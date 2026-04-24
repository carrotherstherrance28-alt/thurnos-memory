#!/usr/bin/env python3
"""
Thurnos Dispatch — Discord → Mac Mini Bridge
You type a command in Discord → runs on your Mac → reports back

Commands:
  !run [bash command]     → runs shell command, returns output
  !browse [url or query]  → launches browser agent, returns summary
  !status                 → system status (n8n, bot, disk, etc.)
  !restart bot            → restarts the Discord bot
  !files [path]           → lists files at path
"""

import discord
import anthropic
import subprocess
import asyncio
import os
import sys
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
log = logging.getLogger('dispatch')

DISCORD_TOKEN  = os.environ.get("DISCORD_TOKEN", "")
ANTHROPIC_KEY  = os.environ.get("ANTHROPIC_API_KEY", "")
GEMINI_KEY     = os.environ.get("GEMINI_API_KEY", "")

# Only YOUR Discord user ID can run dispatch commands
OWNER_ID       = int(os.environ.get("DISCORD_OWNER_ID", "0"))

# Same channel map as the main bot
DISPATCH_CHANNELS = {
    1490820088432169074,  # general
    1490821603787935814,  # n8n-logs
    1490821698549710898,  # lead-alerts
    1490821776899309668,  # client-updates
    1490821873708306654,  # restore-contracting
    1490821983556866139,  # 5star-hospice
    1490822226164056116,  # errors
    1490822303829852161,  # api-costs
}

SAFE_COMMANDS = True  # Set False to allow any bash command (dangerous)

BLOCKED_COMMANDS = [
    'rm -rf', 'sudo rm', 'mkfs', 'dd if=', 'format',
    '> /dev/sda', 'shutdown', 'reboot', ':(){ :|:& };:'
]

intents = discord.Intents.default()
intents.message_content = True
intents.messages = True

client_discord = discord.Client(intents=intents)
client_claude  = anthropic.Anthropic(api_key=ANTHROPIC_KEY)

async def send(message, text):
    if len(text) <= 1900:
        await message.reply(f"```\n{text}\n```" if '\n' in text else text, mention_author=False)
    else:
        chunks = [text[i:i+1800] for i in range(0, len(text), 1800)]
        for chunk in chunks:
            await message.reply(f"```\n{chunk}\n```", mention_author=False)

async def run_command(cmd: str) -> str:
    if SAFE_COMMANDS:
        for blocked in BLOCKED_COMMANDS:
            if blocked in cmd.lower():
                return f"❌ Blocked: '{blocked}' is not allowed"

    try:
        result = await asyncio.create_subprocess_shell(
            cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            cwd=os.path.expanduser("~/thurnos-memory")
        )
        stdout, stderr = await asyncio.wait_for(result.communicate(), timeout=30)
        output = stdout.decode().strip() or stderr.decode().strip()
        return output[:1800] if output else "(no output)"
    except asyncio.TimeoutError:
        return "⏱️ Command timed out after 30 seconds"
    except Exception as e:
        return f"❌ Error: {str(e)}"

async def get_status() -> str:
    n8n = await run_command("lsof -i :5678 | grep LISTEN | wc -l")
    bot = await run_command("pgrep -f thurnos-bot.py | wc -l")
    disk = await run_command("df -h / | tail -1 | awk '{print $4\" free of \"$2}'")
    docker = await run_command("docker ps --format '{{.Names}}' 2>/dev/null || echo 'Docker off'")
    ollama = await run_command("ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' | tr '\n' ', '")

    return (
        f"**Thurnos Prime — System Status**\n"
        f"n8n local: {'🟢 Running' if n8n.strip() != '0' else '🔴 Down'}\n"
        f"Discord bot: {'🟢 Running' if bot.strip() != '0' else '🔴 Down'}\n"
        f"Disk free: {disk}\n"
        f"Docker: {docker}\n"
        f"Ollama models: {ollama or 'none'}"
    )

@client_discord.event
async def on_ready():
    log.info(f"Thurnos Dispatch online as {client_discord.user}")

@client_discord.event
async def on_message(message: discord.Message):
    if message.author.bot:
        return

    # Dispatch commands only work for you
    if message.author.id != OWNER_ID and OWNER_ID != 0:
        return

    if message.channel.id not in DISPATCH_CHANNELS:
        return

    content = message.content.strip()

    async with message.channel.typing():

        if content.lower().startswith("!run "):
            cmd = content[5:].strip()
            log.info(f"DISPATCH run: {cmd}")
            result = await run_command(cmd)
            await send(message, f"⚡ `{cmd}`\n{result}")

        elif content.lower().startswith("!browse "):
            query = content[8:].strip()
            log.info(f"DISPATCH browse: {query}")
            script = f"~/thurnos-memory/n8n-tools/thurnos-browser.py"
            result = await run_command(f"ANTHROPIC_API_KEY={ANTHROPIC_KEY} python3 {script} '{query}'")
            await send(message, f"🌐 **Browse:** {query}\n{result}")

        elif content.lower() == "!status":
            result = await get_status()
            await message.reply(result, mention_author=False)

        elif content.lower() == "!restart bot":
            await message.reply("🔄 Restarting Thurnos Prime bot...", mention_author=False)
            await run_command("pkill -f thurnos-bot.py")
            await asyncio.sleep(2)
            await run_command(
                f"set -a && source ~/thurnos-memory/n8n-tools/.env.thurnos && set +a && "
                f"nohup python3 ~/thurnos-memory/n8n-tools/thurnos-bot.py > ~/.n8n/thurnos-bot.log 2>&1 &"
            )
            await message.reply("✅ Bot restarted.", mention_author=False)

        elif content.lower().startswith("!files"):
            path = content[6:].strip() or "~/thurnos-memory"
            result = await run_command(f"ls -la {path}")
            await send(message, result)

        elif content.lower() == "!help dispatch":
            help_text = (
                "**Thurnos Dispatch Commands** *(owner only)*\n"
                "```\n"
                "!run [command]    → run any shell command on Mac Mini\n"
                "!browse [query]   → browse web + get AI summary\n"
                "!status           → system health check\n"
                "!restart bot      → restart the Discord bot\n"
                "!files [path]     → list files at path\n"
                "```"
            )
            await message.reply(help_text, mention_author=False)

if __name__ == "__main__":
    if not DISCORD_TOKEN:
        print("❌ DISCORD_TOKEN not set"); exit(1)
    log.info("Starting Thurnos Dispatch...")
    client_discord.run(DISCORD_TOKEN, log_handler=None)
