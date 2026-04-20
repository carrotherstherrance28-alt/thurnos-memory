# Case 2: Lead Qualification Agent
## Client Presentation Deck
**Presenter:** Therrance Carrothers
**Date:** March 4, 2026
**Automation:** AI-Powered Lead Scoring & Verification System (n8n)

---

## Slide 1 — Problem Statement

### What Was Broken

Every incoming B2B sales lead required a Sales Development Representative to manually complete five separate tasks before the lead could be handed off to the sales team. The SDR had to verify the email address using a deliverability tool, research the company on LinkedIn and Google, check the company size and industry classification, score the lead against ICP criteria using personal judgment, and then update the tracking spreadsheet with the result.

This process took an average of 15 minutes per lead. At 100 leads per month, that added up to approximately 25 hours of SDR time — every single month — spent on research and data entry instead of selling.

### Business Consequences

The manual process created four categories of measurable harm.

First, **cost per lead was $8.75** (15 minutes at $35 per hour), making high-volume lead qualification economically inefficient. Second, **email domain reputation was at risk** — approximately 15 to 20 percent of leads carried invalid or undeliverable email addresses that passed through to outreach anyway, causing bounce rates above the 2 percent threshold that triggers spam filters. Third, **ICP scoring was inconsistent** — different SDRs applied criteria differently depending on workload, experience, and attention, meaning the same company could receive a different score on different days. Fourth, **discovery call time was wasted** — without pre-qualification, SDRs conducted full discovery calls with leads who were never going to convert, losing approximately 45 minutes per unqualified call.

### Why It Matters

Lead qualification speed and accuracy directly impacts pipeline velocity — how fast qualified leads move from first contact to opportunity. Every day a qualified lead sits unscored is a day a competitor could reach that prospect first. Every invalid email that reaches outreach damages the domain reputation that every future email depends on. And every hour an SDR spends on data entry is an hour not spent on the activities that actually generate revenue: conversations, follow-ups, and closing.

The business impact of this problem was quantifiable: $8,750 per month in direct labor cost for qualification alone, plus uncounted losses from missed conversions, wasted calls, and deliverability degradation.

---

## Slide 2 — As-Is Workflow: The Manual Process

### Overview

Before automation, lead qualification was a fully manual, human-dependent process with no consistency controls, no audit trail, and no scalability ceiling — meaning throughput was capped by how many hours the SDR could spend on research.

### Step-by-Step Process

**Step 1 — Email Verification (3 minutes)**
The SDR manually checked each email address using a deliverability tool or by inspection. This step had no defined pass/fail threshold, so SDRs made judgment calls on borderline addresses.

**Step 2 — Company Research (5 minutes)**
The SDR searched LinkedIn, the company website, and Google to confirm the company's industry, size, and geographic location. Results varied based on how much time the SDR invested and what sources they consulted.

**Step 3 — ICP Classification Check (3 minutes)**
The SDR compared the company against the Ideal Customer Profile criteria — US-based, 50 or more employees, telecom industry — and made a pass/fail judgment. No scoring rubric existed. No documentation of reasoning was saved.

**Step 4 — Manual ICP Scoring (2 minutes)**
The SDR assigned a score based on how well the lead matched the ICP. This step was entirely subjective with no standardized scale.

**Step 5 — Spreadsheet Update (2 minutes)**
The SDR manually typed the result, score, and status into the Google Sheet tracking system. This step was the most error-prone due to copy-paste mistakes and inconsistent column naming.

**Total time per lead: 15 minutes**

### Pain Points Summary

| Category | Detail |
|---|---|
| Team Handoffs | SDR to sales — only after full manual review |
| Tools Used | Email verification tool, LinkedIn, Google Search, Google Sheets |
| Manual Actions | All 5 steps require human judgment and data entry |
| Delay Points | Each lead adds 15 min to pipeline; batch of 100 = 2+ full workdays |
| Error Points | Subjective scoring, invalid emails, no audit trail, copy-paste errors |

### The Hidden Cost

The SDR team spent approximately 25 hours per month on qualification tasks at a $35 per hour rate — a direct labor cost of $875 per month just for qualification. But the real cost was the opportunity cost: 25 hours that could have been redirected toward outreach, follow-up, and pipeline management instead of manual data entry.

---

## Slide 3 — Solution Overview

### What the Automation Does

The Lead Qualification Agent is a fully automated n8n workflow that replaces all five manual tasks with a consistent, AI-powered process that runs daily without human intervention. Once a new lead is added to the Google Sheet, the system handles everything automatically — from email verification to AI scoring to sales notification — in under two minutes.

### Automatic Trigger

Every 24 hours, the workflow scans the lead tracking Google Sheet and identifies any rows where the status column is empty, indicating an unprocessed lead. All new leads are pulled into the pipeline simultaneously.

### Processing Steps

**Deduplication and Cleaning**
The system removes duplicate email addresses, standardizes name and company capitalization, validates email format, and normalizes company data before any API calls are made. This prevents wasting API credits on already-processed leads.

