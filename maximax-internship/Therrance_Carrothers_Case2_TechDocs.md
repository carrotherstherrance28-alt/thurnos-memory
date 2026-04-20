# Lead Qualification Agent
## AI-Powered Lead Scoring & Verification System
### Technical Documentation

**Author:** Therrance Carrothers
**Version:** 1.0
**Date:** March 4, 2026
**Workflow ID:** qG6B8b5kwP5zmJKm

---

## 1. Overview

The Lead Qualification Agent is an intelligent automation system that processes B2B sales leads end-to-end — from raw contact data to scored, enriched, and routed outcomes — without any manual intervention. The workflow reads unprocessed leads from a Google Sheet on a daily schedule, verifies each email address through the Bouncer API, researches the company using Tavily AI web search, and submits the enriched data to an AI model (via OpenRouter) for qualification scoring against a defined Ideal Customer Profile (ICP).

The system targets **USA-based telecommunications companies with 50 or more employees**. Leads that meet this profile receive an AI score of 1–100 and are routed to the sales team via Slack. Leads with invalid emails or a poor ICP match are automatically marked and excluded from the sales pipeline. All outcomes are written back to the source Google Sheet, and every workflow run is logged to a monitoring dashboard.

**Who uses it:** Sales development representatives and operations teams who need a reliable, daily intake of pre-qualified B2B leads without spending 15–20 minutes per contact on manual research.

**Business impact:** Reduces per-lead qualification time from ~15 minutes to under 2 minutes. Eliminates invalid emails before any outreach occurs. Ensures the sales team only acts on leads that have been cross-referenced against live web data and scored by AI — removing guesswork and improving pipeline accuracy.

---

## 2. Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        LEAD QUALIFICATION AGENT                         │
└─────────────────────────────────────────────────────────────────────────┘

[Daily Schedule]
      │
      ▼
[Read Raw Leads] ──── Google Sheets: "Leads Without Verification"
      │
      ▼
[Filter Unprocessed] ── keeps only rows where status = empty
      │
      ▼
[Deduplicate Leads] ── removes duplicate emails in same batch
      │
      ▼
[Transform & Clean Data] ── normalize email, name, company; validate format
      │
      ▼
[ICP Rule Check] ── score lead: USA? (1pt) + 50+ employees? (1pt) + Telecom? (1pt)
      │
      ▼
[ICP Score Gate]
      │
      ├── FALSE (score = 0/3) ──────────────────────────────────────────┐
      │                                                                  ▼
      │                                                    [Mark Not Qualified]
      │                                                   status = "rejected"
      │                                                          │
      ▼                                                          ▼
[Loop Over Leads] ◄──────────────────────────── [Back to Loop] ◄┘
      │
      ├── output[0]: DONE (all leads processed) ──► [Success Summary]
      │                                                     │
      │                                              [Log API Usage]
      │                                                     │
      │                                         [Send Success Notification]
      │                                           Slack: #sales-leads
      │
      └── output[1]: NEXT ITEM (1 lead at a time)
            │
            ▼
   [Batch Bouncer Validation]
   GET /v1.1/email/verify?email=...   ── Bouncer API
            │
            ▼
   [Parse Batch Results]
   merge bouncer result into lead object
            │
            ▼
   [Strict Email Valid?]
   deliverable = true AND score ≥ 90
            │
            ├── FALSE ──► [Mark Email Invalid]
            │              status = "invalid_email"
            │                    │
            │                    └──────────────────► [Back to Loop]
            │
            └── TRUE
                  │
                  ▼
         [Web Search Enrichment]
         POST https://api.tavily.com/search   ── Tavily API
         query: "{Company} {Industry} company info"
                  │
                  ▼
         [Merge Search + Lead]
         sanitize inputs + embed web context
                  │
                  ▼
         [AI Lead Scorer]                     ── OpenRouter (LangChain Agent)
         system: ICP criteria + anti-injection
         user:   lead data + web research
                  │
                  ▼
         [Parse AI Score]
         extract JSON → validate score (0–100)
         → validate qualification label
         → apply UNSURE fallback
                  │
                  ▼
         [Update Lead Row]
         Google Sheets: update row matched by Email
         writes: status, score, email_validation,
                 icp_score, qualification
                  │
                  ▼
         [Is Qualified?]
         Status == "Qualified"
                  │
                  ├── TRUE ──► [Notify Sales in Slack]
                  │             #sales-leads: name, company,
                  │             AI score, ICP score, notes
                  │                   │
                  │                   ▼
                  └── FALSE ──► [Back to Loop]

