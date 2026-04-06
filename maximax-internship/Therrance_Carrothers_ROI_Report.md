# Return on Investment Report
## Lead Qualification Agent — AI-Powered Lead Scoring & Verification System

**Author:** Therrance Carrothers
**Date:** March 4, 2026
**Evaluation Period:** 12 months
**Automation:** Case 2 — Lead Qualification Agent (n8n)
**Calculator Status:** ✓ Project is viable

---

## 1. Executive Summary

The Lead Qualification Agent automates the end-to-end process of verifying, researching, and scoring incoming B2B sales leads. This report quantifies the financial return using the ROI Calculator over a 12-month evaluation horizon.

**Bottom line:** The automation recovers its full development cost in **~17 days** and generates a **net present value of $13,405** over 12 months — a return of **2,026%** on a $700 investment.

| Metric | Value |
|---|---|
| Monthly Net Benefit (MNB) | $1,240 |
| Payback Period (PBP) | 0.56 months (~17 days) |
| Return on Investment (ROI) | 2,026% |
| Full-Time Equivalents Freed (FTE) | 0.17 employees |
| Total Cost of Ownership (TCO) | $1,420 |
| Net Present Value (NPV) | $13,405 |
| Project Status | ✓ Viable |

---

## 2. ROI Calculator Inputs

### 2.1 All Input Parameters

| Field | Code | Value | Source |
|---|---|---|---|
| Hours Saved Monthly | HSM | **20 hours** | Calculated — see Section 3 |
| Employee Utilization Rate | UTIL | **0.70** | Provided (70%) |
| Cost per Hour (fully-loaded) | CHR | **$35.00** | Provided |
| Monthly Additional Benefits | MAB | **$600.00** | Provided — see Section 4 |
| Monthly Operational Expenses | OPEX | **$60.00** | Calculated — see Section 5 |
| Initial Implementation Investment | CAPEX | **$700** | Calculated — see Section 6 |
| Evaluation Horizon | n | **12 months** | Provided |
| Annual Discount Rate | DR | **0.10** | Provided (10%) |

---

## 3. Hours Saved per Month (HSM = 20)

### 3.1 Manual Process — Before Automation

| Task | Time |
|---|---|
| Verify email deliverability (manual check or tool) | 3 min |
| Research company on LinkedIn, website, Google | 5 min |
| Check company size, location, industry classification | 3 min |
| Score lead manually against ICP criteria | 2 min |
| Update Google Sheet with result | 2 min |
| **Total per lead** | **15 min** |

### 3.2 Automated Process — After Automation

| Task | Time |
|---|---|
| SDR reviews AI score, ICP breakdown, and notes | 2 min |
| **Total per lead** | **2 min** |

### 3.3 Time Saved Calculation (Guide Formula)

```
HSM = Time saved per cycle × cycles per month × 0.9 ÷ 60
HSM = 13 min × 100 leads × 0.9 ÷ 60
HSM = 1,170 ÷ 60
HSM = 19.5 → 20 hours/month
```

| Variable | Value |
|---|---|
| Time saved per lead (15 min − 2 min review) | 13 min |
| Estimated monthly lead volume | 100 leads |
| Accuracy buffer | × 0.9 |
| **HSM** | **20 hours/month** |

> The 0.9 accuracy buffer accounts for edge cases, re-runs, and exception reviews that slightly reduce real-world savings below the theoretical maximum.

---

## 4. Monthly Additional Benefits (MAB = $600)

MAB captures measurable financial benefits beyond direct labor savings.

| Benefit | Monthly Value | Justification |
|---|---|---|
| Email domain reputation protection | $200 | Sending to invalid/catch-all emails causes bounce rates above 2%, triggering spam filters. Remediation (deliverability tools, re-warming) costs $150–300/month. Bouncer's 90+ score threshold prevents this. |
| Higher lead-to-meeting conversion | $200 | AI-scored, ICP-matched leads convert at 2–3× the rate of unscreened leads. Even a 0.5 additional meeting/month at $400 avg deal value = $200 incremental revenue contribution. |
| Eliminated wasted discovery calls | $200 | Each unqualified discovery call wastes ~45 min of SDR time. Preventing 5 calls/month: 5 × 45 min × $35/hr × 0.70 UTIL = ~$200 recovered. |
| **Total MAB** | **$600** | |

> All three MAB items are directly attributable to specific workflow capabilities: Bouncer validation (reputation), AI ICP scoring (conversion), and pre-qualification routing (call elimination).

---

## 5. Monthly Operating Costs (OPEX = $60)

| Service | Usage (100 leads/month) | Monthly Cost |
|---|---|---|
| Bouncer API | ~100 email verifications | $20.00 |
| Tavily AI Search | ~100 web searches | $15.00 |
| OpenRouter (LLM inference) | ~100 calls × ~$0.002/call | $5.00 |
| n8n Cloud (allocated share) | Shared plan, this workflow's portion | $20.00 |
| **Total OPEX** | | **$60.00/month** |

