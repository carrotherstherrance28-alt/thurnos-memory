# Therrance Carrothers — Portfolio Content
## AI Automation Specialist

---

## PAGE 1 — EXECUTIVE OVERVIEW

### Header
**Therrance Carrothers**
AI Automation Consultant | Business Process Optimization & Intelligent Workflow Systems

---

### Value Proposition
I help startups and SMBs eliminate manual workflows, reduce operational costs, and scale efficiently by designing intelligent AI automation systems aligned with measurable business outcomes.

---

### Who I Am
I specialize in designing scalable automation systems across revenue operations, sales, and business administration. My approach combines business process analysis, ROI estimation, AI integration, and long-term system reliability. Every system I build is designed to deliver measurable results — shorter payback periods, reduced labor costs, and consistent performance without ongoing manual oversight.

---

### Services

**Revenue Operations Automation**
- AI lead qualification and scoring
- CRM data automation
- Sales pipeline dashboards
- Intelligent lead routing systems

**Finance & Admin Automation**
- Sales proposal generation
- Contract workflow automation
- Document processing and delivery
- Client onboarding workflows

**Customer Support Automation**
- AI knowledge assistants
- 24/7 monitoring systems
- Ticket classification and routing
- Automated follow-up sequences

---

### Business Problems I Solve
Businesses typically reach out when they:
- Spend excessive time qualifying leads manually
- Lose deals because proposals take too long to prepare
- Experience inconsistent data entry across CRM and spreadsheets
- Lack visibility into workflow performance and KPIs
- Have disconnected tools that require manual hand-offs between steps

---

### Tech Stack

**Workflow Automation**
n8n, Zapier, Make

**AI & LLM Integration**
OpenAI, OpenRouter, Tavily AI

**CRM & Data**
Google Sheets, Airtable, HubSpot

**APIs & Integrations**
REST APIs, Webhooks, OAuth, HTTP Requests

**Monitoring**
24/7 execution monitoring, error logging, failure alerting

---

### My Approach

**Step 1 — Discovery & Workflow Audit**
- Map the current (As-Is) process
- Identify bottlenecks, delay points, and error-prone steps
- Define KPIs and success metrics
- Estimate ROI and payback period before building anything

**Step 2 — Automation Strategy Design**
- Design the To-Be automated system
- Define integration architecture and data flow
- Address security, credentials, and access controls

**Step 3 — Build & Integration**
- Workflow implementation in n8n
- AI model integration and prompt engineering
- Monitoring setup and error handling

**Step 4 — Testing & Optimization**
- Edge case validation across all workflow paths
- Performance testing under load
- Continuous optimization based on execution data

---

### Measurable Results
- **20+ hours** automated monthly per workflow
- **87% reduction** in manual processing time
- **16–17 day** average payback period
- **2,000%+** ROI on automation investment

---

### Security & Compliance
- Secure API authentication via credential management
- Role-based access controls
- Input validation and data sanitization
- 24/7 monitoring with automated error alerting

---

---

## PAGE 2 — PROJECTS

---

### PROJECT 1

**AI-Powered Lead Qualification & Scoring System**

**Industry & Focus Area**
B2B Sales | Telecom | Revenue Operations | Cost Reduction

---

**Business Problem**

A B2B sales team was manually qualifying every incoming lead — verifying email addresses, researching companies on LinkedIn and Google, scoring leads against ICP criteria, and updating a tracking spreadsheet by hand. Each lead took 15 minutes to process. At 100 leads per month, the team was spending 25 hours per month on data entry and research instead of selling.

Beyond the time cost, the process had no consistency controls. Different SDRs applied ICP criteria differently, invalid email addresses regularly reached outreach and damaged domain reputation, and there was no audit trail for any qualification decision.

---

**Business Analysis (As-Is)**

The manual process consisted of five sequential steps performed entirely by hand:

1. Email verification using a manual deliverability check — no defined pass/fail threshold, SDRs made judgment calls
2. Company research on LinkedIn and Google — depth and accuracy varied by available time
3. ICP classification check against three criteria (US-based, 50+ employees, telecom industry) — fully subjective, undocumented
4. ICP scoring — no standardized scale, inconsistent across team members
5. Spreadsheet update — copy-paste errors, inconsistent column naming, no version control

