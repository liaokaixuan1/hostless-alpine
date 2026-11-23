#!/bin/sh
# Hostless Alpine web shell + nodeget probe + traffmonetizer
# All writable state lives under /root (wiped on restart); binaries are baked into the image.
set -u

PORT="${PORT:-8000}"
TTYD_USER="${TTYD_USER:-admin}"
TTYD_PASS="${TTYD_PASS:-}"

if [ -z "$TTYD_PASS" ]; then
  TTYD_PASS="$(head -c 32 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 16)"
fi

export HOME=/root
export TMPDIR=/tmp
export TERM=xterm-256color
export LANG=C.UTF-8

mkdir -p /root/.ng /root/.tfm

echo "[boot] $(cat /etc/alpine-release 2>/dev/null) port=${PORT} cpus=$(nproc 2>/dev/null || echo '?')"
echo "[auth] user=${TTYD_USER}"
echo "[auth] pass=${TTYD_PASS}"

# ---------- NodeGet agent ----------
if [ -n "${NG_AGENT_ID:-}" ] && [ -n "${NG_TOKEN:-}" ]; then
  cat > /root/.ng/nodeget-agent.toml <<EOF
log_level = "info"
dynamic_summary_report_interval_ms = 3000
dynamic_report_interval_ms = 3000
static_report_interval_ms = 300000
agent_uuid = "${NG_AGENT_ID}"
connect_timeout_ms = 5000
terminal_shell = "bash"
exec_max_character = 30000
ip_provider = "cloudflare"

[[server]]
name = "${NG_SERVER_NAME:-zongkong}"
server_uuid = "${NG_SERVER_ID:-4d15eb19-1056-4edc-9429-21f23fa6845d}"
token = "${NG_TOKEN}"
ws_url = "${NG_WS_URL:-wss://nodeget-qwenpaw.go.altare.global/nodeget/rpc}"
allow_task = true
allow_task_type = [ "http_ping", "web_shell", "read_config", "execute", "self_update", "ip", "version", "edit_config", "http_request", "ping", "tcp_ping", "dns" ]
ignore_cert = false
EOF
  ( setsid /usr/local/bin/nodeget-agent -c /root/.ng/nodeget-agent.toml \
      >> /root/.ng/agent.log 2>&1 < /dev/null & )
  echo "[boot] nodeget-agent started (agent_id=${NG_AGENT_ID})"
else
  echo "[boot] nodeget-agent skipped (NG_AGENT_ID / NG_TOKEN not set)"
fi

# ---------- Traffmonetizer ----------
if [ -n "${TFM_TOKEN:-}" ]; then
  ( cd /root/.tfm && setsid /usr/local/bin/traffmonetizer start accept --token "$TFM_TOKEN" \
      >> /root/.tfm/tfm.log 2>&1 < /dev/null & )
  echo "[boot] traffmonetizer started"
else
  echo "[boot] traffmonetizer skipped (TFM_TOKEN not set)"
fi

sleep 1
echo "[boot] entering ttyd on 0.0.0.0:${PORT}"

# -W is mandatory: without it ttyd is read-only and the browser cannot type anything.
exec /usr/bin/ttyd \
  -p "$PORT" \
  -i 0.0.0.0 \
  -b / \
  -w /root \
  -W \
  -t rendererType=canvas \
  -t fontSize=15 \
  -t disableLeaveAlert=true \
  -c "${TTYD_USER}:${TTYD_PASS}" \
  /bin/bash -l