# n8n Workflow Backups

This folder stores n8n workflow backups without credential secrets.

## What Is Backed Up

- `latest/live-db-export`: workflow definitions exported from the local n8n SQLite `workflow_entity` table.
- `latest/static-json`: existing workflow JSON files found in local n8n tool/client folders.
- `latest/manifest.json`: timestamp, counts, and backup notes.
- `archive/YYYYMMDD-HHMMSS`: timestamped copy of each backup run.

## What Is Not Backed Up

- n8n credential tables
- API keys
- service account files
- `.env` files
- token/secret-looking JSON files

## Run Backup

```bash
/Users/thurr/thurnos-memory/scripts/backup-n8n-workflows.sh
```

## Current Limitation

The installed n8n CLI currently requires Node `>=22.16`, while the active shell is using Node `20.20.2`. This backup uses SQLite export as a safe fallback. After Node is upgraded, prefer n8n's official workflow export command and keep credential exports separate and encrypted.
