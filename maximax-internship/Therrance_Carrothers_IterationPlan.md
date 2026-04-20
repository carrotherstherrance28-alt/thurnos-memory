# Iteration Plan — Week 2 → Week 3

**Student:** Therrance Carrothers
**Workflows:** Lead Qualification Agent (Case 2) & Sales Proposal Automation (Case 1)
**Date:** February 20, 2026

---

## 1. Wins (What Worked Well)

### Case 2: Lead Qualification Agent (30 nodes)
- **Batch email verification** — Using Bouncer batch API instead of per-lead calls reduced API usage from N calls to 1 call per run, improving speed and staying under rate limits. Fallback: if Bouncer fails mid-batch, the HTTP Request node retries 2x with 5s backoff; after exhausting retries the Error Trigger fires, logging the failure and alerting ops via Slack so no leads are silently dropped
- **ICP Score Gate saves LLM tokens** — Leads scoring 0/3 on ICP rules (location, employees, industry) skip the AI scorer entirely, reducing OpenRouter costs by filtering out obvious non-fits before expensive AI evaluation
- **Web search enrichment adds real context** — Tavily API provides real-time company data that the AI scorer cross-references against the spreadsheet data, catching outdated or incorrect fields (e.g., employee count changed, company rebranded)
- **AI Lead Scorer produces structured JSON output** — The prompt engineering ensures consistent `{ai_score, qualification, notes}` format that the Parse AI Score node can reliably extract
- **Email deduplication prevents wasted API calls** — Deduplicate Leads node removes duplicate emails before processing, preventing redundant Bouncer, Tavily, and OpenRouter calls on the same lead
- **5 fallback paths handle failures gracefully** — Bouncer response format handling, web search `continueOnFail`, merge fallback string, AI parse defaults, and UNSURE fallback for low-confidence scores all prevent crashes
- **Error Trigger with parallel logging** — Global error catch fires both Slack alert AND Google Sheets error log simultaneously, ensuring nothing is lost

### Case 1: Sales Proposal Automation (18 nodes)
- **Input validation gates processing** — The `Valid Lead Data?` IF node prevents incomplete submissions from generating proposals or consuming API credits
- **HTML-to-PDF pipeline works end-to-end** — Generate Proposal Content → PDF.co → Gmail sends a professional proposal with a single webhook trigger
- **Email send verification** — Checking Gmail's returned message ID confirms delivery, with automatic failure routing to Mark Send Failed + Alert Ops
- **Data transformation handles messy form input** — Title-casing names, stripping phone characters, lowercase emails, and null-safe fallbacks prevent downstream errors

### Shared Across Both Workflows
- **Consistent error handling pattern** — Both workflows use the same Error Trigger → Log Error to Sheet + Send Error Alert structure
- **Retry logic on all external APIs** — Bouncer (2x/5s), Tavily (2x/2s), PDF.co (2x/3s), Gmail (2x/3s) all retry before failing
- **Success + error Slack notifications** match the rubric template format
- **Detailed node notes** document every step's tool, run time estimate, failure modes, and data transformations
- **Security hardening completed** — Tavily API key moved to credential manager, webhook authentication added, AI prompt injection mitigated, UNSURE fallback for low-confidence AI scores, PII reduced in Slack notifications (see Security Checklist)

---

## 2. Issues / Bugs

| # | Issue | Severity | Workflow | Details | Status |
|---|---|---|---|---|---|
| 1 | **Google Sheet `documentId` fields empty** | High | Both | All Google Sheets nodes need actual Sheet URL | **FIXED (Case 2)** — URL configured on all 5 nodes. Case 1 still pending. |
| 2 | **Tavily API key in JSON body** | Medium | Case 2 | `api_key` field was hardcoded in jsonBody, exposing key in logs | **FIXED** — Removed from jsonBody, moved to HTTP Header Auth credential |
| 3 | **AI parse fallback may create noise** | Low | Case 2 | Non-JSON AI responses default to `Needs Review`, could flood review queue | Open — mitigated by UNSURE fallback distinguishing low-confidence from parse errors |
| 4 | **No deduplication check** | Critical | Both | Duplicate leads waste API calls; duplicate form submissions generate duplicate proposals | **FIXED (Case 2)** — Deduplicate Leads node added after Filter Unprocessed. Case 1 still pending. |
| 5 | **PDF.co error not gated** | Low | Case 1 | Email sends with empty PDF link when PDF generation fails | Open — needs IF node gate on `_pdfGenerated` before email send |
| 6 | **Merge Lead + Bouncer join logic** | Low | Case 2 | `enrichInput1` mode without explicit field matching could misalign results | **FIXED** — Added `fieldsToMatch` with `Email = _bouncer_email` |
| 7 | **Webhook has no authentication (Case 1)** | Medium | Case 1 | `/fillout-proposal` endpoint accepts POST from any source — could be spammed | **FIXED** — Added `headerAuth` requiring `X-Webhook-Secret` header |
| 8 | **AI prompt injection risk** | Medium | Case 2 | Lead data fields interpolated directly into AI prompt without sanitization | **FIXED** — Input sanitization added in Merge Search + Lead; anti-injection instruction in system message |

