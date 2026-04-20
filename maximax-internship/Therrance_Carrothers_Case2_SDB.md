### SOLUTION DESIGN BRIEF (SDB)

**Case Title:** Case 2 – Lead Qualification Agent
**AI Automation Specialist Name:** Therrance Carrothers
**Date:** 02/11/2026

---

#### 1. Problem Statement (2–3 sentences)

The current lead qualification process is entirely manual — sales reps review each incoming lead one by one, research the company online, check if it fits the ideal customer profile, and decide whether to pursue or reject. This is time-consuming (5+ minutes per lead), inconsistent across reps, and relies on stale CRM data that may not reflect a company's current size, industry, or status. Leads sit unqualified for days, causing missed opportunities and wasted outreach on bad-fit prospects.

---

#### 2. Current State Analysis (As‑Is Workflow)

(Reference: Miro As‑Is board link)

- New leads are added to a spreadsheet manually or via form submissions.
- A sales rep opens each lead row and manually checks the email address for typos or obvious issues.
- The rep Googles the company to verify industry, size, and location.
- The rep mentally compares the lead against the ideal customer profile (USA, telecom, 50+ employees).
- Based on gut feel and whatever information they found, the rep marks the lead as "Qualified," "Not Qualified," or leaves it for later.
- Qualified leads are manually forwarded to the sales team via email or Slack message.
- There is no centralized scoring, no audit trail of why a lead was qualified or rejected, and no automated follow-up for borderline leads.

---

#### 3. Proposed Solution Overview (High‑Level Only)

The proposed solution runs on a daily schedule, automatically reading new leads from a Google Sheet, cleaning and normalizing the data, and running each lead through a multi-stage qualification pipeline. First, email addresses are batch-verified via the Bouncer API to eliminate invalid or risky contacts. Next, a rule-based ICP (Ideal Customer Profile) check scores each lead on three criteria: USA location, 50+ employees, and telecom industry. Leads scoring 0/3 are immediately marked "Not Qualified" without consuming AI resources. Leads scoring 1/3 or higher proceed to web search enrichment via the Tavily API, which fetches real-time company data. An AI agent (GPT-4.1 Mini via OpenRouter) then cross-references the web research with the spreadsheet data to produce a confidence score (1–100) and a final classification. Results are written back to the sheet, and qualified leads trigger an instant Slack notification to the sales team. The objective is to eliminate manual research time, produce consistent and auditable scores, and ensure no qualified lead sits unreviewed for more than 24 hours.

---

#### 4. Tech Stack (Tools You Will Use)

| Component              | Tool                                   |
|------------------------|----------------------------------------|
| Workflow Orchestration | n8n                                    |
| CRM / Database         | Google Sheets                          |
| Email Verification     | Bouncer API (batch verification)       |
| Web Search Enrichment  | Tavily API (real-time company research) |
| AI Scoring             | OpenRouter (GPT-4.1 Mini)              |
| Internal Notifications | Slack                                  |

---

#### 5. Data Flow Diagram (Text Description)

**Overall Flow:**
Schedule → Google Sheets → Bouncer → ICP Rules → Tavily → AI Agent → Google Sheets → Slack

- **Trigger:**
  - Daily schedule trigger fires every 24 hours to process new leads.

- **Inputs:**
  - Email
  - First Name / Last Name
  - Company Name
  - Company Domain
  - Location
  - Employee Count
  - Industry

