#!/usr/bin/env bash
# finish-mission-2.sh
#
# End-to-end closer for Mission 2:
#   1. Verifies rotated service token works against hermes.thurrsolutions.com
#   2. Installs the tunnel as a launchd boot service (GUI sudo prompt — click once)
#   3. Re-verifies the endpoint after launchd takes over the tunnel
#   4. Commits and pushes all config/script changes to origin/main
#
# Usage: bash ~/thurnos-memory/scripts/finish-mission-2.sh

set -u

REPO_DIR="$HOME/thurnos-memory"
ENV_FILE="$REPO_DIR/.env.local"

# --- Load rotated credentials ---
if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: $ENV_FILE not found."
  exit 1
fi
# shellcheck source=/dev/null
source "$ENV_FILE"
: "${HERMES_CF_ID:?HERMES_CF_ID missing in $ENV_FILE}"
: "${HERMES_CF_SECRET:?HERMES_CF_SECRET missing in $ENV_FILE}"

echo "============================================================"
echo "STEP 1/4: Verify rotated service token works"
echo "============================================================"
STATUS=$(curl -s -o /dev/null -w '%{http_code}' "https://hermes.thurrsolutions.com/api/tags" \
  -H "CF-Access-Client-Id: $HERMES_CF_ID" \
  -H "CF-Access-Client-Secret: $HERMES_CF_SECRET")
echo "HTTP status: $STATUS"
if [ "$STATUS" != "200" ]; then
  echo "ERROR: expected 200, got $STATUS. Aborting before touching launchd."
  exit 1
fi
echo "✓ rotated secret works"
echo

echo "============================================================"
echo "STEP 2/4: Install cloudflared as a boot service (launchd)"
echo "============================================================"
# Stop the foreground/nohup tunnel so launchd can own it
FG_PIDS=$(pgrep -f 'cloudflared tunnel run hermes' || true)
if [ -n "$FG_PIDS" ]; then
  echo "stopping foreground tunnel: $FG_PIDS"
  kill $FG_PIDS
  sleep 2
  FG_PIDS=$(pgrep -f 'cloudflared tunnel run hermes' || true)
  [ -n "$FG_PIDS" ] && kill -9 $FG_PIDS
fi

# Pick the correct cloudflared path (Apple Silicon vs Intel brew)
CFD_BIN=""
for candidate in /opt/homebrew/bin/cloudflared /usr/local/bin/cloudflared; do
  if [ -x "$candidate" ]; then CFD_BIN="$candidate"; break; fi
done
if [ -z "$CFD_BIN" ]; then
  echo "ERROR: cloudflared binary not found"
  exit 1
fi
echo "cloudflared: $CFD_BIN"

echo "Launching GUI password prompt (click OK / Touch ID to authorize)..."
osascript -e "do shell script \"${CFD_BIN} service install\" with administrator privileges"
echo "✓ service install command returned"
sleep 4
echo

echo "============================================================"
echo "STEP 3/4: Verify launchd-managed tunnel works"
echo "============================================================"
echo "launchd plist check (no sudo needed):"
ls -la /Library/LaunchDaemons/com.cloudflare.cloudflared.plist 2>/dev/null \
  || ls -la "$HOME/Library/LaunchAgents/com.cloudflare.cloudflared.plist" 2>/dev/null \
  || echo "(plist not found — service install may have failed)"
sleep 2
echo
echo "Curl test against hermes.thurrsolutions.com..."
STATUS=$(curl -s -o /dev/null -w '%{http_code}' "https://hermes.thurrsolutions.com/api/tags" \
  -H "CF-Access-Client-Id: $HERMES_CF_ID" \
  -H "CF-Access-Client-Secret: $HERMES_CF_SECRET")
echo "HTTP status: $STATUS"
if [ "$STATUS" != "200" ]; then
  echo "WARNING: got $STATUS — launchd tunnel may still be warming up. Check logs:"
  echo "  tail -f /Library/Logs/com.cloudflare.cloudflared.out.log"
fi
echo

echo "============================================================"
echo "STEP 4/4: Commit & push repo changes"
echo "============================================================"
cd "$REPO_DIR" || exit 1

# Stage only the intended paths — keep .env.local OUT (it's gitignored but be explicit)
git add config/cloudflared-config.yml scripts/apply-hermes-fix.sh scripts/install-boot-service.sh scripts/finish-mission-2.sh

echo
echo "Staged diff preview:"
git diff --cached --stat
echo

DATE=$(date +%Y-%m-%d)
git commit -m "sync: $DATE fix hermes tunnel Host header for ollama

- add originRequest.httpHostHeader=localhost to cloudflared config
  (ollama returns 403 for any Host other than localhost/127.0.0.1)
- scripts/apply-hermes-fix.sh: restart tunnel + verify end-to-end
- scripts/install-boot-service.sh: launchd install via GUI sudo prompt
- scripts/finish-mission-2.sh: full closer (verify + boot-service + commit)
- service token secret rotated (see .env.local — gitignored)"

git push origin main
echo
echo "=== All done. ==="
