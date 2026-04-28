#!/bin/bash
set -euo pipefail

KEY_FILE="${N8N_API_KEY_FILE:-$HOME/Documents/ThurrSolutions/_sensitive_archive/n8n_api_key.txt}"
if [ -z "${N8N_API_KEY:-}" ] && [ -f "$KEY_FILE" ]; then
  N8N_API_KEY="$(cat "$KEY_FILE")"
fi

if [ -z "${N8N_API_KEY:-}" ]; then
  echo "Missing N8N_API_KEY. Set the env var or place it in: $KEY_FILE" >&2
  exit 1
fi

echo "Checking N8N Cloud..."
curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" "https://therrancecarrothers.app.n8n.cloud/api/v1/workflows?limit=10" \
  | python3 -m json.tool \
  | grep -E '"name"|"active"'
