FROM alpine:3.21

# darkhttpd 是 Alpine 里最省事的静态服务器：单二进制、支持 --port/--addr。
# 注意：alpine 的 busybox 不带 httpd applet（会报 "httpd: applet not found"），
# busybox-extras 也不提供它 —— 别再试 busybox httpd。
RUN apk add --no-cache darkhttpd ca-certificates tzdata

ENV PORT=8080 \
    TZ=Asia/Shanghai

COPY www/ /www/
COPY entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh

EXPOSE 8080
CMD ["/entrypoint.sh"]