#!/usr/bin/env bash
# apply-hermes-fix.sh
#
# Applies the Host-header fix to the cloudflared tunnel for hermes.thurrsolutions.com.
# - Copies the repo's tunnel config into ~/.cloudflared/config.yml
# - Stops any currently running `cloudflared tunnel run hermes` process
# - Starts a fresh tunnel in the background (logs to /tmp/cloudflared-hermes.log)
# - Tests the endpoint end-to-end with the service token headers
#
# Credentials are sourced from ~/thurnos-memory/.env.local (gitignored).
# Required env vars: HERMES_CF_ID, HERMES_CF_SECRET.
#
# Usage: bash ~/thurnos-memory/scripts/apply-hermes-fix.sh

set -u

REPO_DIR="$HOME/thurnos-memory"
REPO_CONFIG="$REPO_DIR/config/cloudflared-config.yml"
LIVE_CONFIG="$HOME/.cloudflared/config.yml"
LOG="/tmp/cloudflared-hermes.log"
ENV_FILE="$REPO_DIR/.env.local"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: $ENV_FILE not found. Create it with HERMES_CF_ID and HERMES_CF_SECRET."
  exit 1
fi
# shellcheck source=/dev/null
source "$ENV_FILE"
: "${HERMES_CF_ID:?HERMES_CF_ID not set in $ENV_FILE}"
: "${HERMES_CF_SECRET:?HERMES_CF_SECRET not set in $ENV_FILE}"

echo "=== 1. Copy repo config → ~/.cloudflared/config.yml ==="
cp "$REPO_CONFIG" "$LIVE_CONFIG" && echo "ok: copied"
echo

echo "=== 2. Verify httpHostHeader is present ==="
grep -A 2 httpHostHeader "$LIVE_CONFIG" || echo "WARNING: httpHostHeader not found in live config"
echo

echo "=== 3. Stop any running hermes tunnel ==="
PIDS=$(pgrep -f 'cloudflared tunnel run hermes' || true)
if [ -n "$PIDS" ]; then
  echo "killing: $PIDS"
  kill $PIDS
  sleep 2
  PIDS=$(pgrep -f 'cloudflared tunnel run hermes' || true)
  [ -n "$PIDS" ] && kill -9 $PIDS
else
  echo "no running hermes tunnel found"
fi
echo

echo "=== 4. Start new tunnel in background (log: $LOG) ==="
nohup cloudflared tunnel run hermes > "$LOG" 2>&1 &
NEW_PID=$!
echo "started pid=$NEW_PID"
echo "waiting 5s for tunnel to register..."
sleep 5
echo

echo "=== 5. Curl hermes.thurrsolutions.com/api/tags with service token ==="
curl -si "https://hermes.thurrsolutions.com/api/tags" \
  -H "CF-Access-Client-Id: $HERMES_CF_ID" \
  -H "CF-Access-Client-Secret: $HERMES_CF_SECRET" \
  | head -25
echo

echo "=== Done. Tunnel log tail: ==="
tail -20 "$LOG"