**ICP Pre-Filter**
Before running any paid API calls, the workflow scores each lead against three rule-based ICP criteria: US-based location, 50 or more employees, and telecom industry classification. Leads scoring zero out of three are immediately marked as rejected and routed out of the pipeline. This gate eliminates unnecessary API costs for leads that have no chance of qualifying.

**Email Verification via Bouncer API**
Each lead passes through the Bouncer email validation API, which checks deliverability status and assigns a confidence score from 0 to 100. Only emails that are both marked "deliverable" AND score 90 or above continue to the enrichment stage. All others are flagged as invalid and marked in the sheet automatically.

**Company Research via Tavily AI Search**
For leads with valid emails, the workflow calls the Tavily web search API to pull fresh information about the company from publicly available sources. This gives the AI scorer real-world context to work with, rather than relying solely on the data entered in the spreadsheet.

**AI Lead Scoring via OpenRouter**
The lead data and web research context are passed to an AI agent running through OpenRouter. The agent analyzes the full picture — company size, industry fit, location, email quality, and web research findings — and returns a structured JSON output with a score from 1 to 100, a qualification decision (Qualified, Needs Review, or Not Qualified), and a 2–3 sentence explanation of its reasoning.

**Lead Sheet Update**
The workflow writes the AI score, qualification decision, ICP breakdown, and email validation result back to the original Google Sheet row, creating a complete audit trail for every lead decision.

### Final Outputs

**For qualified leads:** The sales team receives an instant Slack notification in the #sales-leads channel with the lead's full profile, ICP score, AI score, and the AI's reasoning notes — everything needed to start a conversation without any additional research.

**For all runs:** A monitoring dashboard log entry is written to track run time, success or failure status, and processing duration for operational visibility.

**For errors:** If any part of the workflow fails, the operations team receives an automatic Slack alert in #ops-alerts with the error message, the node that failed, and the execution ID for investigation.

---

## Slide 4 — Workflow Diagram

### Architecture Overview

The Lead Qualification Agent consists of 29 nodes organized into five distinct processing paths.

```
TRIGGER PATH
─────────────────────────────────────────────────────────
[Daily Schedule] ──► [Read Raw Leads] ──► [Filter Unprocessed]
                                                │
                                         [Deduplicate Leads]
                                                │
                                      [Transform & Clean Data]
                                                │
                                         [ICP Rule Check]
                                                │
                                        [ICP Score Gate]
                                       ┌────────┴────────┐
                                  (score ≥ 1)        (score = 0)
                                       │                  │
                                  [Loop Over         [Mark Not
                                    Leads]            Qualified]
                                       │                  │
                              ─────────┘         [Success Summary]
                             │                          │
                     (loop body)                 [Log API Usage]
                             │                          │
                    ─────────────────────          [Send Success
                   │                    │           Notification]
              (done path)         [Bouncer API]
                   │                    │
          [Success Summary]    [Parse Batch Results]
                                        │
                               [Strict Email Valid?]
                              ┌─────────┴──────────┐
                         (valid)               (invalid)
                              │                    │
                    [Web Search           [Mark Email Invalid]
                     Enrichment]                   │
                              │             [Back to Loop]
                    [Merge Search + Lead]
                              │
                       [AI Lead Scorer]
                       (OpenRouter LLM)
                              │
                      [Parse AI Score]
                              │
                      [Update Lead Row]
                              │
                       [Is Qualified?]
                      ┌───────┴────────┐
                  (yes)            (no)
                      │                │
              [Notify Sales       [Back to Loop]
               in Slack]
                      │
              [Back to Loop]

ERROR PATH
─────────────────────────────────────────────────────────
[Error Trigger] ──►┬── [Send Error Alert (Slack)]
                   ├── [Log Error to Sheet]
                   └── [Log Error to Run Logs]
```

### Tools and Services Involved

| Node | Tool | Purpose |
|---|---|---|
| Daily Schedule | n8n built-in | Triggers workflow every 24 hours |
| Read Raw Leads | Google Sheets API | Reads lead data from spreadsheet |
| Bouncer API | Bouncer.io | Email deliverability verification |
| Web Search Enrichment | Tavily AI | Company web research |
| AI Lead Scorer | OpenRouter + LLM | AI scoring and qualification decision |
| Update Lead Row | Google Sheets API | Writes results back to lead sheet |
| Notify Sales in Slack | Slack API | Sales team qualified lead alert |
| Log API Usage | Google Sheets API | Monitoring dashboard data logging |
| Error Trigger | n8n built-in | Catches all workflow failures |

### Conditional Logic Paths

The workflow has three decision gates that route leads to different outcomes:

1. **ICP Score Gate** — Leads scoring 0/3 on ICP criteria skip the entire API processing chain and are marked rejected immediately, saving cost.
2. **Strict Email Valid?** — Leads with email scores below 90 or status other than "deliverable" are flagged invalid and bypass AI scoring.
3. **Is Qualified?** — Only leads with AI status "Qualified" trigger a Slack sales notification. Needs Review and Not Qualified leads are logged silently.

---

## Slide 5 — Impact and ROI

### Headline Results (12-Month Analysis)

The Lead Qualification Agent was evaluated over a 12-month horizon using conservative, verified inputs. Every number below traces directly to measurable business activity.

