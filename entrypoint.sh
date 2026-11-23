#!/bin/sh
# Hostless 运行时约定：监听 $PORT、绑定 0.0.0.0、日志走 stdout。
# darkhttpd 是前台进程（不加 --daemon），正好当 PID 1。
set -e

PORT="${PORT:-8080}"
echo "[boot] alpine $(cat /etc/alpine-release) port=${PORT} cpus=$(nproc) server=darkhttpd"

# 根文件系统只读：只允许写 /tmp、/root、/app/.cache
export TMPDIR=/tmp

exec /usr/bin/darkhttpd /www --port "${PORT}" --addr 0.0.0.0