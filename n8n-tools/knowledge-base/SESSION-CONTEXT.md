# Session Context - Therrance's n8n Setup

**Last Updated**: 2026-01-29

This document captures everything about this user's n8n environment for seamless continuation across sessions.

---

## User Profile

- **Name**: Therrance Carrothers
- **Email**: therrance.carrothers@careerist.academy
- **Learning**: n8n workflow automation (student)
- **Slack Channel for Alerts**: #thurr

---

## n8n Instance

- **URL**: https://therrancecarrothers.app.n8n.cloud/
- **Version**: 2.33.5 (latest as of Jan 2026)
- **Type**: n8n Cloud (hosted)

---

## Active Workflows

| ID | Name | Status | Purpose |
|----|------|--------|---------|
| XFGypgHzRtSfXz0Q | Claude Auto-Fixer | ACTIVE | Catches errors, AI analysis, Slack alerts |
| R4tjcgnzL96gLJtU | Test Workflow - Intentional Failure | ACTIVE | For testing auto-fixer |
| am2Weqftv0fIf4Xf | Email Classifier - Lesson 5 | INACTIVE | Needs credentials configured |
| ZXmHAt2ydfekikty | Invoice Processing - Google Forms | INACTIVE | Form → PDF.co → Airtable → Slack |
| xfLlie18fZHQcUeJ | Weekly Sales Report - Lesson 14 | INACTIVE | Schedule → Sheets → Chart + AI → Email |
| Q0EgGVo9oj2CpNDz | Retell AI Lead Qualification - Lesson 17 | INACTIVE | Voice calls → Supabase → Slack alerts |

---

## Credentials Available

| Service | Credential Name | Status |
|---------|-----------------|--------|
| Slack | Slack account 2 | Working |
| OpenRouter | OpenRouter account | Working |
| PDF.co | PDF.co API (HTTP Header Auth) | Working |
| Airtable | Airtable Personal Access Token account 2/3 | Working |
| Fillout | Fillout API | Available |
| Google Sheets | Invoice Submission 1 | Working |
| Supabase | Supabase API | Working |
| OpenAI | NOT SET UP | Needed for TTS in Sales Report |
| Gmail | NOT SET UP | Needed for Sales Report |

---

## Credentials TO SET UP

### Google OAuth (Priority - needed for Email Classifier)

User has 3 Google accounts:
1. **Main personal Gmail**
2. **Careerist AI Gmail**
3. **Business email** (coming soon)

### Setup Steps:
1. n8n > Credentials > Add Credential > Google OAuth2 API
2. Name: `Google OAuth - Personal Gmail`
3. Sign in with Google, select the account
4. Grant permissions, Save
5. Repeat for other accounts

---

## Working Preferences

| Setting | Value |
|---------|-------|
| Fix approach | Explain first, then fix after approval |
| Knowledge logging | Yes - document issues and solutions |
| Error notifications | Slack #thurr channel |
| Optimization | ALWAYS fix AND optimize workflows (don't just make them work - make them better) |
| Proactive improvements | Yes - suggest and implement improvements when spotted |

---

## Key Lessons Learned

1. **Slack nodes**: Always include `"operation": "post"` explicitly
2. **HTTP auth**: Don't mix credentials with manual headers - use one or the other
3. **Webhooks via API**: Must include `webhookId` and deactivate/reactivate to register
4. **Error workflows**: Only trigger on PRODUCTION executions, not test mode
5. **n8n expressions**: No optional chaining `?.` - use `|| 'default'` instead

---

## Pending Tasks

- [ ] Set up Google OAuth credentials (3 accounts)
- [ ] Configure Email Classifier - Lesson 5 with credentials
- [ ] Regenerate OpenRouter API key (was shared in chat)
- [ ] Regenerate Supabase service_role key (was shared in chat)
- [ ] Regenerate PDF.co API key (was shared in chat)
- [ ] Regenerate Airtable token (was shared in chat)
- [ ] Configure Retell AI to send webhooks to n8n

---

## Workflow Links

- **Claude Auto-Fixer**: https://therrancecarrothers.app.n8n.cloud/workflow/XFGypgHzRtSfXz0Q
- **Test Workflow**: https://therrancecarrothers.app.n8n.cloud/workflow/R4tjcgnzL96gLJtU
- **Email Classifier**: https://therrancecarrothers.app.n8n.cloud/workflow/am2Weqftv0fIf4Xf
- **Invoice Processing**: https://therrancecarrothers.app.n8n.cloud/workflow/ZXmHAt2ydfekikty
- **Weekly Sales Report**: https://therrancecarrothers.app.n8n.cloud/workflow/xfLlie18fZHQcUeJ
- **Retell AI Lead Qualification**: https://therrancecarrothers.app.n8n.cloud/workflow/Q0EgGVo9oj2CpNDz
- **Credentials Page**: https://therrancecarrothers.app.n8n.cloud/home/credentials
- **All Workflows**: https://therrancecarrothers.app.n8n.cloud/home/workflows

---

## Documentation Files

| File | Purpose |
|------|---------|
| `SESSION-CONTEXT.md` | This file - environment overview |
| `n8n-issues-solutions.md` | Issue log with root causes and fixes |
| `n8n-debugging-guide.md` | Systematic debugging approach |
| `n8n-workflow-patterns.md` | Build patterns and templates |
| `credentials-inventory.md` | Detailed credential tracking |