**Total Cost of Ownership:**
```
TCO = CAPEX + (OPEX × n) = $700 + ($60 × 12) = $1,420
```

---

## 6. Development Investment (CAPEX = $700)

| Phase | Hours | Description |
|---|---|---|
| Requirements & design | 3 hrs | ICP definition, flow mapping, data schema |
| Workflow construction | 10 hrs | All 28 nodes, 3 processing paths |
| Testing & debugging | 5 hrs | End-to-end runs, type errors, API auth |
| Security review | 1 hr | Credential storage, prompt injection, webhook auth |
| Documentation | 1 hr | Technical handoff documentation |
| **Total** | **20 hrs** | |

```
CAPEX = 20 hours × $35/hour (SDR specialist rate) = $700
```

---

## 7. Financial Analysis

### 7.1 Monthly Net Benefit

The calculator formula:
```
MNB = (HSM × CHR) + MAB − OPEX
MNB = (20 × $35) + $600 − $60
MNB = $700 + $600 − $60
MNB = $1,240/month
```

### 7.2 Full-Time Equivalent (FTE)

```
FTE = HSM ÷ (168 hours/month × UTIL)
FTE = 20 ÷ (168 × 0.70)
FTE = 20 ÷ 117.6
FTE = 0.17 employees
```

**Client explanation:** "This automation frees up 0.17 of a full-time SDR — roughly one full day per week — that was previously spent on manual lead research."

### 7.3 Payback Period

```
PBP = CAPEX ÷ MNB
PBP = $700 ÷ $1,240
PBP = 0.56 months ≈ 17 days
```

### 7.4 Return on Investment (12-Month)

```
ROI = (MNB × n − CAPEX) ÷ CAPEX × 100
ROI = ($1,240 × 12 − $700) ÷ $700 × 100
ROI = ($14,880 − $700) ÷ $700 × 100
ROI = $14,180 ÷ $700 × 100
ROI = 2,026%
```

### 7.5 Net Present Value (NPV)

```
Monthly discount rate (r) = 0.10 ÷ 12 = 0.00833

PV Annuity Factor = [1 − (1.00833)^−12] ÷ 0.00833
                  = [1 − 0.9052] ÷ 0.00833
                  = 11.375

PV of Monthly Net Benefits = $1,240 × 11.375 = $14,105

NPV = $14,105 − $700 = $13,405
```

### 7.6 Summary Table

| Metric | Value |
|---|---|
| Monthly Labor Benefit (HSM × CHR) | $700 |
| Monthly Additional Benefits (MAB) | $600 |
| Monthly Gross Benefit | $1,300 |
| Monthly OPEX | −$60 |
| **Monthly Net Benefit (MNB)** | **$1,240** |
| CAPEX | $700 |
| TCO (12 months) | $1,420 |
| FTE Freed | 0.17 |
| **Payback Period (PBP)** | **0.56 months (~17 days)** |
| Annual Net Benefit | $14,880 |
| **ROI (12 months)** | **2,026%** |
| **NPV (12 months @ 10% DR)** | **$13,405** |

### 7.7 Month-by-Month Cash Flow

| Month | Net Cash Flow | Cumulative |
|---|---|---|
| 0 (CAPEX paid) | −$700 | −$700 |
| 1 | +$1,240 | +$540 ✅ Break-even |
| 2 | +$1,240 | +$1,780 |
| 3 | +$1,240 | +$3,020 |
| 6 | +$1,240 | +$6,740 |
| 12 | +$1,240 | +$14,180 |

---

## 8. Break-Even Analysis

| Metric | Value | Meaning |
|---|---|---|
| BE_HSM (break-even hours, if MAB = 0) | 1.71 hrs/month | The automation only needs to save 1.7 hours/month to cover OPEX — it saves 20 |
| Break-even check | $700 ÷ $35 = 20 hrs | At $35/hr, just 20 hours of saved labor = the entire CAPEX recovered in month 1 |

The labor savings alone ($700/month from HSM × CHR) already exceed OPEX ($60/month) by $640/month — the project is justified by labor savings alone, before counting any of the $600 in additional benefits.

---

## 9. Scenario Analysis

| Parameter | Pessimistic (−20%) | Base Case | Optimistic (+20%) |
|---|---|---|---|
| HSM | 16 hrs | 20 hrs | 24 hrs |
| MAB | $480 | $600 | $720 |
| OPEX | $72 | $60 | $48 |
| CHR | $35 | $35 | $35 |