─────────────────────────────────────────────────────────────
ERROR HANDLER (runs independently on any workflow error)
─────────────────────────────────────────────────────────────

[Error Trigger]
      │
      ├──► [Send Error Alert] ── Slack: #ops-alerts
      │
      └──► [Log Error to Sheet] ── Google Sheets: "Error Log"
```

**Third-party services used:**
| Service | Purpose | Auth |
|---|---|---|
| Google Sheets | Lead input, result output, error log | OAuth2 |
| Bouncer API | Single email verification | HTTP Header (x-api-key) |
| Tavily API | Company web research | HTTP Header (Authorization: Bearer) |
| OpenRouter | LLM inference (AI scoring) | OpenRouter credential |
| Slack | Qualified lead alerts + error alerts | OAuth2 |

---

## 3. Setup Guide

### 3.1 Required Tools & Accounts

- **n8n** (cloud or self-hosted) — workflow engine
- **Google Account** — for Google Sheets access (OAuth2)
- **Bouncer** — email verification — https://usebouncer.com
- **Tavily** — AI-powered web search — https://tavily.com
- **OpenRouter** — LLM API gateway — https://openrouter.ai
- **Slack** — notifications (workspace admin required for OAuth)

---

### 3.2 Google Sheets Setup

**Sheet 1: Lead Input**
Create a Google Sheet with a tab named exactly: `Leads Without Verification`

Required column headers (row 1):

| First Name | Last Name | Email | Company | company_name | headquarters_location | employee_count | industry | status | score | email_validation | icp_score | qualification |

- The first 8 columns are input data (filled before workflow runs)
- The last 5 columns (`status` through `qualification`) are output — leave them empty. The workflow writes to these.

**Sheet 2: Monitoring Dashboard**
Create a separate Google Sheet with a tab named exactly: `Run Logs`

Required column headers:

| timestamp | status | processing_time_sec | error_type |

**Sheet 3: Error Log** (optional tab in either sheet)
Tab named exactly: `Error Log`

---

### 3.3 API Key Configuration in n8n

Go to **n8n → Credentials** and create the following:

| Credential Name | Type | Fields |
|---|---|---|
| AI Lead Case | Google Sheets OAuth2 | Sign in with Google |
| Bouncer | HTTP Header Auth | Name: `x-api-key` / Value: `<your key>` |
| Tavily API 2 | HTTP Header Auth | Name: `Authorization` / Value: `Bearer <your key>` |
| OpenRouter account | OpenRouter | API Key |
| Slack account 2 | Slack OAuth2 | Sign in with Slack |

> **Important:** The Tavily credential requires the full value `Bearer sk-tavily-...` in the Value field (not just the key).

---

### 3.4 Workflow Import

1. In n8n, go to **Workflows → Import from File**
2. Select `Therrance_Carrothers_WorkflowDesign.json`
3. Open each node that uses a credential and reassign to your configured credentials:
   - All Google Sheets nodes → AI Lead Case
   - Batch Bouncer Validation1 → Bouncer
   - Web Search Enrichment → Tavily API 2
   - OpenRouter Model → OpenRouter account
   - All Slack nodes → Slack account 2
4. Update the Google Sheets document URLs in each node to point to your sheet
5. Save the workflow (keep inactive for now)

---

### 3.5 Test Data

Add this sample lead to `Leads Without Verification` (leave status/score/etc. blank):

| First Name | Last Name | Email | Company | company_name | headquarters_location | employee_count | industry |
|---|---|---|---|---|---|---|---|
| James | Mitchell | j.mitchell@verizonbusiness.com | Verizon Business | verizonbusiness.com | New York, USA | 5000 | Telecommunications |

---

### 3.6 First Run Test

1. With the workflow inactive, click **Test workflow** (manual trigger)
2. Watch execution in real-time
3. Expected result: James Mitchell → `status = Qualified`, `score ≥ 80`
4. Verify row is updated in Google Sheets
5. Verify Slack message appears in `#sales-leads`
6. Verify a row was added to the Run Logs monitoring tab
7. If all pass, activate the workflow for daily automated runs

