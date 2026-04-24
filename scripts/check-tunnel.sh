#!/usr/bin/env bash
# check-tunnel.sh — diagnose the launchd-managed hermes tunnel after install.
# Usage: bash ~/thurnos-memory/scripts/check-tunnel.sh

set -u
ENV_FILE="$HOME/thurnos-memory/.env.local"
# shellcheck source=/dev/null
[ -f "$ENV_FILE" ] && source "$ENV_FILE"

echo "=== 1. Is cloudflared running? ==="
pgrep -lf cloudflared || echo "(not running)"
echo

echo "=== 2. launchd plist present ==="
ls -la /Library/LaunchDaemons/com.cloudflare.cloudflared.plist 2>/dev/null || echo "(missing)"
echo

echo "=== 3. Daemon log tail (out) ==="
[ -f /Library/Logs/com.cloudflare.cloudflared.out.log ] && tail -30 /Library/Logs/com.cloudflare.cloudflared.out.log || echo "(out log not yet written)"
echo
echo "=== 4. Daemon log tail (err) ==="
[ -f /Library/Logs/com.cloudflare.cloudflared.err.log ] && tail -30 /Library/Logs/com.cloudflare.cloudflared.err.log || echo "(err log not yet written)"
echo

echo "=== 5. What config is the daemon reading? ==="
ls -la /etc/cloudflared/ 2>/dev/null || echo "(/etc/cloudflared/ missing — daemon may be reading ~/.cloudflared/config.yml)"
echo
echo "--- /etc/cloudflared/config.yml (if present) ---"
cat /etc/cloudflared/config.yml 2>/dev/null || echo "(not present)"
echo

echo "=== 6. Curl test ==="
if [ -n "${HERMES_CF_ID:-}" ] && [ -n "${HERMES_CF_SECRET:-}" ]; then
  curl -si "https://hermes.thurrsolutions.com/api/tags" \
    -H "CF-Access-Client-Id: $HERMES_CF_ID" \
    -H "CF-Access-Client-Secret: $HERMES_CF_SECRET" \
    | head -3
else
  echo "(env not sourced)"
fi
