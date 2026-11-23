#!/bin/sh
# Hostless 运行时约定：监听 $PORT、绑定 0.0.0.0、日志走 stdout。
#
# ttyd 提供浏览器终端。必须带 basic auth —— Hostless 的
# "malware and unauthorized remote access" 政策只允许「已授权的远程访问」，
# 要求你能说明访问是怎么被限制的。无认证的公开 shell 会被暂停。
set -e

PORT="${PORT:-8080}"
TTYD_USER="${TTYD_USER:-admin}"
TTYD_PASS="${TTYD_PASS:-}"

echo "[boot] alpine $(cat /etc/alpine-release) port=${PORT} cpus=$(nproc) server=ttyd"

# 根文件系统只读：只允许写 /tmp、/root、/app/.cache
export TMPDIR=/tmp
export HOME=/root

# 没给密码就现场生成一个，并打印到 stdout（日志里可见，只在本次容器生命周期有效）
if [ -z "$TTYD_PASS" ]; then
  TTYD_PASS="$(head -c 18 /dev/urandom | base64 | tr -d '/+=' | head -c 16)"
  echo "[auth] generated one-time password"
fi

echo "[auth] user=${TTYD_USER}"
echo "[auth] pass=${TTYD_PASS}"
echo "[auth] open: https://<your-app-url>/  (basic auth)"

# -W 允许客户端输入；-w 是 working dir；--once 不要（要能反复用）
exec /usr/bin/ttyd \
  -p "${PORT}" \
  -i 0.0.0.0 \
  -b / \
  -w /root \
  -t rendererType=xterm-256color \
  -t fontSize=15 \
  -c "${TTYD_USER}:${TTYD_PASS}" \
  /bin/bash -l