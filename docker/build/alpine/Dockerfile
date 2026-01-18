FROM wbitt/network-multitool:alpine-extra

RUN apk update && apk add --no-cache \
    net-tools \
    && rm -rf /var/cache/apk/*

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]