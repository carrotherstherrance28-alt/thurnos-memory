#!/usr/bin/env python3
"""
Thurnos Prime — Discord Bot
Runs locally on Mac Mini. Stays private.

Commands:
  !draft [task]   → Gemma4 local (free, fast, internal)
  !build [task]   → Sonnet 4.6 (client-ready quality)
  !review         → Sonnet 4.6 reviews last Gemma draft
  !approve        → Locks last output as production
  !opus [task]    → Opus 4.6 (complex orchestration only)
  (no prefix)     → Haiku 4.5 (default, fast responses)
"""

import discord
import anthropic
import httpx
import os
import json
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
log = logging.getLogger('thurnos')

# ── Config ────────────────────────────────────────────────────────────────────
DISCORD_TOKEN = os.environ.get("DISCORD_TOKEN", "")
ANTHROPIC_KEY = os.environ.get("ANTHROPIC_API_KEY", "")
OLLAMA_URL    = os.environ.get("OLLAMA_URL", "http://localhost:11434")
_owner_raw    = os.environ.get("DISCORD_OWNER_ID", "0")
OWNER_ID      = int(_owner_raw) if _owner_raw.isdigit() else 0

# Model aliases
MODEL_HAIKU   = "claude-haiku-4-5-20251001"
MODEL_SONNET  = "claude-sonnet-4-6"
MODEL_OPUS    = "claude-opus-4-6"
MODEL_GEMMA   = "gemma4:e4b"

# ── Channel map ───────────────────────────────────────────────────────────────
CHANNEL_DUTIES = {
    1490820088432169074: "general",
    1490821603787935814: "n8n-logs",
    1490821698549710898: "lead-alerts",
    1490821776899309668: "client-updates",
    1490821873708306654: "restore-contracting",
    1490821983556866139: "5star-hospice",
    1490822226164056116: "errors",
    1490822303829852161: "api-costs",
}

CHANNEL_CONTEXT = {
    "general":            "General channel. Help with anything — business, automation, research, planning.",
    "n8n-logs":           "n8n workflow logs. Review execution history, flag anomalies, diagnose issues.",
    "lead-alerts":        "Lead alerts. Help qualify, prioritize, and suggest follow-up actions.",
    "client-updates":     "Cross-client communications. Draft updates, summarize status, track deliverables.",
    "restore-contracting":"RESTORE-C client (Weather Stopper roofing). Workflow IDs: Sales Proposal=Iar5xzG6KaCj8Gy2 (18 nodes), Lead Qual=qG6B8b5kwP5zmJKm (29 nodes).",
    "5star-hospice":      "5 Star Hospice client channel. Focused assistance for this client's automation needs.",
    "errors":             "n8n error diagnosis. Be precise, identify root causes, suggest fixes.",
    "api-costs":          "API spend tracking. Monitor and optimize costs across Anthropic, Google, and other services.",
    "default":            "General assistance for Thurr Solutions operations.",
}

SYSTEM_BASE = """You are Thurnos Prime — the AI operating brain of Thurr Solutions, running privately on Therrance's Mac Mini.

Owner: Therrance Carrothers — automation agency founder, n8n workflow builder
Business: Thurr Solutions | Intern at Maximax Automation Agency
Active client: RESTORE-C (Weather Stopper roofing contractor)
n8n Cloud: therrancecarrothers.app.n8n.cloud

STANDING OPERATING PROCEDURE — BUILD vs ADAPT:
Before building ANY workflow, tool, automation, or skill:
1. Search GitHub first (n8n-io/n8n-workflows, awesome-mcp-servers, tags: n8n, mcp, ai-agent, automation)
2. Report findings with % match estimate
3. 70%+ match → adapt it | below 70% → build from scratch
4. Never build blind — confirm with Therrance before starting if close match exists
5. Log what was searched, found, and built/adapted
Trigger: /prebuild [description]

Rules:
- NEVER make purchases, send external messages, or share data without explicit consent
- Be sharp, direct, concise — Discord, not a doc editor
- Bullets for lists. Keep responses under 1800 chars when possible
- If asked to build something, run the prebuild SOP first
- Files never leave the Mac Mini"""