---

## 4. How It Works (Step-by-Step)

### 4.1 Daily Schedule
**Purpose:** Triggers the workflow automatically once per day.
**Input:** None (time-based trigger)
**Output:** Single item with timestamp metadata
**Configuration:** Every 24 hours. For manual testing, use the "Test workflow" button.

---

### 4.2 Read Raw Leads
**Purpose:** Reads all rows from the lead input sheet.
**Input:** None (reads from Google Sheets)
**Output:** One item per row containing all column values
**Sheet:** `Leads Without Verification`
**Note:** Reads ALL rows including already-processed ones. The next step filters them down.

---

### 4.3 Filter Unprocessed
**Purpose:** Keeps only leads that have not yet been processed.
**Condition:** `status` field is empty
**Output (TRUE only):** Leads with no status — these need processing
**Why this matters:** Prevents re-processing leads the workflow already handled in previous runs.

---

### 4.4 Deduplicate Leads
**Purpose:** Removes duplicate email addresses within the same batch.
**Logic:** Iterates all items; tracks seen emails in a Set; skips any email already seen
**Input:** Array of lead items
**Output:** Unique leads only
**Example:** If the sheet has the same email twice, only the first row proceeds.

---

### 4.5 Transform & Clean Data
**Purpose:** Normalizes all lead fields to a consistent format before scoring.
**Transformations:**
- Email → lowercase, trimmed
- First/Last Name → Title Case
- Company → trimmed
- Employee count → integer (strips commas, text)
- Validates email format with regex
**Output fields added:** `_emailFormatValid`, normalized versions of all input fields

---

### 4.6 ICP Rule Check
**Purpose:** Applies rule-based scoring against the Ideal Customer Profile.
**ICP Criteria:**
| Criterion | Points | Check |
|---|---|---|
| Location: USA | 1 | `headquarters_location` contains "usa" or "united states" |
| Size: 50+ employees | 1 | `employee_count` ≥ 50 |
| Industry: Telecom | 1 | `industry` contains telecom keywords |

**Output fields added:** `ICP_USA`, `ICP_EmployeeCheck`, `ICP_Telecom`, `ICP_Match`, `ICP_Score` (e.g. "3/3"), `_icpScoreNum` (integer)

---

### 4.7 ICP Score Gate
**Purpose:** Routes leads based on ICP score.
**Condition:** `_icpScoreNum` ≥ 1
**TRUE path:** Lead has at least some ICP fit — continue to full AI analysis
**FALSE path:** Score = 0/3 — send directly to Mark Not Qualified (skips expensive API calls)
**Cost optimization:** Leads with zero ICP fit never reach Bouncer, Tavily, or the LLM.

---

### 4.8 Loop Over Leads
**Purpose:** Processes ICP-qualified leads one at a time through the verification and AI pipeline.
**Type:** splitInBatches, v3, batch size = 1
**Output[0]:** Fires when all leads are done → goes to Success Summary
**Output[1]:** Fires with the next single lead → goes to Bouncer verification
**Why one at a time:** Ensures each lead's Bouncer result, Tavily search, and AI score are correctly matched before moving to the next lead.

---

### 4.9 Batch Bouncer Validation
**Purpose:** Verifies whether the lead's email address is deliverable.
**Method:** GET
**URL:** `https://api.usebouncer.com/v1.1/email/verify?email={Email}`
**Auth:** HTTP Header Auth (x-api-key)
**Response fields:**
```json
{
  "email": "j.mitchell@verizonbusiness.com",
  "status": "deliverable",
  "score": 99,
  "reason": "accepted_email"
}
```