- **Processing Steps:**
  1. Read all rows from the "Raw Leads" tab in Google Sheets.
  2. Filter to only unprocessed leads (Status column is empty).
  3. Transform and clean data: emails lowercased and trimmed, names title-cased, employee count parsed to integer, email format validated via regex.
  4. Collect all valid-format emails and send a single batch request to the Bouncer API for email verification.
  5. Parse Bouncer results and merge verification data (status, score, reason) back onto each lead.
  6. Strict email gate: only leads with status = "deliverable" AND score >= 90 continue. Failed leads are marked "Invalid Email" in the sheet.
  7. ICP Rule Check scores each lead on three criteria (USA location, 50+ employees, telecom industry) producing a score of 0–3.
  8. ICP Score Gate: leads scoring 0/3 are immediately marked "Not Qualified – Low ICP" and skip the AI step entirely (saves LLM tokens). Leads scoring 1/3+ proceed.
  9. For each qualifying lead, fetch real-time company information via Tavily web search API (top 3 results).
  10. Merge web search context with lead data and pass to the AI Lead Scorer (GPT-4.1 Mini via OpenRouter).
  11. AI produces a JSON response with ai_score (1–100), qualification (Qualified / Needs Review / Not Qualified), and notes (2–3 sentences of reasoning).
  12. Parse AI response, assign final Status, and write results back to Google Sheets (Email, EmailValidation, ICP_Match, ICP_Score, AI_Score, Qualification, AI_Notes, Status).
  13. If Status = "Qualified," send a Slack notification to #sales-leads with full lead details and AI reasoning.

- **Outputs:**
  - Every lead row in Google Sheets updated with email validation, ICP score, AI score, qualification, and status.
  - Slack notification to #sales-leads for each qualified lead.
  - Error log entries in Google Sheets "Error Log" tab for any failures.
  - Slack alert to #ops-alerts for unhandled errors.

---

#### 6. Success Metrics (KPIs)

- Reduction in time from lead arrival to qualification (from days to under 24 hours via daily schedule).
- Elimination of manual company research per lead (from ~5 minutes of Googling to automated web search + AI analysis).
- Consistency of qualification decisions (AI provides auditable scores and reasoning vs. subjective rep judgment).
- Percentage of leads with valid, verified email addresses before outreach (target: 100% of contacted leads pass Bouncer verification).
- LLM cost efficiency via ICP pre-filtering (target: 30–40% of leads skip AI scoring entirely due to 0/3 ICP score).
- Time from qualified lead identification to sales team notification (should be near-instant via Slack).

---

#### 7. Risks & Mitigation

| Risk                                                        | Mitigation                                                                                             |
|-------------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| Bouncer API rate limits on large lead batches (100+)        | Add batch size limits in the Collect Emails node; process in chunks of 25. Monitor usage and alert on low credits. |
| OpenRouter / LLM costs escalate with high lead volume       | ICP Score Gate pre-filters 0/3 leads before AI. Use GPT-4.1 Mini (cheapest capable model). Track token usage per lead. |
| Tavily free tier limits (1,000 searches/month)              | Cache results for known companies. Skip search for repeat leads. Upgrade plan if volume exceeds free tier. |
| AI returns non-JSON or hallucinated scores                  | Parse AI Score node uses regex extraction with fallback defaults (score=0, qualification="Needs Review"). AI parsing errors are flagged in AI_Notes for manual review. |
| Web search returns irrelevant or no results                 | Merge node falls back to "No web data available." AI still scores using table data alone, noting limited confidence in its reasoning. |
| Stale or incorrect data in Google Sheets                    | Web search enrichment cross-references table data. AI prompt instructs "trust web data over table data" when contradictions are found. |

---

#### 8. Questions for Stakeholder

1. How many new leads per day/week are typically added to the spreadsheet?
2. Should the workflow run more frequently than once per day (e.g., every 6 hours) for faster qualification turnaround?
3. Are the current ICP criteria (USA, telecom, 50+ employees) fixed, or should they be configurable per campaign or quarter?
4. For leads classified as "Needs Review" by the AI, who should be notified, and what is the expected manual review process?
5. Should leads marked "Invalid Email" be permanently excluded, or should they be re-verified after a set period in case of temporary email issues?
6. Which Slack channel(s) should receive qualified lead notifications, and should different qualification tiers (e.g., score 70+ vs. 90+) go to different channels?