# ── State ─────────────────────────────────────────────────────────────────────
conversation_history: dict[int, list] = {}
last_draft: dict[int, str] = {}          # channel_id → last Gemma draft
production_log: list[dict] = []          # approved outputs

# ── Bot setup ─────────────────────────────────────────────────────────────────
intents = discord.Intents.default()
intents.message_content = True
intents.messages = True

client_discord = discord.Client(intents=intents)
client_claude  = anthropic.Anthropic(api_key=ANTHROPIC_KEY)

# ── Model callers ─────────────────────────────────────────────────────────────

async def call_claude(model: str, system: str, history: list, prompt: str) -> str:
    msgs = history + [{"role": "user", "content": prompt}]
    response = client_claude.messages.create(
        model=model,
        max_tokens=2048,
        system=system,
        messages=msgs
    )
    return response.content[0].text

async def call_gemma(prompt: str, system: str) -> str:
    payload = {
        "model": MODEL_GEMMA,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user",   "content": prompt}
        ],
        "stream": False
    }
    async with httpx.AsyncClient(timeout=60) as http:
        r = await http.post(f"{OLLAMA_URL}/api/chat", json=payload)
        r.raise_for_status()
        return r.json()["message"]["content"]

# ── Send helper (auto-splits long messages) ───────────────────────────────────

async def send(message: discord.Message, text: str):
    if len(text) <= 1900:
        await message.reply(text, mention_author=False)
    else:
        chunks = [text[i:i+1900] for i in range(0, len(text), 1900)]
        for chunk in chunks:
            await message.reply(chunk, mention_author=False)

# ── Events ────────────────────────────────────────────────────────────────────

@client_discord.event
async def on_ready():
    log.info(f"Thurnos Prime online as {client_discord.user}")
    log.info(f"Watching {len(CHANNEL_DUTIES)} channels")

