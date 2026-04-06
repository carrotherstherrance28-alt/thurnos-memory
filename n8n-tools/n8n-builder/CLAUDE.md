# n8n Workflow Builder - Claude Configuration

## Project Overview

This project enables Claude to build, modify, debug, and document n8n workflows through the **n8n-mcp** MCP server and **n8n-skills** package. Claude has access to 1,084 n8n nodes, 2,709 workflow templates, and production-tested patterns.

**Tools:**
- [n8n-mcp](https://github.com/czlonkowski/n8n-mcp) - MCP server for node access and workflow management
- [n8n-skills](https://github.com/czlonkowski/n8n-skills) - 7 specialized skills for production-ready workflows

---

## 1. Environment Setup

### Required Environment Variables

```bash
# MCP Configuration
MCP_MODE=stdio                    # Required: enables Claude integration
LOG_LEVEL=error                   # Required: prevents JSON parsing errors
DISABLE_CONSOLE_OUTPUT=true       # Required: clean operation

# n8n Instance Connection
N8N_API_URL=https://your-n8n-instance.com    # Your n8n instance URL
N8N_API_KEY=your-api-key                      # API key from n8n Settings → API
```

### Quick Setup (Claude Code CLI)

**Remote n8n Instance:**
```bash
claude mcp add n8n-mcp \
 -e MCP_MODE=stdio \
 -e LOG_LEVEL=error \
 -e DISABLE_CONSOLE_OUTPUT=true \
 -e N8N_API_URL=https://your-n8n-instance.com \
 -e N8N_API_KEY=your-api-key \
 -- npx n8n-mcp
```

**Local n8n Instance:**
```bash
claude mcp add n8n-mcp \
 -e MCP_MODE=stdio \
 -e LOG_LEVEL=error \
 -e DISABLE_CONSOLE_OUTPUT=true \
 -e N8N_API_URL=http://localhost:5678 \
 -e N8N_API_KEY=your-local-api-key \
 -- npx n8n-mcp
```

**Local Development Note:** Set `WEBHOOK_SECURITY_MODE=moderate` in your local n8n environment for easier webhook testing.

### Install Skills

```bash
/plugin install czlonkowski/n8n-skills
```

### Verify Setup

```bash
# Check MCP server
claude mcp list

# Test connection (ask Claude)
"What n8n nodes are available for Slack?"
```

---

## 2. Safety Rules

### Critical Safety Requirements

**🚨 NEVER edit production workflows directly with AI!**

**Mandatory Safety Process:**
1. ✅ **Copy First**: Always create a copy of the workflow before modifications
2. ✅ **Test Isolated**: Test changes in development environment
3. ✅ **Backup**: Export backups of important workflows
4. ✅ **Validate**: Thoroughly validate all changes before production
5. ✅ **Manual Review**: Review AI-generated configurations manually

**Production Deployment Workflow:**
```
Development → Validation → Testing → Manual Review → Production
```

**Never Skip Steps**: Each safety step prevents potentially catastrophic automation failures.

---

## 3. MCP Tools

### Available Tools (265 AI-capable variants)

**Node Discovery & Search:**
- 1,084 total nodes (537 core + 547 community, 301 verified)
- Search by name, category, verification status, AI capability
- Natural language queries
- 99% property coverage

**Template Access:**
- 2,709 workflow templates with complete metadata
- 2,646 pre-extracted real-world configurations
- Template-based learning and discovery

**Workflow Management:**
- Create workflows programmatically
- Update existing workflows safely
- Execute workflows and monitor results
- Manage credentials securely
- Configure webhooks and triggers

**Configuration Validation:**
- 4 validation profiles: minimal, runtime, ai-friendly, strict
- Pre-build and post-build validation
- Expression syntax testing
- Property dependency checks
- Auto-sanitization detection

### Example Tool Usage

```
"Find nodes for Slack integration"
"Show me webhook to email workflow templates"
"Validate the Payment Processing workflow"
"What AI nodes are available?"
```

---

## 4. Skills System

### The 7 Skills (Auto-Activating)

| # | Skill | Activates When | Prevents |
|---|-------|----------------|----------|
| 1 | **Expression Syntax** | Writing `{{}}` expressions, using `$json`/`$node` | Incorrect variable access, webhook data errors |
| 2 | **MCP Tools Expert** ⭐ | Searching nodes, validating configs | Tool misuse, wrong nodeType format |
| 3 | **Workflow Patterns** | Creating workflows, connecting nodes | Poor architecture, unreliable workflows |
| 4 | **Validation Expert** | Validation failures, debugging errors | Validation loops, false positive confusion |
| 5 | **Node Configuration** | Configuring nodes, setting dependencies | Missing properties, dependency errors |
| 6 | **Code JavaScript** | Writing JavaScript in Code nodes | 62%+ of Code node failures |
| 7 | **Code Python** | Writing Python (rare - use JS 95% of time) | Unsupported library usage |

### Skill Synergy Example

**Request:** "Build and validate a webhook to Slack workflow"

**Skills Activate in Sequence:**
1. **Workflow Patterns** → Identifies webhook-based automation architecture
2. **MCP Tools Expert** → Searches for Webhook and Slack nodes
3. **Node Configuration** → Guides webhook trigger and Slack message setup
4. **Code JavaScript** → Handles webhook data processing (`$json.body`)
5. **Expression Syntax** → Manages data mapping between nodes
6. **Validation Expert** → Confirms correctness, catches errors

---

## 5. Workflow Building Process

### Step-by-Step Workflow Creation

**1. Define Requirements**
- Workflow purpose and goals
- Input sources (webhook, schedule, manual, event)
- Required integrations and services
- Expected outputs and actions

**2. Select Pattern** (choose one of 5 proven patterns)
- Data Transformation Pipeline
- Webhook-Based Automation
- Scheduled Data Sync
- Error Handling Pattern
- Event-Driven Integration

**3. Node Discovery**
- Use MCP tools to search for required nodes
- Check node documentation and properties
- Review template examples

**4. Build Workflow**
- Create workflow structure following pattern
- Configure each node with proper settings
- Add error handling at critical points
- Implement data validation

**5. Validation**
- Use ai-friendly validation profile during development
- Test expressions and data access patterns
- Verify property dependencies
- Check for auto-sanitization warnings

**6. Testing**
- Execute workflow with test data
- Monitor execution results
- Debug any issues
- Optimize performance

**7. Production Deployment**
- Export from development
- Review manually
- Import to production
- Final validation with strict profile

---

## 6. Quality Standards

### Workflow Quality Checklist

**Node Naming:**
- ✅ Use descriptive names (e.g., "Fetch Customer Data" not "HTTP Request")
- ✅ Indicate purpose clearly
- ✅ Use consistent naming conventions

**Error Handling:**
- ✅ Add Error Trigger nodes for critical workflows
- ✅ Log errors appropriately
- ✅ Implement retry logic where needed
- ✅ Send notifications for failures

**Security:**
- ✅ Store credentials in n8n's credential system (never hardcode)
- ✅ Validate all external inputs
- ✅ Sanitize data before use
- ✅ Use environment variables for configuration

**Performance:**
- ✅ Minimize HTTP requests
- ✅ Use batch operations when available
- ✅ Implement pagination for large datasets
- ✅ Prefer webhooks over polling

**Code Quality (Code Nodes):**
- ✅ Use JavaScript (95% of cases, Python lacks external libraries)
- ✅ Return correct format: `[{json: {...}}]`
- ✅ Use proper data access: `$input.all()`, `$input.first()`, `$input.item`
- ✅ Use built-in helpers: `$helpers.httpRequest()`, DateTime
- ✅ Add comments for complex logic

**Validation:**
- ✅ Use ai-friendly profile during development
- ✅ Use strict profile before production
- ✅ Address all validation errors (not just warnings)
- ✅ Understand auto-sanitization vs real errors

---

## 7. Workflow Patterns

### The 5 Proven Patterns

**1. Data Transformation Pipeline**
```
Trigger → Fetch Data → Transform Data → Validate → Store/Send → Done
```
**Use for:** ETL processes, data migration, report generation

**2. Webhook-Based Automation**
```
Webhook → Parse Payload → Conditional Logic → Execute Actions → Respond
```
**Use for:** Real-time integrations, event processing, API endpoints

**3. Scheduled Data Sync**
```
Schedule Trigger → Fetch Source → Compare/Diff → Update Destination → Log Results
```
**Use for:** Periodic syncs, scheduled reports, maintenance tasks

**4. Error Handling Pattern**
```
Main Workflow → [On Error] → Error Trigger → Log Error → Notify Admin → Retry Logic
```
**Use for:** Critical workflows requiring reliability

**5. Event-Driven Integration**
```
Event Trigger → Validate Event → Transform → Route by Type → Execute Actions → Confirm
```
**Use for:** Multi-system integrations, complex event processing

---

## 8. Expression Syntax

### Core Expression Variables

```javascript
$json           // Current node's output data
$json.body      // Webhook data (CRITICAL: always at .body)
$node           // Access data from specific node
$input          // Access input data (Code nodes)
$now            // Current timestamp
$env            // Environment variables
```

### Common Expression Patterns

**Access Webhook Data:**
```javascript
{{ $json.body.email }}              // Correct
{{ $json.email }}                   // ❌ Wrong - webhook data is at .body
```

**Access Previous Node Data:**
```javascript
{{ $node["HTTP Request"].json.result }}
```

**Use JMESPath for Complex Data:**
```javascript
{{ $jmespath($json.body, "users[?age > 25].name") }}
```

**Date/Time Operations:**
```javascript
{{ $now.toISO() }}
{{ $now.plus({days: 7}).toFormat('yyyy-MM-dd') }}
```

### Expression Rules

- ✅ Use `{{}}` syntax for expressions
- ✅ Access webhook data at `$json.body`
- ✅ Use `$jmespath()` for complex queries
- ❌ Don't use expressions in Code nodes (use JavaScript directly)
- ❌ Don't forget `.body` for webhook data

---

## 9. Common Mistakes

### Critical Gotchas (Cause 62%+ of Failures)

| Issue | ❌ Wrong | ✅ Correct | Skill That Prevents |
|-------|---------|----------|---------------------|
| **Webhook Data** | `$json.email` | `$json.body.email` | Expression Syntax, Code JavaScript |
| **Code Return Format** | `return data` | `return [{json: {...}}]` | Code JavaScript |
| **Python Libraries** | `import requests` | Use JavaScript instead | Code Python |
| **Node Type Format** | `n8n-nodes-base.slack` | `nodes-base.slack` | MCP Tools Expert |
| **Data Access (Code)** | `items[0]` | `$input.first()` or `$input.all()` | Code JavaScript |
| **Expression in Code** | Using `{{ }}` in Code node | Direct JavaScript | Expression Syntax |
| **Missing Dependencies** | Set `sendBody` without `contentType` | Set both properties | Node Configuration |
| **Validation False Positives** | Treating auto-fixes as errors | Understand auto-sanitization | Validation Expert |

### Debugging Checklist

**Workflow Not Executing:**
- ✅ Check trigger configuration
- ✅ Verify webhook URL (if webhook trigger)
- ✅ Check credentials
- ✅ Review node connections

**Data Not Flowing:**
- ✅ Verify webhook data at `$json.body`
- ✅ Check expression syntax
- ✅ Review Code node return format
- ✅ Validate data transformations

**Validation Errors:**
- ✅ Use correct validation profile (ai-friendly for development)
- ✅ Check property dependencies
- ✅ Distinguish auto-sanitization from real errors
- ✅ Verify nodeType format

**Code Node Errors:**
- ✅ Use JavaScript (not Python) for 95% of cases
- ✅ Return `[{json: {...}}]` format
- ✅ Access data with `$input.all()` or `$input.first()`
- ✅ Use `$helpers.httpRequest()` for HTTP calls
- ✅ Remember webhook data at `$json.body`

---

## 10. Validation Profiles

| Profile | When to Use | Strictness | Coverage |
|---------|-------------|------------|----------|
| **minimal** | Quick prototyping, exploring ideas | Lowest | Basic checks only |
| **runtime** | Development and testing | Medium | Full schema (63.6% operations) |
| **ai-friendly** | Working with Claude (recommended) | Medium (relaxed) | LLM-optimized |
| **strict** | Pre-production, critical workflows | Highest | Maximum rigor |

**Recommendation:** Use `ai-friendly` during development, `strict` before production deployment.

---

## Quick Reference

### Environment Variables
```bash
MCP_MODE=stdio
LOG_LEVEL=error
DISABLE_CONSOLE_OUTPUT=true
N8N_API_URL=https://your-instance.com
N8N_API_KEY=your-api-key
```

### Key Reminders
- Webhook data is at `$json.body` (not `$json`)
- Code nodes return `[{json: {...}}]` format
- Use JavaScript (95% of cases, Python lacks libraries)
- Always copy workflows before editing
- Validate with `ai-friendly` during dev, `strict` before production

### Resources
- [n8n-mcp GitHub](https://github.com/czlonkowski/n8n-mcp)
- [n8n-skills GitHub](https://github.com/czlonkowski/n8n-skills)
- [n8n Documentation](https://docs.n8n.io/)

---

**Ready to build workflows?** Configure the environment above, then ask Claude to help create your first workflow. The skills will activate automatically and guide you through the process.
