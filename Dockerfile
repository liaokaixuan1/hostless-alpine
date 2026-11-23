FROM alpine:3.21

# ttyd: terminal over HTTP. Alpine busybox has NO httpd applet ("httpd: applet not found"),
# so never use `busybox httpd` here. ttyd comes from the community repo.
RUN apk add --no-cache ttyd bash coreutils tzdata ca-certificates curl

ENV PORT=8080 \
    TZ=Asia/Shanghai \
    TTYD_USER=admin

# Static musl binaries, baked into the image so they survive restarts.
# nodeget-agent  2,310,860 B  sha256 9a51055f84187d340233f1ab8fc151f0211a4e0052263d21515638c64ae53524
# traffmonetizer 2,786,464 B  sha256 b1c7903423b432c0f02d062651e311da188d0343a3b24928020239769cd7b851
COPY bin/nodeget-agent   /usr/local/bin/nodeget-agent
COPY bin/traffmonetizer  /usr/local/bin/traffmonetizer
RUN chmod 0755 /usr/local/bin/nodeget-agent /usr/local/bin/traffmonetizer

COPY entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh

EXPOSE 8080
CMD ["/entrypoint.sh"]