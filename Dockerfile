FROM alpine:3.21

# ttyd：把终端挂到 HTTP 上。注意 alpine 的 busybox 不带 httpd applet
# （"httpd: applet not found"），所以别用 busybox httpd。
# ttyd 依赖 libwebsockets，community 仓库有预编译包。
RUN apk add --no-cache ttyd bash coreutils tzdata ca-certificates

ENV PORT=8080 \
    TZ=Asia/Shanghai \
    TTYD_USER=admin

COPY entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh

# 端口由 Hostless 注入 $PORT；ttyd 必须绑 0.0.0.0 才能过健康检查
EXPOSE 8080
CMD ["/entrypoint.sh"]