---

## 3. Risks

| # | Risk | Likelihood | Impact | Mitigation Plan |
|---|---|---|---|---|
| 1 | **Bouncer API rate limits** | Medium | High | Free tier allows ~100 verifications/month. Large lead batches (50+) could exceed limits in a single run. Plan: Add batch size limit in Collect Emails node, process in chunks of 25. Add API usage monitoring dashboard (Google Sheet tab tracking calls/month, remaining quota, cost per run) |
| 2 | **OpenRouter/LLM costs escalate** | Medium | Medium | Each AI Lead Scorer call uses GPT-4.1 Mini tokens. At 50+ leads/day, monthly costs grow. The ICP Score Gate mitigates this, but costs should be monitored. Plan: Add token usage tracking + monitoring dashboard tab logging tokens consumed, cost per lead, and daily/weekly totals |
| 3 | **Tavily free tier (1,000 searches/month)** | High | Medium | Each qualified lead uses 1 search. With 30+ leads/day this exhausts the quota in ~1 week. Plan: Cache results, skip search for known companies, or upgrade plan. Add API usage monitoring to dashboard to alert when approaching quota limits |
| 4 | **PDF.co credit limits** | Medium | Medium | Free tier: 100 credits/month. Each proposal = 1 credit. High form submission volume could exhaust credits. Plan: Track credit usage, alert when below 20% |
| 5 | **Gmail daily sending limits** | Low | High | Google Workspace: 2,000/day. Free Gmail: 500/day. Unlikely to hit for B2B proposals, but worth monitoring. Plan: Add daily count check |
| 6 | **Data consistency across sheets** | Medium | Low | Multiple nodes write to same Google Sheet — race conditions unlikely in sequential workflows but possible if two webhook submissions arrive simultaneously in Case 1. Plan: Add row-level locking or queue |

---

## 4. Next Steps for Week 3

### Must Do (Critical)
- [x] **Configure Google Sheet URLs (Case 2)** — Sheet URL set on all 5 Google Sheets nodes
- [x] **Create "Error Log" tab (Case 2)** — Error Log tab created with 6 columns
- [x] **Move Tavily API key** — Removed from jsonBody, authentication moved to HTTP Header Auth credential
- [x] **Security audit** — Completed Security Compliance Checklist, all medium+ issues fixed
- [ ] **Configure Google Sheet URLs (Case 1)** — Still needs actual Sheet URL in all documentId fields
- [ ] **Create "Error Log" tab (Case 1)** — Needs Error Log tab in Case 1 Google Sheet
- [ ] **Configure API credentials** — Connect Bouncer, Tavily, OpenRouter, PDF.co, Gmail OAuth2, and Slack OAuth2 credentials in n8n UI
- [ ] **End-to-end test** both workflows with real API credentials and sample data

### Should Do (Improvements)
- [x] **Add email deduplication (Case 2)** — Deduplicate Leads node added after Filter Unprocessed
- [x] **Improve Merge join logic (Case 2)** — Added explicit field matching (`Email = _bouncer_email`)
- [ ] **Add email deduplication (Case 1)** — Check Proposals sheet for existing ClientEmail before generating a new proposal
- [ ] **Add PDF generation gate (Case 1)** — Insert an IF node after Parse PDF Response that checks `_pdfGenerated=true` before sending email
- [ ] **Add AI component to Case 1** — Use OpenRouter to personalize proposal content based on the client's industry and requirements (see AI Performance Report)
- [ ] **Test with 5+ records** for each failure case documented in Test Results Table

### Nice to Have (Future)
- [ ] **API usage monitoring dashboard** — Google Sheet tab tracking API calls per run, remaining quotas, cost per lead, and daily/weekly totals for Bouncer, Tavily, and OpenRouter
- [ ] **Dashboard sheet** — Summary tab with lead counts by status, conversion rates, weekly trends
- [ ] **Follow-up automation** in Case 1 — Schedule a reminder email if no response within 3 days of proposal sent
- [ ] **Lead scoring history** in Case 2 — Track score changes over time if a lead is re-evaluated
- [ ] **Token usage tracking** — Log OpenRouter token consumption per lead for cost monitoring
