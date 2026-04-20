# n8n Workflow Issues & Solutions Knowledge Base

**Last Updated**: 2026-01-28

This document tracks issues encountered, their root causes, and solutions applied.

---

## Quick Reference - Common Patterns

### Expression Errors
| Issue | Cause | Solution |
|-------|-------|----------|
| `={{ }}` not working | Missing `=` prefix | Always use `={{ $json.field }}` not `{{ $json.field }}` |
| Undefined reference | Previous node data not available | Check node connections and data flow |
| Optional chaining `?.` not working | n8n doesn't support `?.` | Use `$json.field.name \|\| 'default'` instead |

### Slack Node Issues
| Issue | Cause | Solution |
|-------|-------|----------|
| "Invalid value for operation" | Missing operation parameter | Add `"operation": "post"` to parameters |
| Channel not found | Channel ID not set | Select channel in n8n UI after adding credential |

### HTTP Request / API Issues
| Issue | Cause | Solution |
|-------|-------|----------|
| 401 Unauthorized | Auth conflict or bad key | Set `authentication: "none"` and use manual headers |
| "No cookie auth credentials" | Credential + manual headers conflict | Remove credential, use headers only |

### Webhook Issues
| Issue | Cause | Solution |
|-------|-------|----------|
| Webhook not registered (404) | Missing webhookId or not saved | Add webhookId, deactivate/reactivate workflow |
| Test URL vs Production URL | Different URLs for testing vs production | Test: `/webhook-test/path`, Prod: `/webhook/path` |
| Error workflow not triggering | Only triggers on production executions | Use production webhook, not test mode |

---

## Issue Log

### Issue #1: Slack Node Missing Operation Parameter
**Date**: 2026-01-28
**Workflow**: Claude Auto-Fixer, Email Classifier

**Symptoms**:
- Validation error: "Invalid value for 'operation'. Must be one of: delete, getPermalink, search, post, sendAndWait, update"

**Root Cause**:
- Slack node created via API didn't include the `operation` parameter
- n8n requires explicit operation even for the default "post" action

**Solution**:
- Add `"operation": "post"` to Slack node parameters

**Prevention**:
- Always include operation parameter when creating Slack nodes via API

---

### Issue #2: HTTP Request Auth Conflict
**Date**: 2026-01-28
**Workflow**: Claude Auto-Fixer

**Symptoms**:
- 401 error: "No cookie auth credentials found"
- OpenRouter API rejecting requests

**Root Cause**:
- Node had both `authentication: "genericCredentialType"` with a credential AND manual Authorization headers
- n8n tried to use the credential (which was misconfigured) instead of the headers

**Solution**:
- Set `authentication: "none"`
- Use only manual headers with the API key

**Prevention**:
- Don't mix credential auth with manual headers
- For simple API key auth, use manual headers with `authentication: "none"`

---

### Issue #3: Webhook Not Registering in Production
**Date**: 2026-01-28
**Workflow**: Test Workflow - Intentional Failure

**Symptoms**:
- Production webhook URL returns 404
- Test webhook works fine

**Root Cause**:
- Webhook node added via API didn't have a `webhookId`
- n8n cloud requires webhookId for production webhook registration

**Solution**:
- Add `webhookId` property to webhook node
- Deactivate and reactivate workflow to register the webhook

**Prevention**:
- Always include webhookId when creating webhook nodes via API
- After adding webhooks, deactivate/reactivate to register

---

### Issue #4: Error Workflow Not Triggering
**Date**: 2026-01-28
**Workflow**: Claude Auto-Fixer

**Symptoms**:
- Test workflow failed but error workflow didn't run

**Root Cause**:
- Error workflows only trigger for PRODUCTION executions
- Test/manual executions don't trigger error workflows

**Solution**:
- Trigger the workflow via production webhook URL, not test mode

**Prevention**:
- Remember: Error workflows = production only
- For testing error workflows, use production triggers

---

### Issue #5: Invalid Model Name
**Date**: 2026-01-28
**Workflow**: Email Classifier - Lesson 5

**Symptoms**:
- Original workflow had `gpt-5-mini` model

**Root Cause**:
- Model name doesn't exist (was placeholder or typo in original)

**Solution**:
- Changed to `gpt-4o-mini` which is a valid OpenAI model

**Prevention**:
- Verify model names exist before using them

---

### Issue #6: Google Sheets Trigger - Sheet Not Found
**Date**: 2026-01-28
**Workflow**: Invoice Processing - Google Forms

**Symptoms**:
- Error: "Sheet with ID gid=X not found"
- Trigger fails to read spreadsheet

**Root Cause**:
- Sheet GID was incorrect or credential didn't have access
- Using pasted gid instead of selecting from dropdown

**Solution**:
- Select sheet from dropdown in n8n UI (ensures proper auth)
- Verify the Google account in credential has access to the spreadsheet

**Prevention**:
- Always select documents/sheets from dropdown, not paste IDs
- Share spreadsheet with the Google account used in credential

---

### Issue #7: PDF.co Community Node Not Available
**Date**: 2026-01-28
**Workflow**: Invoice Processing - Google Forms

**Symptoms**:
- Validation error: "Unknown node type: n8n-nodes-pdfco.PDFco Api"

**Root Cause**:
- PDF.co is a community node that may not be installed
- Node type reference was incorrect

**Solution**:
- Replace with HTTP Request node calling PDF.co API directly
- Use endpoint: `https://api.pdf.co/v1/pdf/invoiceparser`
- Use HTTP Header Auth with `x-api-key` header

**Prevention**:
- For third-party services without built-in nodes, use HTTP Request
- This is more reliable than depending on community nodes

---

### Issue #8: Airtable Column Mapping Reset
**Date**: 2026-01-28
**Workflow**: Invoice Processing - Google Forms

**Symptoms**:
- Airtable node had default values instead of expressions
- Data not being populated correctly

**Root Cause**:
- User edited node in UI and column mapping was reset
- API updates don't preserve UI-modified configurations

**Solution**:
- Re-apply correct column mappings via API
- Use expressions like `={{ $json.fieldName }}`

**Prevention**:
- After API updates, verify node configuration in UI
- Document expected mappings in workflow notes

---

## Statistics

- **Total Issues Resolved**: 8
- **Most Common Category**: Authentication/Configuration, Credential Access
- **Key Learnings**:
  - Always set explicit parameters
  - Don't mix auth methods
  - Webhooks need IDs
  - Select sheets/docs from dropdown (not paste IDs)
  - Use HTTP Request for third-party APIs without built-in nodes
