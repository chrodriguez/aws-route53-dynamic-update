#!/bin/bash

set -e

[ -z "$ZONEID" ] && echo ZONEID must be set && exit 1

[ -z "$RECORDSET" ] && echo RECORDSET must be set && exit 1

DATA_DIR=${DATA_DIR:-/tmp}
TTL=${TTL:-60}
TYPE=${TYPE:-"A"}
IP=$(wget -qO- http://ifconfig.me)

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


IPFILE="$DATA_DIR/ip"

if ! valid_ip $IP; then
    echo "Invalid IP address: $IP" >> "$LOGFILE"
    exit 1
fi

[ ! -f "$IPFILE" ] && touch "$IPFILE"

if grep -Fxq "$IP" "$IPFILE"; then
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
echo "$IP" > "$IPFILE"
