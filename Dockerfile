FROM amazon/aws-cli
RUN yum install -y wget bind-utils
ENTRYPOINT ["/usr/local/bin/aws-route53-dynamic-update.sh"]
ADD ./aws-route53-dynamic-update.sh /usr/local/bin/aws-route53-dynamic-update.sh