| Result | Pessimistic | Base Case | Optimistic |
|---|---|---|---|
| Monthly Gross Benefit | $1,040 | $1,300 | $1,560 |
| **Monthly Net Benefit** | **$968** | **$1,240** | **$1,512** |
| **Payback Period** | **~22 days** | **~17 days** | **~14 days** |
| 12-Month Net Profit | $10,916 | $14,180 | $17,444 |
| **ROI** | **1,560%** | **2,026%** | **2,492%** |

**How to use with clients:**

> *"Even in the pessimistic scenario — 20% fewer hours saved, 20% lower benefits, and 20% higher costs — the project still pays off in 22 days and delivers $10,916 in net profit over the year. There is no scenario where this investment loses money."*

---

## 10. KPI Comparison (Before vs. After)

| KPI | Before Automation | After Automation | Change |
|---|---|---|---|
| Time to qualify one lead | 15 minutes | 2 minutes | −87% |
| Leads qualified per hour | 4 leads | 30 leads | +650% |
| Invalid emails reaching outreach | ~15–20% of list | <2% (Bouncer filtered) | −90% |
| ICP scoring consistency | Subjective (SDR judgment) | 100% rule-based + AI scored | Fully consistent |
| Company research coverage | Varies by SDR effort | 100% (Tavily web search every lead) | +100% |
| Time to sales alert (qualified lead) | Same day or next day | <2 minutes | −99% |
| SDR hours/month on qualification | ~25 hours | ~3 hours (result review only) | −88% |
| Cost per lead (labor only) | $8.75 (15 min × $35) | $1.17 (2 min × $35) | −87% |
| Audit trail per lead decision | None | Full record in Google Sheets | New capability |
| Daily processing capacity | ~15–20 (manual limit) | Unlimited (automated daily batch) | Scalable |

---

## 11. Client Presentation Script

**Open with payback period:**
> *"Your $700 investment pays off in 17 days. After that, it generates $1,240 in net savings every month for the rest of the year."*

**If asked about the numbers:**
> *"These are conservative estimates — we applied a 0.9 accuracy buffer to time savings and only included $600 in additional benefits that trace to specific, measurable business outcomes: domain reputation protection, better conversion rates, and eliminated wasted discovery calls."*

**If the client doubts hours saved:**
> *"The 15-minute estimate is based on timing the individual tasks: 3 min to verify an email, 5 min to research the company, 3 min to score ICP criteria, 2 min to update the sheet. We can time your SDR doing this live if you want to verify the baseline."*

**If asked about ongoing cost:**
> *"$60/month covers all four APIs — Bouncer, Tavily, OpenRouter, and your n8n subscription. That's less than 5% of the monthly gross benefit."*

**If asked about risk:**
> *"Even if everything performs 20% below projection — worst case — the project still pays off in 22 days and generates $10,916 net over the year. The pessimistic scenario has a 1,560% ROI."*

**Show the FTE number:**
> *"This frees up 0.17 of a full-time employee. That's one full day per week of research time your SDR gets back — to use on closing deals instead."*

---

## 12. Risk Factors

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| API costs double | Low | MNB drops to $1,180 — ROI still ~1,880% | OPEX is only 4.6% of gross benefit |
| Lead volume drops to 50/month | Medium | HSM = 10 → MNB = $890 → PBP = 24 days | Still viable; payback under 1 month |
| AI model deprecated via OpenRouter | Low | No financial impact | Swap model in OpenRouter config — no rebuild |
| Google OAuth token expires | Low | Temporary downtime only | Re-authorize in n8n credentials (~10 min fix) |
| ICP criteria change | Medium | No cost impact | Update ICP Rule Check node + AI prompt — ~1 hour |

Even at 50% of projected lead volume with doubled OPEX, the project remains profitable with a payback period under 30 days.

---

## 13. Recommendation

**Proceed with full deployment and activation.**

With a 17-day payback period, 2,026% ROI, and $13,405 NPV over 12 months, this automation far exceeds standard investment benchmarks. The $60/month OPEX is under 5% of monthly gross benefit — an exceptionally lean cost structure. As lead volume grows, every additional lead processed adds ~$13 in net benefit (13 min × $35/hr × UTIL) at near-zero additional OPEX.

**Next investment opportunities:**
1. **CRM integration** — push qualified leads directly to HubSpot/Salesforce (add ~5 hrs/month to HSM)
2. **Multi-ICP vertical** — add a second industry target, doubling throughput at the same fixed cost
3. **Automated outreach sequencing** — trigger email campaigns for Qualified leads (increases MAB through direct revenue acceleration)

---

*Version 1.2 | Therrance Carrothers | March 4, 2026*
*All values verified against assignment-provided parameters: CHR=$35, UTIL=0.70, MAB=$600, n=12, DR=0.10*
*Lead Qualification Agent — ROI Analysis | AI Automation Specialist Course*