**Monthly Net Benefit: $1,240 per month**
This figure combines $700 in direct labor savings (20 hours × $35 per hour), $600 in additional business benefits, minus $60 in monthly operating costs.

**Payback Period: 17 days**
The $700 development investment is fully recovered in the first month of operation. From day 18 onward, the automation runs at pure profit.

**12-Month ROI: 2,026%**
On a $700 investment, the automation generates $14,180 in net profit over 12 months — a return of more than twenty times the initial cost.

**Net Present Value: $13,405**
Calculated at a 10 percent annual discount rate, the present value of all future cash flows exceeds the investment by $13,405.

**FTE Freed: 0.17 employees**
The automation frees up the equivalent of one full workday per week that was previously spent on manual lead research. That capacity is now available for revenue-generating activities.

**Total Cost of Ownership (12 months): $1,420**
This includes the $700 one-time build cost plus $60 per month in API and infrastructure costs — 4.6 percent of monthly gross benefit.

### Financial Summary Table

| Metric | Value |
|---|---|
| Monthly Labor Savings (20 hrs × $35) | $700 |
| Monthly Additional Benefits | $600 |
| Monthly Gross Benefit | $1,300 |
| Monthly Operating Costs (OPEX) | −$60 |
| **Monthly Net Benefit** | **$1,240** |
| Development Investment (CAPEX) | $700 |
| Total Cost of Ownership (12 months) | $1,420 |
| **Payback Period** | **17 days** |
| **Annual ROI** | **2,026%** |
| **Net Present Value** | **$13,405** |

### Before and After Comparison

| KPI | Before Automation | After Automation | Change |
|---|---|---|---|
| Time to qualify one lead | 15 minutes | 2 minutes | −87% |
| Leads qualified per hour | 4 leads | 30 leads | +650% |
| Invalid emails reaching outreach | 15–20% of list | Less than 2% | −90% |
| ICP scoring consistency | Subjective SDR judgment | 100% rule-based + AI | Fully consistent |
| Company research coverage | Varies by SDR effort | 100% every lead | +100% |
| Time to sales alert (qualified lead) | Same day or next day | Under 2 minutes | −99% |
| SDR hours per month on qualification | 25 hours | 3 hours (review only) | −88% |
| Cost per lead (labor only) | $8.75 | $1.17 | −87% |
| Audit trail per lead decision | None | Full record in Google Sheets | New capability |
| Daily processing capacity | 15–20 leads (manual limit) | Unlimited (automated batch) | Scalable |

### Scenario Analysis

Even under pessimistic assumptions — 20 percent fewer hours saved, 20 percent lower additional benefits, and 20 percent higher operating costs — the automation still delivers a 1,560 percent ROI with a 22-day payback period and $10,916 in net profit over 12 months. There is no scenario in which this investment loses money.

| Scenario | Monthly Net Benefit | Payback Period | 12-Month Net Profit | ROI |
|---|---|---|---|---|
| Pessimistic (−20%) | $968 | 22 days | $10,916 | 1,560% |
| Base Case | $1,240 | 17 days | $14,180 | 2,026% |
| Optimistic (+20%) | $1,512 | 14 days | $17,444 | 2,492% |

---

## Key Talking Points
*(Optimized for Notebook LM podcast and study guide generation)*

The Lead Qualification Agent solves a $875-per-month labor problem for a $700 one-time investment that pays back in 17 days.

Manual lead qualification required 15 minutes per lead and produced inconsistent, undocumented results. The automation completes the same process in under 2 minutes with a full audit trail.

The workflow uses four APIs in sequence: Bouncer for email validation, Tavily for company research, OpenRouter for AI scoring, and Google Sheets for data persistence.

The ICP pre-filter gate is the most important cost optimization in the design. It eliminates all API costs for leads that score zero out of three on basic ICP criteria before any paid calls are made.

Email validation at a 90-plus confidence threshold reduces invalid email outreach from 15 to 20 percent of the list down to under 2 percent, protecting domain reputation and reducing future deliverability costs.

The AI scorer uses both structured spreadsheet data and live web research to make qualification decisions, meaning it can correct for outdated or incomplete data in the original lead record.

The monitoring dashboard provides real-time visibility into workflow health, processing time, error frequency, and cumulative time saved — making the business value of the automation visible and measurable on an ongoing basis.

Error handling runs in parallel with three outputs: a Slack alert to operations, a log entry in the Error Log sheet, and a status row in the Run Logs monitoring sheet — so no failure goes undetected.

At 100 leads per month, the automation saves 20 hours of SDR time. As lead volume grows, every additional 100 leads adds another 20 hours of recovered capacity at near-zero marginal cost.

The total cost of ownership over 12 months is $1,420. The total net benefit over 12 months is $14,880. The ratio is more than ten to one.

---

*Version 1.0 | Therrance Carrothers | March 4, 2026*
*Lead Qualification Agent — Client Presentation Deck | AI Automation Specialist Course*
*All financial figures verified against ROI Report v1.2 | Case 2 — n8n Workflow ID: qG6B8b5kwP5zmJKm*
