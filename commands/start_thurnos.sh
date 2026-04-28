#!/bin/bash
# Thurnos Startup Script
# Rebuilds the model with latest Modelfile, then starts a session with memory loaded

MODELFILE="${MODELFILE:-$HOME/thurnos-memory/Modelfile}"
MEMORY_DIR="${MEMORY_DIR:-$HOME/thurnos-memory/memory}"
LOG_DIR="${LOG_DIR:-$HOME/thurnos-memory/logs}"

echo "========================================="
echo "  THURNOS — ThurrSolutions Operations AI"
echo "========================================="
echo ""

# Step 1: Rebuild model from Modelfile
echo "[1/3] Rebuilding Thurnos model from Modelfile..."
ollama create thurnos -f "$MODELFILE"
if [ $? -ne 0 ]; then
  echo "❌ Failed to build model. Is Ollama running?"
  echo "   Start it with: ollama serve"
  exit 1
fi
echo "✅ Model rebuilt."
echo ""

# Step 2: Build memory context string
echo "[2/3] Loading memory files..."
MEMORY_CONTEXT=""

for f in "$MEMORY_DIR"/*.md "$MEMORY_DIR"/*.txt; do
  if [ -f "$f" ] && [[ "$f" != *"api_key"* ]] && [[ "$f" != *"token"* ]]; then
    FILENAME=$(basename "$f")
    CONTENT=$(cat "$f")
    MEMORY_CONTEXT="${MEMORY_CONTEXT}\n\n--- MEMORY: $FILENAME ---\n$CONTENT"
  fi
done

# Add most recent log if it exists
LATEST_LOG=$(ls -t "$LOG_DIR"/*.md 2>/dev/null | head -1)
if [ -f "$LATEST_LOG" ]; then
  LOG_NAME=$(basename "$LATEST_LOG")
  LOG_CONTENT=$(cat "$LATEST_LOG")
  MEMORY_CONTEXT="${MEMORY_CONTEXT}\n\n--- RECENT LOG: $LOG_NAME ---\n$LOG_CONTENT"
fi

echo "✅ Memory loaded."
echo ""

# Step 3: Start Thurnos with memory injected
echo "[3/3] Starting Thurnos session..."
echo ""
echo "  Type your request or ask for a briefing."
echo "  Type /bye to exit."
echo ""
echo "========================================="
echo ""

ollama run thurnos
