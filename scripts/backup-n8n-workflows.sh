#!/usr/bin/env bash
set -euo pipefail

N8N_DB="${N8N_DB:-$HOME/.n8n/database.sqlite}"
REPO_ROOT="${REPO_ROOT:-$HOME/thurnos-memory}"
BACKUP_ROOT="${BACKUP_ROOT:-$REPO_ROOT/backups/n8n-workflows}"
SNAPSHOT_DIR="$BACKUP_ROOT/latest"
ARCHIVE_DIR="$BACKUP_ROOT/archive/$(date +%Y%m%d-%H%M%S)"

if [[ ! -f "$N8N_DB" ]]; then
  echo "n8n database not found: $N8N_DB" >&2
  exit 1
fi

command -v sqlite3 >/dev/null || { echo "sqlite3 is required" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

mkdir -p "$SNAPSHOT_DIR/live-db-export" "$SNAPSHOT_DIR/static-json" "$ARCHIVE_DIR"

tmp="$(mktemp)"
sqlite3 -json "$N8N_DB" \
  "select id,name,active,json(nodes) as nodes,json(connections) as connections,json(settings) as settings,json(staticData) as staticData,json(pinData) as pinData,createdAt,updatedAt,versionId,versionCounter,description from workflow_entity order by name;" \
  > "$tmp"

rm -f "$SNAPSHOT_DIR/live-db-export"/*.json

jq -c '.[]' "$tmp" | while IFS= read -r row; do
  id="$(jq -r '.id' <<<"$row")"
  name="$(jq -r '.name' <<<"$row")"
  safe_name="$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
  file="$SNAPSHOT_DIR/live-db-export/${safe_name:-workflow}-$id.json"

  jq '{
    id,
    name,
    active,
    nodes,
    connections,
    settings,
    staticData,
    pinData,
    createdAt,
    updatedAt,
    versionId,
    versionCounter,
    description
  }' <<<"$row" > "$file"
done

rm -f "$SNAPSHOT_DIR/static-json"/*.json

find "$HOME/n8n-tools" "$REPO_ROOT/n8n-tools" "$REPO_ROOT/clients" \
  -type f -name '*.json' 2>/dev/null \
  | grep -Ev '/\.netlify/' \
  | grep -Evi 'credential|secret|token|service-account|service_account|\\.env' \
  | while IFS= read -r file; do
      rel="$(printf '%s' "$file" | sed "s#^$HOME/##" | tr '/' '__')"
      cp "$file" "$SNAPSHOT_DIR/static-json/$rel"
    done

workflow_count="$(find "$SNAPSHOT_DIR/live-db-export" -type f -name '*.json' | wc -l | tr -d ' ')"
static_count="$(find "$SNAPSHOT_DIR/static-json" -type f -name '*.json' | wc -l | tr -d ' ')"

cat > "$SNAPSHOT_DIR/manifest.json" <<JSON
{
  "createdAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "sourceDatabase": "$N8N_DB",
  "workflowCount": $workflow_count,
  "staticJsonCount": $static_count,
  "credentialsBackedUp": false,
  "notes": [
    "Exports workflow definitions from workflow_entity only.",
    "Credential tables and credential-looking files are intentionally excluded.",
    "Use n8n's official CLI export when Node is upgraded to a supported n8n runtime."
  ]
}
JSON

cp -R "$SNAPSHOT_DIR/." "$ARCHIVE_DIR/"
rm -f "$tmp"

echo "n8n workflow backup complete"
echo "Latest: $SNAPSHOT_DIR"
echo "Archive: $ARCHIVE_DIR"
echo "Live workflows: $workflow_count"
echo "Static JSON files: $static_count"
