# Test Results Table - Simulated Failure Cases

**Student:** Therrance Carrothers
**Workflows:** Lead Qualification Agent (Case 2) & Sales Proposal Automation (Case 1)

---

## Case 2: Lead Qualification Agent

| # | Failure Case | How Simulated | Expected Behavior | Actual Result | Error Handling Triggered |
|---|---|---|---|---|---|
| 1 | **Missing Email field** | Remove `Email` column from test row in Google Sheet | Transform & Clean Data sets `Email = ""`, `_emailFormatValid = false`. Collect Emails skips this lead. Merge returns lead without Bouncer data. Strict Email Valid? routes to FALSE → Mark Email Invalid writes "Invalid Email" status to sheet. | Lead marked "Invalid Email" in sheet, workflow continues processing remaining leads. No crash. | Filter node passes (Status empty), Transform handles null with `(data.Email \|\| '').trim()`, IF node routes to false branch |
| 2 | **Bouncer API returns 500** | Use invalid API key or mock 500 response in Batch Bouncer node | HTTP Request retries 2x with 5s delay. After 2 failures, Error Trigger fires → Log Error to Sheet stores error details + original input → Send Error Alert posts to #ops-alerts with Run ID, Timestamp, Error Type. | Error logged to "Error Log" sheet tab. Slack #ops-alerts receives formatted error notification. Workflow stops gracefully. | Retry logic (2 retries, 5s backoff), Error Trigger → Log Error to Sheet + Send Error Alert |
| 3 | **AI returns empty/non-JSON response** | Set OpenRouter API key to invalid value or prompt that returns plain text | AI Lead Scorer returns non-JSON text. Parse AI Score catches regex match failure → defaults `aiScore = 0`, `qualification = 'Needs Review'`, `notes = 'AI parsing error: ...'`. Lead is written to sheet with Status = "Needs Review". | Lead saved with Status="Needs Review", AI_Notes contains truncated AI output for manual review. Workflow continues to next lead in loop. | Parse AI Score try/catch with fallback defaults, loop continues |

---

## Case 1: Sales Proposal & Contract Automation

| # | Failure Case | How Simulated | Expected Behavior | Actual Result | Error Handling Triggered |
|---|---|---|---|---|---|
| 1 | **Missing client name in form submission** | POST to webhook with `{"email": "test@example.com"}` (no name field) | Transform & Clean Data sets `ClientName = ""`, `_nameValid = false`. Valid Lead Data? routes to FALSE → Log Validation Failure writes "Validation Failed - Missing Data" to Proposals sheet. | Incomplete submission logged to sheet with Status="Validation Failed - Missing Data". No proposal generated. No crash. | Transform handles null with `titleCase(body.clientName \|\| body.name \|\| '')`, IF node routes to false branch |
| 2 | **Invalid email format** | POST with `{"name": "John", "email": "not-an-email"}` | Transform & Clean Data regex test fails → `_emailValid = false`. Valid Lead Data? routes to FALSE → Log Validation Failure. | Submission rejected, logged as "Validation Failed - Missing Data". No proposal sent to invalid address. | Email regex validation in Code node, IF node gates processing |
| 3 | **PDF.co API timeout** | Set PDF.co API key to invalid value or disconnect network | HTTP Request retries 2x with 3s delay. After 2 failures, Error Trigger fires → Log Error to Sheet stores error + original input → Send Error Alert posts to #ops-alerts. | Error logged to "Error Log" tab. Slack #ops-alerts receives error notification with workflow name, run ID, timestamp, error type. | Retry logic (2 retries, 3s backoff), Error Trigger → Log Error to Sheet + Send Error Alert |

---

## Notification Templates Implemented

### Error Notification (Slack #ops-alerts)
```
:rotating_light: Workflow Error Alert

Workflow: {{workflow_name}}
Run ID: {{execution.id}}
Time: {{execution.startedAt}}
Error Type: {{execution.error.message}}
```

### Success Notification (Slack)
```
:white_check_mark: Workflow Run Successful

Records processed: {{count}}
Time: {{timestamp}}
```

---

## Error Handling Summary

| Feature | Case 2 | Case 1 |
|---|---|---|
| Error Trigger (global catch) | Yes | Yes |
| Store error to sheet | Yes (Error Log tab) | Yes (Error Log tab) |
| Store original input | Yes (JSON substring) | Yes (JSON substring) |
| Notify team on error | Yes (#ops-alerts) | Yes (#ops-alerts) |
| Continue gracefully | Yes (fallback defaults) | Yes (validation gates) |
| Retry logic | Bouncer 2x/5s, Tavily 2x/2s | PDF.co 2x/3s, Gmail 2x/3s |
| Fallback paths | 4 fallbacks (see below) | 3 fallbacks (see below) |
| Success notification | Yes (#sales-leads) | Yes (#sales-proposals) |
| Error notification template | Matches rubric format | Matches rubric format |

### Case 2 Fallback Paths
1. **Parse Batch Results** - Handles multiple Bouncer response formats (array, {results}, {data}, single object)
2. **Web Search Enrichment** - `continueOnFail=true`, AI works without web data
3. **Merge Search + Lead** - Falls back to "No web data available" string
4. **Parse AI Score** - Defaults to "Needs Review" if AI response is non-JSON

### Case 1 Fallback Paths
1. **Valid Lead Data?** - Routes invalid submissions to Log Validation Failure (skip record)
2. **Email Sent Successfully?** - Routes failed sends to Mark Send Failed + Alert Ops (manual review)
3. **Parse PDF Response** - Sets `_pdfGenerated=false` if PDF.co returns error