---

### 4.10 Parse Batch Results
**Purpose:** Merges the Bouncer response into the lead object.
**Input:** Bouncer API response
**Output:** Full lead object with added fields: `EmailValidation`, `BounceScore`, `EmailReason`
**Source of truth:** Pulls the original lead from `$('Loop Over Leads').first().json` so no data is lost.

---

### 4.11 Strict Email Valid?
**Purpose:** Applies a high-confidence email quality filter.
**Conditions (both must be true):**
- `EmailValidation` equals `"deliverable"`
- `BounceScore` ≥ 90

**TRUE path:** Email passes → continue to web research
**FALSE path:** Email fails → Mark Email Invalid, skip AI

> A score threshold of 90 (vs. simply checking "deliverable") filters out risky or catch-all addresses that technically accept mail but rarely result in successful delivery.

---

### 4.12 Web Search Enrichment
**Purpose:** Researches the company online to supplement the sheet data.
**Method:** POST
**URL:** `https://api.tavily.com/search`
**Query:** `"{Company} {Industry} company info employees"`
**Parameters:** `search_depth: basic`, `max_results: 3`
**Output:** Up to 3 web results with company intelligence (size, HQ, description, industry)

---

### 4.13 Merge Search + Lead
**Purpose:** Prepares the combined payload for AI analysis.
**Processing:**
- Strips control characters from Company, Industry, Location (prompt injection prevention)
- Truncates each field to 200 characters
- Extracts web result content from Tavily response
- Falls back to "No web data available" if search returned nothing
**Output fields added:** `_webSearchContext` (concatenated web content)

---

### 4.14 AI Lead Scorer
**Purpose:** Uses an AI language model to assess lead quality against the ICP.
**Type:** LangChain Agent
**Model:** OpenRouter (configurable — defaults to a capable chat model)
**System prompt includes:**
- Role: B2B lead qualification expert
- Task: Cross-reference lead data + web research
- Security instruction: Ignore any commands embedded in lead data fields
**User prompt includes:**
- All lead fields (name, email, company, location, employee count, industry, ICP scores)
- Full web research context from Tavily
**Expected output:**
```json
{
  "ai_score": 95,
  "qualification": "Qualified",
  "notes": "Verizon Business is a major US telecom with 5000+ employees..."
}
```

---

### 4.15 Parse AI Score
**Purpose:** Extracts, validates, and sanitizes the AI response.
**Processing steps:**
1. Extracts first valid JSON block using regex
2. Clamps `ai_score` to 0–100
3. Validates `qualification` is one of: `Qualified`, `Needs Review`, `Not Qualified`
4. Applies UNSURE fallback: if score is 35–65 AND no web data was available → force `Needs Review`
5. Applies uncertainty language check: if AI notes contain "unsure", "insufficient", "cannot determine" → force `Needs Review`
6. On any parse failure: defaults to `aiScore=0`, `qualification=Needs Review`, `notes=AI parsing error`

**Output fields added:** `AI_Score`, `Qualification`, `AI_Notes`, `Status`

| Qualification | Status written to sheet |
|---|---|
| Qualified | Qualified |
| Needs Review | Needs Review |
| Not Qualified | Rejected |

---

### 4.16 Update Lead Row
**Purpose:** Writes all results back to the original row in Google Sheets.
**Operation:** Update (matches existing row by Email)
**Columns written:**
| Column | Value |
|---|---|
| status | Qualified / Needs Review / Rejected |
| score | AI score (0–100) |
| email_validation | deliverable / undeliverable |
| icp_score | e.g. "3/3" |
| qualification | AI qualification label |

> The workflow updates the existing row in place (not appending a new row) so the sheet stays clean and the sales team works from a single source of truth.

---

