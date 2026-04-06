# n8n Workflow Building Patterns

**Last Updated**: 2026-01-28
**Purpose**: Systematic patterns for building reliable n8n workflows

---

## Build Process Checklist

### Phase 1: Design
- [ ] Define trigger type (schedule, webhook, manual, etc.)
- [ ] List all data sources needed
- [ ] List all outputs/destinations
- [ ] Identify credentials required
- [ ] Sketch the data flow

### Phase 2: Build
- [ ] Create workflow with descriptive name
- [ ] Add trigger node first
- [ ] Build node-by-node, testing each
- [ ] Add error handling
- [ ] Connect to error workflow

### Phase 3: Validate
- [ ] Run validation check
- [ ] Test with real data
- [ ] Verify all credentials connected
- [ ] Check all required fields filled

### Phase 4: Deploy
- [ ] Activate workflow
- [ ] Test production trigger
- [ ] Verify error notifications work

---

## Common Workflow Patterns

### Pattern 1: Form → Process → Store → Notify

**Use case**: Form submissions, invoice processing, lead capture

```
[Trigger] → [Extract Data] → [Process/Transform] → [Store] → [Notify]
```

**Nodes**:
1. Google Sheets Trigger / Webhook
2. Set Node (extract & normalize fields)
3. HTTP Request / Code (external processing)
4. Airtable / Google Sheets (storage)
5. Slack / Email (notification)

**Example**: Invoice Processing workflow

---

### Pattern 2: Schedule → Fetch → Analyze → Report

**Use case**: Weekly reports, data aggregation, monitoring

```
[Schedule] → [Fetch Data] → [Process] → [Generate Report] → [Deliver]
```

**Nodes**:
1. Schedule Trigger
2. Google Sheets / API (data source)
3. Code Node (aggregation)
4. HTTP Request (chart generation)
5. AI Agent (analysis)
6. Gmail / Slack (delivery)

**Example**: Weekly Sales Report workflow

---

### Pattern 3: Webhook → Validate → Branch → Actions

**Use case**: API endpoints, chatbots, interactive forms

```
[Webhook] → [Validate] → [IF/Switch] → [Action A]
                                    → [Action B]
                                    → [Action C]
```

**Nodes**:
1. Webhook (receives external request)
2. Set/Code (validate & normalize)
3. IF/Switch (route by condition)
4. Multiple action branches

**Example**: Slack button handler, API router

---

### Pattern 4: Error Handler → Analyze → Notify

**Use case**: Error monitoring, auto-recovery

```
[Error Trigger] → [Extract Info] → [AI Analysis] → [Notify]
```

**Nodes**:
1. Error Trigger (catches workflow failures)
2. Set Node (extract error details)
3. HTTP Request to AI (analysis)
4. Slack (notification with context)

**Example**: Claude Auto-Fixer workflow

---

## Node Configuration Templates

### Slack Message (Block Kit)
```json
{
  "operation": "post",
  "authentication": "oAuth2",
  "select": "channel",
  "channelId": {
    "__rl": true,
    "value": "CHANNEL_ID",
    "mode": "list"
  },
  "messageType": "block",
  "blocksUi": {
    "blocksValues": [
      {"type": "header", "text": {"text": "Title"}},
      {"type": "section", "text": {"text": "=Content with {{ $json.field }}"}},
      {"type": "actions", "elements": [
        {"type": "button", "text": {"text": "Action"}, "style": "primary", "actionId": "action_id"}
      ]}
    ]
  }
}
```

### HTTP Request with API Key
```json
{
  "method": "POST",
  "url": "https://api.example.com/endpoint",
  "authentication": "genericCredentialType",
  "genericAuthType": "httpHeaderAuth",
  "sendBody": true,
  "specifyBody": "json",
  "jsonBody": "={{ JSON.stringify({ key: $json.value }) }}"
}
```

### Google Sheets Trigger
```json
{
  "pollTimes": {"item": [{"mode": "everyMinute"}]},
  "documentId": {
    "__rl": true,
    "value": "SPREADSHEET_ID",
    "mode": "id"
  },
  "sheetName": {
    "__rl": true,
    "value": "gid=SHEET_GID",
    "mode": "id"
  },
  "event": "rowAdded"
}
```

### Airtable Create Record
```json
{
  "operation": "create",
  "base": {
    "__rl": true,
    "mode": "id",
    "value": "BASE_ID"
  },
  "table": {
    "__rl": true,
    "mode": "id",
    "value": "TABLE_ID"
  },
  "columns": {
    "mappingMode": "defineBelow",
    "value": {
      "Field Name": "={{ $json.fieldValue }}"
    }
  }
}
```

---

## Data Flow Best Practices

### Naming Conventions
- Nodes: Action-based names (`Extract Invoice Data`, `Send Slack Alert`)
- Variables: camelCase (`invoiceNumber`, `totalAmount`)
- Workflows: Descriptive (`Invoice Processing - Google Forms`)

### Data Normalization
Always normalize data early in the workflow:
```javascript
// Good: Normalize at extract step
{
  "firstName": $json['First Name'] || $json.firstName || '',
  "amount": parseFloat($json.Amount.replace(/[$,]/g, '')) || 0
}
```

### Error Handling
Add fallback values for optional fields:
```javascript
// Use || for defaults
{{ $json.companyName || 'N/A' }}

// Check existence before accessing nested
{{ $json.response && $json.response.data ? $json.response.data.value : 'default' }}
```

---

## Credential Management

### Naming Convention
`[Service] - [Account/Purpose]`

Examples:
- `Google OAuth - Personal Gmail`
- `Slack account 2`
- `Airtable Personal Access Token API`
- `PDF.co API`

### Security Rules
1. Never hardcode API keys in workflows
2. Use credentials for all sensitive data
3. Regenerate keys if shared accidentally
4. Use minimal required scopes

### Current Credentials (Therrance)
| Credential | Service | Status |
|------------|---------|--------|
| Slack account 2 | Slack | Working |
| OpenRouter | AI/LLM | Working |
| PDF.co API | Document parsing | Working |
| Airtable Personal Access Token API | Database | Working |
| Invoice Submission 1 | Google Sheets | Working |

---

## Testing Checklist

### Before Each Test
- [ ] Save workflow
- [ ] Check all credentials connected
- [ ] Verify input data format

### Test Execution
- [ ] Execute trigger node manually
- [ ] Check each node's output
- [ ] Verify final output/destination

### Production Test
- [ ] Activate workflow
- [ ] Trigger via production method (not test)
- [ ] Verify error workflow triggers on failure

---

## Optimization Tips

### Performance
- Use filters early to reduce data volume
- Batch operations when possible
- Use pagination for large datasets

### Reliability
- Add retry on fail for HTTP requests
- Use error outputs for graceful degradation
- Log important events for debugging

### Maintainability
- Use sticky notes to document complex logic
- Group related nodes visually
- Keep workflows focused (one purpose each)