Total time: 15 minutes per lead. Total monthly cost: $875 in direct labor. Invalid email rate reaching outreach: 15–20%.

---

**Solution Designed**

I designed a 29-node AI-powered pipeline that runs daily and processes leads automatically from end to end. The system scans the lead tracking spreadsheet for unprocessed entries, runs each lead through email validation, web research, and AI scoring, then writes results back with a full audit trail and notifies the sales team instantly for qualified leads.

Key design decisions:
- An ICP pre-filter gate eliminates API costs for leads that score 0/3 on basic criteria before any paid calls are made
- Email validation uses a 90+ confidence threshold to protect domain reputation
- AI scoring incorporates live web research alongside structured data, so the model can correct for outdated or missing information in the spreadsheet
- Error handling runs in parallel — Slack alert, error log, and monitoring dashboard row — so no failure goes undetected

---

**Tools Used**
n8n (workflow orchestration), Bouncer.io (email validation), Tavily AI (web research), OpenRouter (LLM scoring), Google Sheets (data persistence), Slack (notifications)

---

**Results & Impact**

| Metric | Before | After | Change |
|---|---|---|---|
| Time per lead | 15 minutes | 2 minutes | −87% |
| Leads processed per hour | 4 | 30 | +650% |
| Invalid emails in outreach | 15–20% | <2% | −90% |
| Cost per lead | $8.75 | $1.17 | −87% |
| SDR hours/month on qualification | 25 hours | 3 hours | −88% |
| Sales alert time (qualified lead) | Same/next day | Under 2 minutes | −99% |
| Monthly Net Benefit | — | $1,280/month | — |
| Payback Period | — | 16 days | — |
| 12-Month ROI | — | 2,094% | — |
| Net Present Value | — | $13,700+ | — |

---

**Tags**
B2B Sales | Revenue Operations | Lead Qualification | AI Integration | Cost Reduction | Process Optimization | Google Sheets | n8n

---

---

### PROJECT 2

**Automated Sales Proposal & Contract Delivery System**

**Industry & Focus Area**
Home Services | Roofing | Sales Acceleration | Revenue Operations

---

**Business Problem**

A regional roofing contractor was manually creating sales proposals and contracts for every new client inquiry. Sales staff copied client information from intake forms into document templates by hand, formatted pricing, and emailed the final documents manually. During peak season, with 15–20 active inquiries per week, the process created delays and introduced copy-paste errors that required correction before contracts could be signed.

Proposal turnaround took 24–48 hours. Every hour of delay increased the risk of losing the client to a competitor who responded faster.

---

**Business Analysis (As-Is)**

The manual process involved four steps:

1. Sales rep receives client inquiry with job details and contact information
2. Rep manually copies data into a proposal template — roof type, square footage, pricing, client name, address
3. Rep calculates pricing and formats the document
4. Rep emails the proposal and follows up manually to confirm receipt

Every step was prone to human error. Pricing miscalculations, wrong client names on contracts, and delayed delivery were recurring issues during busy periods.

---

**Solution Designed**

I designed an 18-node automated workflow that triggers when a new client inquiry is submitted and delivers a fully populated proposal and contract within minutes — without any manual intervention.

The system extracts all relevant client and job details from the intake form, populates a branded proposal template with pre-filled pricing and terms, generates the contract document, and emails it directly to the client. The sales team receives a notification with the client details and next steps as soon as the documents are delivered.

---

**Tools Used**
n8n (workflow orchestration), Google Sheets (client data), document generation integration, email delivery, Slack (sales team notifications)

---

**Results & Impact**
- Proposal turnaround reduced from 24–48 hours to under 10 minutes
- Copy-paste errors eliminated completely
- Sales team capacity freed from document preparation during peak season
- Client response time improved, reducing loss to faster-responding competitors

---

**Tags**
Home Services | Roofing | Sales Automation | Contract Generation | Document Automation | Revenue Operations | n8n

---

---

## CONTACT SECTION

**Ready to automate your workflows?**

Let's discuss your business process and identify where automation delivers the most value.

[Your Email]
[LinkedIn Profile]
[Schedule a Call — Calendly link]

---

*Therrance Carrothers | AI Automation Consultant*
*Specializing in n8n workflow systems, AI integration, and measurable business outcomes*