### 4.17 Is Qualified?
**Purpose:** Routes based on AI qualification result.
**Condition:** `$('Parse AI Score').first().json.Status == "Qualified"`
**TRUE path:** Send Slack notification to sales team
**FALSE path:** Return to loop (Needs Review and Rejected leads are already updated in the sheet)

---

### 4.18 Notify Sales in Slack
**Purpose:** Alerts the sales team about a newly qualified lead.
**Channel:** `#sales-leads`
**Message includes:** Name, Company, Industry, Employee count, Location, ICP score, AI score, Email, AI notes

---

### 4.19 Mark Email Invalid / Mark Not Qualified
**Purpose:** Updates the sheet for leads that were rejected before AI scoring.
**Mark Email Invalid:** Sets `status = invalid_email` for leads that failed Bouncer (undeliverable or score < 90)
**Mark Not Qualified:** Sets `status = rejected` for leads with ICP score = 0/3 (bypasses all API calls)

---

### 4.20 Success Summary → Log API Usage → Send Success Notification
**Purpose:** Closes out the workflow run with statistics and monitoring.
**Success Summary computes:**
- Total leads read, unique leads, duplicates removed
- Emails verified, ICP passed/skipped
- Tavily searches + OpenRouter calls made
- Estimated API cost (USD)
- Total processing time (seconds)
- Time saved estimate (10 min/lead × total leads)

**Log API Usage:** Appends one row to the Run Logs monitoring dashboard with: `timestamp`, `status`, `processing_time_sec`, `error_type`

**Send Success Notification:** Posts summary to `#sales-leads` Slack channel

---

### 4.21 Error Handler
**Purpose:** Catches any unhandled error in the workflow and alerts the team.
**Trigger:** `Error Trigger` node — fires automatically if any node fails
**Actions (parallel):**
1. Posts error details to `#ops-alerts` Slack channel (error message, node name, execution ID, timestamp)
2. Logs error to the `Error Log` Google Sheet tab (for post-incident analysis)

---

## 5. Troubleshooting Guide

### 5.1 Common Errors

| Issue | Possible Cause | Fix |
|---|---|---|
| `Sheet with name X not found` | Sheet tab name doesn't match exactly | Check tab name — must be exactly `Leads Without Verification` or `Run Logs` (case-sensitive) |
| `header name must be a non-empty string` | Bouncer or Tavily credential has empty Name field | Open the credential in n8n, set Name to `x-api-key` (Bouncer) or `Authorization` (Tavily) |
| `Wrong type: 'X' is a string but was expecting a number` | IF node using strict type validation | Change `typeValidation` to `loose` and wrap expression with `Number()` |
| Loop goes directly to "done" without processing leads | splitInBatches output wiring wrong | output[0] must connect to Success Summary (done path); output[1] must connect to Batch Bouncer (loop path) |
| Update Lead Row writes nothing / appends new row | Google Sheets `columns` structure incorrect | Ensure `matchingColumns` is a sibling of `value` in the `columns` object, not nested inside it |
| AI returns empty or malformed JSON | LLM hallucination or model timeout | Parse AI Score node handles this with fallback — check AI_Notes field for `AI parsing error` |
| `Is Qualified?` sends all leads to FALSE | Reading `$json.Status` after Update Lead Row | Reference `$('Parse AI Score').first().json.Status` instead — Update Lead Row output doesn't carry lead fields |
| Slack notification shows blank fields | Same `$json` issue after Google Sheets node | Use `$('Parse AI Score').first().json.FieldName` for all fields in the Slack message |
| Log API Usage writes 0 rows | Operation defaulted to "read" instead of "append" | Set `operation: append` on the Log API Usage node |
| `Filter Unprocessed` returns 0 leads | All leads already have a status value | Clear the `status`, `score`, `email_validation`, `icp_score`, and `qualification` cells for leads to re-test |

---

### 5.2 What Logs to Check

**n8n Execution Log:**
1. Go to n8n → Executions
2. Click the most recent execution
3. Click any node to see its exact input and output
4. Red nodes indicate errors — check the error message in the node output

