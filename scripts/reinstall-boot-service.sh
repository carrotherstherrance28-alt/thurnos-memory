#!/usr/bin/env bash
# reinstall-boot-service.sh
#
# Uninstall + reinstall cloudflared's launchd service. The first install
# ran before /etc/cloudflared/config.yml existed, so cloudflared generated
# a broken plist that invokes `cloudflared` without `tunnel run`. With
# /etc/cloudflared/ now populated, a fresh install produces the correct plist.
#
# Shows before-and-after plist ProgramArguments and runs a final curl.

set -u
ENV_FILE="$HOME/thurnos-memory/.env.local"
# shellcheck source=/dev/null
[ -f "$ENV_FILE" ] && source "$ENV_FILE"

CFD_BIN=""
for c in /opt/homebrew/bin/cloudflared /usr/local/bin/cloudflared; do
  [ -x "$c" ] && CFD_BIN="$c" && break
done
[ -z "$CFD_BIN" ] && { echo "cloudflared not found"; exit 1; }

PLIST=/Library/LaunchDaemons/com.cloudflare.cloudflared.plist

echo "=== BEFORE: current plist ProgramArguments ==="
if [ -f "$PLIST" ]; then
  /usr/libexec/PlistBuddy -c 'Print :ProgramArguments' "$PLIST" 2>/dev/null || cat "$PLIST"
else
  echo "(plist not present — odd)"
fi
echo

# One osascript block = one password prompt for uninstall + reinstall + kickstart.
SCRIPT=$(cat <<EOF
launchctl bootout system/com.cloudflare.cloudflared 2>/dev/null || true
'$CFD_BIN' service uninstall || true
'$CFD_BIN' service install
# Ensure /etc/cloudflared/config.yml is still in place (service install
# sometimes overwrites) — if so, copy from repo source again:
if [ ! -f /etc/cloudflared/config.yml ]; then
  cp '$HOME/.cloudflared/config.yml' /etc/cloudflared/config.yml
  sed -i '' 's|credentials-file: .*|credentials-file: /etc/cloudflared/d8e11dda-9d0f-4c45-8587-b2fbe0795d5c.json|' /etc/cloudflared/config.yml
fi
launchctl bootstrap system /Library/LaunchDaemons/com.cloudflare.cloudflared.plist 2>/dev/null || true
launchctl kickstart -k system/com.cloudflare.cloudflared
EOF
)

echo "=== Running uninstall + reinstall (ONE password prompt) ==="
osascript -e "do shell script \"$SCRIPT\" with administrator privileges"
echo "✓ done"
echo

echo "=== AFTER: new plist ProgramArguments ==="
/usr/libexec/PlistBuddy -c 'Print :ProgramArguments' "$PLIST" 2>/dev/null || cat "$PLIST"
echo

echo "=== Wait 8s for 4 tunnel connections to register ==="
sleep 8

echo "=== Daemon log (out) tail ==="
tail -15 /Library/Logs/com.cloudflare.cloudflared.out.log 2>/dev/null || echo "(no out log)"
echo
echo "=== Daemon log (err) tail ==="
tail -15 /Library/Logs/com.cloudflare.cloudflared.err.log 2>/dev/null || echo "(no err log)"
echo

echo "=== Is cloudflared running? ==="
pgrep -lf cloudflared
echo

echo "=== Final curl test ==="
if [ -n "${HERMES_CF_ID:-}" ] && [ -n "${HERMES_CF_SECRET:-}" ]; then
  curl -si "https://hermes.thurrsolutions.com/api/tags" \
    -H "CF-Access-Client-Id: $HERMES_CF_ID" \
    -H "CF-Access-Client-Secret: $HERMES_CF_SECRET" \
    | head -5
else
  echo "(env not sourced)"
fi
