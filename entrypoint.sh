#!/bin/sh
# Hostless 运行时约定：监听 $PORT、绑定 0.0.0.0、日志走 stdout。
set -e

PORT="${PORT:-8080}"
echo "[boot] alpine $(cat /etc/alpine-release) port=${PORT} cpus=$(nproc)"

# 根文件系统只读：只允许写 /tmp、/root、/app/.cache
# 这里把 httpd 的运行期垃圾都指到 /tmp
mkdir -p /tmp/httpd
export TMPDIR=/tmp

exec /bin/busybox httpd -f -p "${PORT}" -h /www