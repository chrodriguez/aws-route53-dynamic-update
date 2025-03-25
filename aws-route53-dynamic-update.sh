#!/bin/bash

set -e

[ -z "$ZONEID" ] && echo ZONEID must be set && exit 1

[ -z "$RECORDSET" ] && echo RECORDSET must be set && exit 1

DATA_DIR="/tmp"
TTL=${TTL:-60}
TYPE=${TYPE:-"A"}
IP=${IP:-$(wget -qO- http://ifconfig.me/ip)}
DNS_SERVER=${DNS_SERVER:-8.8.8.8}

[ -z "$IP" ] && echo IP cant be retrieved && exit 1

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}


if ! valid_ip $IP; then
    echo "Invalid retrieved IP address: $IP"
    exit 1
fi

CURRENT_IP=$( dig -t $TYPE $RECORDSET +short @${DNS_SERVER} )

[ -z "$CURRENT_IP" ] && echo CURRENT_IP cant be retrieved from DNS && exit 1

if ! valid_ip $CURRENT_IP; then
    echo "Invalid retrieved CURRENT_IP address FROM DNS: $IP"
    exit 1
fi

if [ "$CURRENT_IP" = "$IP" ]; then
    echo "Update not needed"
    exit 0
else
    echo "IP has changed to $IP"
    TMPFILE=$(mktemp $DATA_DIR/temporary-file.XXXXXXXX)
    cat > ${TMPFILE} << EOF
    {
      "Comment":"Auto updating @ $(date)",
      "Changes":[
        {
          "Action":"UPSERT",
          "ResourceRecordSet":{
            "ResourceRecords":[
              {
                "Value":"$IP"
              }
            ],
            "Name":"$RECORDSET",
            "Type":"$TYPE",
            "TTL":$TTL
          }
        }
      ]
    }
EOF
    aws route53 change-resource-record-sets --hosted-zone-id $ZONEID --change-batch file://"$TMPFILE"
    rm $TMPFILE
fi