@client_discord.event
async def on_message(message: discord.Message):
    if message.author.bot:
        return

    channel_id = message.channel.id
    mentioned  = client_discord.user in message.mentions
    in_watched = channel_id in CHANNEL_DUTIES

    if not in_watched and not mentioned:
        return

    content = message.content.strip()
    if client_discord.user.mention in content:
        content = content.replace(client_discord.user.mention, "").strip()
    if not content:
        return

    duty           = CHANNEL_DUTIES.get(channel_id, "default")
    channel_ctx    = CHANNEL_CONTEXT.get(duty, CHANNEL_CONTEXT["default"])
    system_prompt  = f"{SYSTEM_BASE}\n\nChannel: {channel_ctx}"
    history        = conversation_history.get(channel_id, [])

    async with message.channel.typing():
        try:
            # ── Command routing ──────────────────────────────────────────────

            if content.lower().startswith("!draft"):
                task = content[6:].strip() or "continue"
                log.info(f"DRAFT → Gemma4 | {task[:60]}")
                reply = await call_gemma(task, system_prompt)
                last_draft[channel_id] = reply
                header = "📝 **DRAFT** *(Gemma4 — internal only)*\n"
                await send(message, header + reply)
                return

            elif content.lower().startswith("!build"):
                task = content[6:].strip() or "continue"
                log.info(f"BUILD → Sonnet 4.6 | {task[:60]}")
                reply = await call_claude(MODEL_SONNET, system_prompt, history, task)
                history.append({"role": "user", "content": task})
                history.append({"role": "assistant", "content": reply})
                header = "🏗️ **BUILD** *(Sonnet 4.6 — client-ready)*\n"
                await send(message, header + reply)

            elif content.lower().startswith("!review"):
                draft = last_draft.get(channel_id)
                if not draft:
                    await send(message, "⚠️ No draft found in this channel. Run `!draft [task]` first.")
                    return
                log.info(f"REVIEW → Sonnet 4.6")
                review_prompt = f"Review this draft and improve it for client delivery. Be specific about what you changed and why.\n\nDRAFT:\n{draft}"
                reply = await call_claude(MODEL_SONNET, system_prompt, [], review_prompt)
                last_draft[channel_id] = reply
                header = "🔍 **REVIEW** *(Sonnet 4.6 — reviewed draft)*\n"
                await send(message, header + reply)
                return

            elif content.lower().startswith("!approve"):
                draft = last_draft.get(channel_id)
                if not draft:
                    await send(message, "⚠️ Nothing to approve. Run `!build` or `!review` first.")
                    return
                production_log.append({"channel": duty, "content": draft})
                log.info(f"APPROVED output in #{duty}")
                await send(message, f"✅ **APPROVED — Locked as production output.**\n\nSaved to production log. Ready to deploy.")
                return

            elif content.lower().startswith("!opus"):
                task = content[5:].strip() or "continue"
                log.info(f"OPUS → Opus 4.6 | {task[:60]}")
                reply = await call_claude(MODEL_OPUS, system_prompt, history, task)
                history.append({"role": "user", "content": task})
                history.append({"role": "assistant", "content": reply})
                header = "🧠 **OPUS** *(Opus 4.6 — complex orchestration)*\n"
                await send(message, header + reply)

            elif content.lower().startswith("!prebuild") or content.lower().startswith("/prebuild"):
                task = content.split(" ", 1)[1].strip() if " " in content else ""
                if not task:
                    await send(message, "Usage: `!prebuild [describe what you want to build]`")
                    return
                log.info(f"PREBUILD search → {task[:60]}")
                search_prompt = (
                    f"Run the Build vs Adapt SOP for this request: **{task}**\n\n"
                    f"Search these sources mentally based on your training knowledge:\n"
                    f"- n8n-io/n8n-workflows GitHub\n"
                    f"- awesome-mcp-servers repos\n"
                    f"- Tags: n8n, mcp, ai-agent, automation\n\n"
                    f"Return:\n"
                    f"1. What existing resources match (name them specifically if you know them)\n"
                    f"2. % match estimate\n"
                    f"3. Recommendation: ADAPT existing or BUILD from scratch\n"
                    f"4. Next step for Therrance to approve\n\n"
                    f"Be specific. If you don't know of an exact match, say so and recommend build."
                )
                reply = await call_claude(MODEL_SONNET, system_prompt, [], search_prompt)
                header = "🔍 **PREBUILD SCAN** *(Build vs Adapt SOP)*\n"
                await send(message, header + reply)
                return

            elif content.lower() == "!help":
                help_text = (
                    "**Thurnos Prime Commands**\n"
                    "```\n"
                    "!prebuild [task] → Search before building (SOP)\n"
                    "!draft [task]    → Gemma4 local (free, internal)\n"
                    "!build [task]    → Sonnet 4.6 (client-ready)\n"
                    "!review          → Sonnet reviews last draft\n"
                    "!approve         → Lock output as production\n"
                    "!opus [task]     → Opus 4.6 (complex only)\n"
                    "(no prefix)      → Haiku (fast chat)\n"
                    "```"
                )
                await send(message, help_text)
                return

            else:
                # Default: Haiku for fast chat
                reply = await call_claude(MODEL_HAIKU, system_prompt, history, content)
                history.append({"role": "user", "content": content})
                history.append({"role": "assistant", "content": reply})
                await send(message, reply)

            # Trim history
            if len(history) > 20:
                conversation_history[channel_id] = history[-20:]
            else:
                conversation_history[channel_id] = history

        except Exception as e:
            log.error(f"Error: {e}")
            await send(message, f"⚠️ Error: {str(e)[:300]}")

# ── Run ───────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    if not DISCORD_TOKEN:
        print("❌ DISCORD_TOKEN not set"); exit(1)
    if not ANTHROPIC_KEY:
        print("❌ ANTHROPIC_API_KEY not set"); exit(1)
    log.info("Starting Thurnos Prime...")
    client_discord.run(DISCORD_TOKEN, log_handler=None)