**Key nodes to inspect when debugging:**
| Node | What to check |
|---|---|
| Filter Unprocessed | How many items came through (0 = all leads already processed) |
| ICP Score Gate | Which path fired (TRUE = continue, FALSE = rejected) |
| Batch Bouncer Validation | `status` and `score` fields in response |
| Parse AI Score | `AI_Score`, `Status`, `AI_Notes` — check for parsing errors |
| Update Lead Row | Output fields — confirm `status`, `score` etc. are present |
| Log API Usage | Items output (should be 1 row per run; 0 = column mismatch) |

**Google Sheets Error Log tab:**
Contains timestamp, workflow execution ID, error message, and up to 1000 characters of the input payload that caused the failure. Use this for post-run debugging when the execution log is no longer available.

**Slack #ops-alerts:**
Error alerts include the failing node name and execution ID. Use the execution ID to find the exact run in n8n.

---

### 5.3 API Rate Limits

| Service | Limit | Behavior if exceeded |
|---|---|---|
| Bouncer | 1 request/second (single verify endpoint) | HTTP 429 — workflow errors, caught by Error Trigger |
| Tavily | Plan-dependent (check dashboard) | HTTP 429 or empty results |
| OpenRouter | Model-dependent | HTTP 429 — workflow errors, caught by Error Trigger |
| Google Sheets | 100 reads/100 writes per 100 seconds | Rare at this scale; add Wait node if processing 50+ leads/run |

For large batches (50+ leads), add a `Wait` node (1–2 seconds) between the Batch Bouncer node and Parse Batch Results to respect rate limits.

---

### 5.4 When to Escalate

Contact the automation team lead or rebuild from the JSON export if:
- Workflow errors on every run for more than 24 hours despite credential refresh
- AI consistently returns `AI parsing error` on more than 10% of leads (may indicate model deprecation via OpenRouter)
- A lead was incorrectly qualified (false positive) — this warrants a review of the ICP criteria in the ICP Rule Check node and the AI system prompt in AI Lead Scorer
- Google Sheets permissions are revoked (OAuth token expired) — requires re-authorization in n8n credentials
- You need to change the ICP target (different industry, size, or geography) — update the `ICP Rule Check` Code node and the `AI Lead Scorer` system message prompt

---

## Appendix: Key Node Reference

| Node ID | Node Name | Type |
|---|---|---|
| schedule | Daily Schedule | Schedule Trigger |
| readLeads | Read Raw Leads | Google Sheets |
| filterNew | Filter Unprocessed | Filter |
| dedupLeads | Deduplicate Leads | Code |
| transformClean | Transform & Clean Data | Code |
| icpRules | ICP Rule Check | Code |
| icpGate | ICP Score Gate | IF |
| loopLeads | Loop Over Leads | splitInBatches |
| ba999cc0 | Batch Bouncer Validation1 | HTTP Request |
| parseBatch | Parse Batch Results | Code |
| strictEmailValid | Strict Email Valid? | IF |
| d4179625 | Web Search Enrichment | HTTP Request |
| mergeSearchData | Merge Search + Lead | Code |
| aiScoring | AI Lead Scorer | LangChain Agent |
| openRouterModel | OpenRouter Model | LangChain LM |
| parseAiOutput | Parse AI Score | Code |
| updateSheet | Update Lead Row | Google Sheets |
| ifQualified | Is Qualified? | IF |
| slackNotify | Notify Sales in Slack | Slack |
| loopBack | Back to Loop | No-Op |
| markInvalid | Mark Email Invalid | Google Sheets |
| markNotQualified | Mark Not Qualified | Google Sheets |
| successSummary | Success Summary | Code |
| logApiUsage | Log API Usage | Google Sheets |
| successNotify | Send Success Notification | Slack |
| errorTrigger | Error Trigger | Error Trigger |
| errorSlack | Send Error Alert | Slack |
| logErrorSheet | Log Error to Sheet | Google Sheets |

---

*Version 1.0 | Therrance Carrothers | March 4, 2026*
*Lead Qualification Agent — AI Automation Specialist Course*
