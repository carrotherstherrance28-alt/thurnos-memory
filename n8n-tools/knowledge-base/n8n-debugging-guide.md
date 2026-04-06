# n8n Workflow Debugging Guide

**Last Updated**: 2026-01-28
**Purpose**: Systematic approach to debugging n8n workflows

---

## Quick Diagnostic Checklist

When a workflow fails, check in this order:

### 1. Is the workflow ACTIVE?
- Inactive workflows won't run automatically
- Check the toggle in top-right of workflow editor

### 2. Check execution mode
- **Manual/Test** = Error workflows WON'T trigger
- **Production** = Error workflows WILL trigger
- Test mode is great for debugging but won't notify you of errors

### 3. Check credentials
- Red/disconnected indicator = credential issue
- Try re-authenticating the credential
- Make sure the correct account has access to the resource

### 4. Check node configuration
- Missing required fields
- Wrong operation selected
- Incorrect data references

---

## Common Error Patterns & Fixes

### Slack Nodes

| Error | Cause | Fix |
|-------|-------|-----|
| "Invalid value for 'operation'" | Missing operation parameter | Add `"operation": "post"` explicitly |
| "Channel not found" | Channel ID not set | Select channel from dropdown |
| "not_authed" | Credential issue | Re-authenticate Slack OAuth2 |

**Rule**: ALWAYS include `operation: "post"` when creating Slack message nodes via API.

---

### Google Sheets

| Error | Cause | Fix |
|-------|-------|-----|
| "Sheet with ID gid=X not found" | Wrong sheet tab ID | Select sheet from dropdown (don't paste ID) |
| "Permission denied" | Credential doesn't have access | Share spreadsheet with the Google account in credential |
| "Document not found" | Wrong spreadsheet ID | Select from dropdown or verify URL |

**Rule**: When sheet errors occur, select the sheet via dropdown - this ensures proper authentication.

---

### HTTP Request / API Calls

| Error | Cause | Fix |
|-------|-------|-----|
| 401 Unauthorized | Bad API key or auth conflict | Check key is valid, don't mix credential + manual headers |
| "No cookie auth credentials" | Credential + headers conflict | Set `authentication: "none"` and use manual headers only |
| 403 Forbidden | Missing permissions | Check API key scopes/permissions |
| 404 Not Found | Wrong endpoint URL | Verify API endpoint |

**Rule**: Don't mix credential-based auth with manual Authorization headers. Use one or the other.

---

### Webhook Nodes

| Error | Cause | Fix |
|-------|-------|-----|
| 404 on production URL | Webhook not registered | Add webhookId, deactivate/reactivate workflow |
| Test URL works, production doesn't | Missing webhookId | Add webhookId property to node |
| Webhook data structure wrong | Test vs production format | Test mode wraps data differently |

**Rule**: Webhooks created via API need `webhookId` property. Always deactivate/reactivate after adding webhooks.

---

### Airtable

| Error | Cause | Fix |
|-------|-------|-----|
| "Table not found" | Wrong table ID or no access | Select table from dropdown |
| "Invalid permissions" | Token missing scopes | Regenerate token with proper scopes |
| "Field not found" | Column name mismatch | Verify column names match exactly |

**Required Airtable Token Scopes**:
- `data.records:read`
- `data.records:write`
- `schema.bases:read`

---

### Expression Errors

| Error | Cause | Fix |
|-------|-------|-----|
| "Cannot read property of undefined" | Previous node data not available | Check node connections, verify data exists |
| Optional chaining `?.` not working | n8n doesn't support `?.` | Use `$json.field \|\| 'default'` instead |
| Expression not evaluating | Missing `=` prefix | Use `={{ expression }}` not `{{ expression }}` |

**Rule**: n8n expressions need `=` prefix when mixing literal text with expressions.

---

## Debugging Strategies

### Strategy 1: Execute Nodes Individually
1. Click on a node
2. Click "Execute node" (play button)
3. Check output data
4. Move to next node

### Strategy 2: Pin Test Data
1. Execute workflow up to problematic node
2. Right-click node → "Pin data"
3. Now you can test downstream nodes with consistent data

### Strategy 3: Add Debug Set Nodes
Insert a Set node to inspect/transform data:
```
Name: DEBUG - Check Data
Operation: Set
Fields:
  - debug_input = {{ JSON.stringify($json) }}
```

### Strategy 4: Check Execution History
1. Go to workflow
2. Click "Executions" tab
3. Click on failed execution
4. See exactly which node failed and why

---

## Pre-Flight Checklist (Before Activating)

Before activating any workflow, verify:

- [ ] All credentials connected (no red indicators)
- [ ] All required fields filled
- [ ] Slack nodes have `operation` set
- [ ] HTTP requests have correct authentication method
- [ ] Webhooks have webhookId (if created via API)
- [ ] Expressions have `=` prefix where needed
- [ ] Error workflow is connected (Settings → Error Workflow)
- [ ] Test execution succeeds

---

## Workflow Validation Commands

Use these MCP tools to validate workflows:

```
# Validate a workflow
n8n_validate_workflow(id="workflow_id")

# Check recent executions
n8n_executions(action="list", workflowId="workflow_id", limit=5)

# Get error details
n8n_executions(action="get", id="execution_id", mode="error")

# Auto-fix common issues
n8n_autofix_workflow(id="workflow_id", applyFixes=true)
```

---

## Node Type Quick Reference

### Triggers
| Type | Use Case |
|------|----------|
| Schedule Trigger | Automated recurring runs |
| Webhook | External HTTP calls |
| Google Sheets Trigger | New rows in spreadsheet |
| Error Trigger | Catch errors from other workflows |

### Processing
| Type | Use Case |
|------|----------|
| Set | Transform/rename data fields |
| Code | Complex JavaScript logic |
| IF | Conditional branching |
| Switch | Multiple conditions |
| Merge | Combine data streams |

### External Services
| Type | Auth Method |
|------|-------------|
| Slack | OAuth2 |
| Gmail | OAuth2 |
| Google Sheets | OAuth2 |
| Airtable | Personal Access Token |
| HTTP Request | Varies (API key, OAuth, Header) |

---

## Error Workflow Setup

Every important workflow should have an error workflow configured:

1. **Settings** (gear icon) → **Error Workflow**
2. Select your error handler (e.g., Claude Auto-Fixer)
3. This only triggers on **production** executions

Your current error workflow: `XFGypgHzRtSfXz0Q` (Claude Auto-Fixer)

---

## Quick Fixes Reference

| Symptom | Likely Fix |
|---------|------------|
| Workflow won't trigger | Activate it (toggle on) |
| No error notifications | Use production mode, not test |
| API returns 401 | Check/regenerate API key |
| Sheet not found | Select from dropdown, not paste ID |
| Slack fails silently | Add `operation: "post"` |
| Expression shows literally | Add `=` prefix |
| Data is undefined | Check node connections |
