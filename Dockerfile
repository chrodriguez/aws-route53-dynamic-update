FROM amazon/aws-cli
ADD ./aws-route53-dynamic-update.sh /usr/local/bin/aws-route53-dynamic-update.sh
RUN yum install -y wget
ENTRYPOINT ["/usr/local/bin/aws-route53-dynamic-update.sh"]
