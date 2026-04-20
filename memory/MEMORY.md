# Agentic Workflows - Memory

## User Preferences
- **API usage priority: Speed + Cost efficiency** — When building n8n workflows, optimize for faster execution and least cost regarding API usage. Examples: batch API calls instead of per-item, pre-filter before expensive steps (like ICP Score Gate skipping LLM for 0/3 leads), use cheapest capable models, cache results for repeat lookups.

## Project Context
- Therrance Carrothers — intern at Maximax Automation Agency (learning context) AND founder of his own agency "Thurr Solutions" (or "Thurr AI Solutions" — name TBD)
- Real clients belong to Thurr Solutions, NOT Maximax
- Active client: RESTORE-C (Weather Stopper roofing contractor, regional/multi-city)
- n8n instance: https://therrancecarrothers.app.n8n.cloud/
- Case 1: Sales Proposal & Contract Automation (workflow ID: Iar5xzG6KaCj8Gy2, 18 nodes)
- Case 2: Lead Qualification Agent (workflow ID: qG6B8b5kwP5zmJKm, 28 nodes)

## Internship Evaluation — Case 2 (Lead Qualification)
- Status: Eligible to proceed to next stage
- Scores: 5/5 on Business understanding, Process mapping, Solution design, Error handling, AI/LLM, Monitoring, ROI analysis, Communication, Ownership. 4/5 on Workflow design, Build, Documentation. 3/5 on Security and Presentation.
- Key quote: "Therrance approached problems from a consultant perspective, connecting automation design decisions to measurable business outcomes"
- Growth areas: Executive-level storytelling (less technical depth), independent security habit-building
- Next goals: Lead full client project independently in 3 months, advanced certs (n8n, Make Expert)
- Case 2 workflow node count confirmed as 29 (not 28 — updated after adding Log Error to Run Logs node)

## Key Files
- `Therrance_Carrothers_WorkflowDesign.json` — Case 2 JSON export
- `Therrance_Carrothers_Case1_WorkflowDesign.json` — Case 1 JSON export
- `Therrance_Carrothers_TestResults.md` — Error handling test results
- `Therrance_Carrothers_IterationPlan.md` — Week 2→3 iteration plan
- `Therrance_Carrothers_AIPerformanceReport.md` — AI integration report
- `Therrance_Carrothers_Case2_SDB.md` — Case 2 Solution Design Brief
