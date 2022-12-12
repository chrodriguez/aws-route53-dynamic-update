FROM alpine:3.17
RUN apk add -U py-pip bash bind-tools \
  && adduser -S aws -s /bin/ash -h /aws
ADD ./aws-route53-dynamic-update.sh /usr/local/bin/aws-route53-dynamic-update.sh
USER aws
ENV PATH=$PATH:/aws/.local/bin
RUN python -m pip install awscli
WORKDIR /aws
ENTRYPOINT ["/usr/local/bin/aws-route53-dynamic-update.sh"]
