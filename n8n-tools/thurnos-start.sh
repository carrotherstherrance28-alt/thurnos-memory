#!/bin/bash
# Thurnos Prime — Startup Script
# Starts n8n + ngrok tunnel
# Run: bash ~/thurnos-memory/n8n-tools/thurnos-start.sh

export PATH="/Users/thurr/.nvm/versions/node/v20.20.2/bin:/opt/homebrew/bin:$PATH"

echo "╔══════════════════════════════════════╗"
echo "║        THURNOS PRIME STARTUP         ║"
echo "╚══════════════════════════════════════╝"

# ── n8n ──────────────────────────────────────────────────────────────────────
if lsof -i :5678 | grep -q LISTEN; then
    echo "✅ n8n already running on port 5678"
else
    echo "🚀 Starting n8n..."
    nohup n8n start > ~/.n8n/n8n.log 2>&1 &
    sleep 5
    if lsof -i :5678 | grep -q LISTEN; then
        echo "✅ n8n started"
    else
        echo "❌ n8n failed to start — check ~/.n8n/n8n-error.log"
        exit 1
    fi
fi

# ── ngrok ────────────────────────────────────────────────────────────────────
if pgrep -x ngrok > /dev/null; then
    echo "✅ ngrok already running"
    TUNNEL_URL=$(curl -s http://localhost:4040/api/tunnels | python3 -c "import json,sys; t=json.load(sys.stdin)['tunnels']; print(t[0]['public_url'] if t else 'not found')" 2>/dev/null)
else
    echo "🚀 Starting ngrok tunnel..."
    nohup ngrok http 5678 > /tmp/ngrok.log 2>&1 &
    sleep 3
    TUNNEL_URL=$(curl -s http://localhost:4040/api/tunnels | python3 -c "import json,sys; t=json.load(sys.stdin)['tunnels']; print(t[0]['public_url'] if t else 'not found')" 2>/dev/null)
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ n8n:   http://localhost:5678"
echo "🌐 ngrok: $TUNNEL_URL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Thurnos Prime is live."
