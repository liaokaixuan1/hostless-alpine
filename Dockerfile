FROM alpine:3.21

# busybox-extras 提供 httpd 的 CGI 能力；tzdata 让容器时间是本地时区
RUN apk add --no-cache busybox-extras ca-certificates tzdata \
 && adduser -D -H -s /sbin/nologin app 2>/dev/null || true

ENV PORT=8080 \
    TZ=Asia/Shanghai

COPY www/ /www/
COPY entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh /www/cgi-bin/* 2>/dev/null || true

EXPOSE 8080
CMD ["/entrypoint.sh"]