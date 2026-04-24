#!/usr/bin/env bash
# fix-daemon-config.sh — populate /etc/cloudflared/ so the launchd-managed
# hermes tunnel has a config to read. Also restarts the daemon.
#
# Root cause: on macOS, `cloudflared service install` creates the LaunchDaemon
# but doesn't always copy ~/.cloudflared/config.yml + credentials into
# /etc/cloudflared/. The daemon runs as root reading /etc/cloudflared/config.yml,
# so if that's missing, no tunnel comes up and edge returns 530.

set -u
ENV_FILE="$HOME/thurnos-memory/.env.local"
# shellcheck source=/dev/null
[ -f "$ENV_FILE" ] && source "$ENV_FILE"

TUNNEL_UUID="d8e11dda-9d0f-4c45-8587-b2fbe0795d5c"
USER_DIR="$HOME/.cloudflared"
SYS_DIR="/etc/cloudflared"

# Verify source files exist before touching /etc/
if [ ! -f "$USER_DIR/config.yml" ]; then
  echo "ERROR: $USER_DIR/config.yml not found"; exit 1
fi
if [ ! -f "$USER_DIR/${TUNNEL_UUID}.json" ]; then
  echo "ERROR: $USER_DIR/${TUNNEL_UUID}.json not found"; exit 1
fi

# Build one heredoc of root commands so there's ONE password prompt.
SCRIPT=$(cat <<EOF
mkdir -p $SYS_DIR
cp '$USER_DIR/config.yml' '$SYS_DIR/config.yml'
cp '$USER_DIR/${TUNNEL_UUID}.json' '$SYS_DIR/${TUNNEL_UUID}.json'
# Rewrite credentials-file path inside the copied config so it points at /etc/cloudflared/
sed -i '' 's|credentials-file: .*|credentials-file: $SYS_DIR/${TUNNEL_UUID}.json|' '$SYS_DIR/config.yml'
chown root:wheel '$SYS_DIR/config.yml' '$SYS_DIR/${TUNNEL_UUID}.json'
chmod 644 '$SYS_DIR/config.yml'
chmod 600 '$SYS_DIR/${TUNNEL_UUID}.json'
# Restart the daemon to pick up the new config
launchctl kickstart -k system/com.cloudflare.cloudflared
EOF
)

echo "=== Running privileged setup (will prompt for password once) ==="
osascript -e "do shell script \"$SCRIPT\" with administrator privileges"
echo "✓ privileged block done"
echo

echo "=== Verify /etc/cloudflared/ ==="
ls -la /etc/cloudflared/
echo
echo "--- /etc/cloudflared/config.yml ---"
cat /etc/cloudflared/config.yml
echo

echo "=== Wait 6s for daemon to re-register tunnel connections ==="
sleep 6

echo "=== Daemon log (out) tail ==="
tail -15 /Library/Logs/com.cloudflare.cloudflared.out.log 2>/dev/null || echo "(no out log yet)"
echo
echo "=== Daemon log (err) tail ==="
tail -15 /Library/Logs/com.cloudflare.cloudflared.err.log 2>/dev/null || echo "(no err log yet)"
echo

echo "=== Curl test ==="
if [ -n "${HERMES_CF_ID:-}" ] && [ -n "${HERMES_CF_SECRET:-}" ]; then
  curl -si "https://hermes.thurrsolutions.com/api/tags" \
    -H "CF-Access-Client-Id: $HERMES_CF_ID" \
    -H "CF-Access-Client-Secret: $HERMES_CF_SECRET" \
    | head -5
else
  echo "(env not sourced)"
fi
