# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Identity

This repo is **Thurnos** — the operating brain of Thurr Solutions, owned by Therrance Carrothers. It is a knowledge-compounding system for n8n workflow automation. Every session should leave the memory system smarter than it was before.

Read `THURNOS.md` for the full system philosophy. Read `memory/MEMORY.md` at the start of every session to orient before doing any work.

---

## Repository Structure

- `THURNOS.md` — System manifesto and operating rules
- `memory/` — Core knowledge base (`MEMORY.md` is the index; subdirs: `user/`, `feedback/`, `project/`, `reference/`)
- `skills/` — Atomic reusable technique files, one pattern per file
- `knowledge-base/` — Longer-form reference entries on tools and domains
- `projects/` — Per-project working memory and artifacts
- `n8n-tools/` — n8n workflow automation hub
  - `n8n-builder/CLAUDE.md` — Detailed n8n + Claude workflow-building guide (read this when building workflows)
  - `knowledge-base/` — Debugging guides, patterns, issues/solutions
  - `claude-webhook-server.js` — Node.js webhook server that bridges n8n failures to Claude Code
- `maximax-internship/` — Internship case studies and portfolio docs
- `restore-c/` — Active client project (Weather Stopper roofing contractor)
- `thurr-solutions/` — Agency brand assets

---

## n8n Integration

**n8n instance:** `https://therrancecarrothers.app.n8n.cloud/`  
**MCP config:** `.mcp.json` — wires `n8n-mcp` (npx) into Claude Code via stdio

The MCP server provides access to 1,084 n8n nodes, 2,709 workflow templates, and 265 AI-capable tool variants. It is already configured in `.mcp.json`; just run `claude mcp list` to verify it is loaded.

**Install n8n-skills plugin (if not already installed):**
```bash
/plugin install czlonkowski/n8n-skills
```

**Run the Claude webhook server (bridges n8n error triggers to Claude):**
```bash
node n8n-tools/claude-webhook-server.js
# Expose externally with ngrok if needed: ngrok http 3456
# Health check: GET http://localhost:3456/health
```

---

## Workflow Building Rules

Full details are in `n8n-tools/n8n-builder/CLAUDE.md`. Critical rules:

- **Never edit production workflows directly.** Always copy first, test in dev, validate, manually review, then deploy.
- **Validation profiles:** Use `ai-friendly` during development, `strict` before production.
- **Workflow deployment path:** Development → Validation → Testing → Manual Review → Production

**The 5 workflow patterns to select from:**
1. Data Transformation Pipeline: `Trigger → Fetch → Transform → Validate → Store`
2. Webhook-Based Automation: `Webhook → Parse → Conditional → Execute → Respond`
3. Scheduled Data Sync: `Schedule → Fetch → Diff → Update → Log`
4. Error Handling Pattern: `Main → [Error Trigger] → Log → Notify → Retry`
5. Event-Driven Integration: `Event → Validate → Transform → Route → Execute`

**Critical expression gotchas:**

| Mistake | Wrong | Correct |
|---------|-------|---------|
| Webhook data access | `$json.email` | `$json.body.email` |
| Code node return | `return data` | `return [{json: {...}}]` |
| Data access in Code | `items[0]` | `$input.first()` or `$input.all()` |
| Node type format | `n8n-nodes-base.slack` | `nodes-base.slack` |
| Expressions in Code nodes | `{{ }}` syntax | Direct JavaScript |

**Code nodes:** Use JavaScript 95% of the time — Python lacks external library support.

---

## Memory System

**Memory types and when to update:**
- `memory/user/` — Therrance's preferences, working style, tools
- `memory/feedback/` — Extracted lessons (what worked, what failed, why)
- `memory/project/` — Active client/project context and decisions
- `memory/reference/` — Stable tool/API/platform reference

**Rules for compounding:**
- Update existing files rather than creating duplicates
- Extract lessons — do not dump raw conversation
- Update `memory/MEMORY.md` index whenever a file is added or significantly changed
- One source of truth per topic; merge if duplicated

**Skills files** go in `skills/` with this frontmatter:
```yaml
---
name: <human-readable name>
type: <n8n | claude-code | client-template | prompt-pattern | api-recipe>
description: <one sentence>
date_added: YYYY-MM-DD
---
```

---

## Build vs Adapt SOP (Standing Operating Procedure)

Before building ANY new workflow, tool, automation, or skill:

1. **Search GitHub first** — `n8n-io/n8n-workflows`, awesome-mcp-servers, tags: `n8n`, `mcp`, `ai-agent`, `automation`
2. **Report findings** — summarize what exists and estimate % match to the goal
3. **Decision rule:** 70%+ match → adapt it | below 70% → build from scratch
4. **Never build blind** — confirm with Therrance before starting if a close match exists
5. **Log it** — record what was searched, found, and built/adapted

Trigger: `/prebuild [description]` in Discord

---

## Commit Convention

One commit per session:
```
sync: YYYY-MM-DD <what was added or updated>
```

Example: `sync: 2026-04-06 added n8n webhook auth skill, updated project/restore-c context`

---

## Active Context

- **Active client:** RESTORE-C (Weather Stopper roofing contractor)
- **Internship:** Maximax Automation Agency (case studies in `maximax-internship/`)
- **API optimization priority:** Batch calls, pre-filter before expensive LLM steps, use cheapest capable model, cache repeat lookups
- **Workflow IDs on n8n cloud:**
  - Case 1 (Sales Proposal & Contract): `Iar5xzG6KaCj8Gy2`
  - Case 2 (Lead Qualification Agent): `qG6B8b5kwP5zmJKm`
