#!/usr/bin/env bash
# install-boot-service.sh
#
# Installs cloudflared as a launchd service so the hermes tunnel starts on boot
# and restarts on crash. Requires admin privileges (prompts via GUI dialog,
# not inline Terminal sudo).
#
# What it does:
#   1. Stops any foreground/nohup cloudflared tunnel process (we want launchd to own it)
#   2. Runs `sudo cloudflared service install` via osascript (system password dialog)
#   3. Waits for the service to register
#   4. Loads/starts the service
#   5. Verifies via launchctl + curl
#
# Usage: bash ~/thurnos-memory/scripts/install-boot-service.sh

set -u

REPO_DIR="$HOME/thurnos-memory"
ENV_FILE="$REPO_DIR/.env.local"

# Source credentials for the verification curl
if [ -f "$ENV_FILE" ]; then
  # shellcheck source=/dev/null
  source "$ENV_FILE"
fi

echo "=== 1. Stop any running foreground/nohup hermes tunnel ==="
PIDS=$(pgrep -f 'cloudflared tunnel run hermes' || true)
if [ -n "$PIDS" ]; then
  echo "killing: $PIDS"
  kill $PIDS
  sleep 2
  PIDS=$(pgrep -f 'cloudflared tunnel run hermes' || true)
  [ -n "$PIDS" ] && kill -9 $PIDS
else
  echo "no foreground tunnel running — good"
fi
echo

echo "=== 2. Install cloudflared as a system service (will prompt for your Mac password) ==="
# osascript opens a GUI password dialog; user clicks OK / Touch ID instead of typing in Terminal.
# The installed service reads from /etc/cloudflared/config.yml or $HOME/.cloudflared/config.yml
# (cloudflared service install copies from ~/.cloudflared automatically).
osascript -e 'do shell script "/opt/homebrew/bin/cloudflared service install" with administrator privileges' \
  || osascript -e 'do shell script "/usr/local/bin/cloudflared service install" with administrator privileges' \
  || { echo "ERROR: service install failed. Is cloudflared installed via brew?"; exit 1; }
echo

echo "=== 3. Wait 3s for launchd to register ==="
sleep 3
echo

echo "=== 4. Verify service is loaded ==="
sudo launchctl list | grep -i cloudflared || echo "(may need sudo password again)"
echo

echo "=== 5. Quick connectivity test ==="
if [ -n "${HERMES_CF_ID:-}" ] && [ -n "${HERMES_CF_SECRET:-}" ]; then
  echo "curl https://hermes.thurrsolutions.com/api/tags ..."
  curl -si "https://hermes.thurrsolutions.com/api/tags" \
    -H "CF-Access-Client-Id: $HERMES_CF_ID" \
    -H "CF-Access-Client-Secret: $HERMES_CF_SECRET" \
    | head -5
else
  echo "(skipping curl test — $ENV_FILE not set up)"
fi
echo

echo "=== Done. Tunnel should survive reboots now. ==="
echo "To see launchd logs: tail -f /Library/Logs/com.cloudflare.cloudflared.err.log"
