#!/usr/bin/env python3
"""
Thurnos Browser Agent
---------------------
Browses and researches any URL or topic on command.
Runs headless (background) — never interrupts your screen.

Usage:
  python3 thurnos-browser.py "https://example.com"
  python3 thurnos-browser.py "search: n8n webhook patterns"
  python3 thurnos-browser.py "youtube: roofing contractor automation"
"""

import sys
import os
import json
import asyncio
from playwright.async_api import async_playwright
import anthropic

ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY", "")

# ── Helpers ──────────────────────────────────────────────────────────────────

async def get_page_content(page, url: str) -> dict:
    """Navigate to URL and extract full text content + metadata."""
    try:
        await page.goto(url, wait_until="domcontentloaded", timeout=20000)
        await page.wait_for_timeout(2000)  # let JS render

        title = await page.title()

        # Extract all visible text
        content = await page.evaluate("""() => {
            // Remove script, style, nav, footer noise
            const remove = ['script','style','nav','footer','header','aside','noscript'];
            remove.forEach(tag => {
                document.querySelectorAll(tag).forEach(el => el.remove());
            });
            return document.body?.innerText || '';
        }""")

        # Extract all links
        links = await page.evaluate("""() => {
            return Array.from(document.querySelectorAll('a[href]'))
                .map(a => ({ text: a.innerText.trim(), href: a.href }))
                .filter(l => l.text && l.href.startsWith('http'))
                .slice(0, 30);
        }""")

        return {
            "url": page.url,
            "title": title,
            "content": content[:8000],  # cap at 8k chars
            "links": links,
            "success": True
        }
    except Exception as e:
        return {"url": url, "success": False, "error": str(e)}


async def search_web(page, query: str) -> list:
    """Search via DuckDuckGo and return top result URLs."""
    search_url = f"https://duckduckgo.com/?q={query.replace(' ', '+')}&ia=web"
    await page.goto(search_url, wait_until="domcontentloaded", timeout=15000)
    await page.wait_for_timeout(2000)

    results = await page.evaluate("""() => {
        const items = document.querySelectorAll('[data-testid="result"]');
        return Array.from(items).slice(0, 8).map(el => {
            const a = el.querySelector('a[data-testid="result-title-a"]') || el.querySelector('a');
            const snippet = el.querySelector('[data-result="snippet"]') || el.querySelector('.result__snippet');
            return {
                title: a?.innerText?.trim() || '',
                url: a?.href || '',
                snippet: snippet?.innerText?.trim() || ''
            };
        }).filter(r => r.url && r.title);
    }""")
    return results


async def search_youtube(page, query: str) -> list:
    """Search YouTube and return video metadata."""
    search_url = f"https://www.youtube.com/results?search_query={query.replace(' ', '+')}"
    await page.goto(search_url, wait_until="domcontentloaded", timeout=15000)
    await page.wait_for_timeout(3000)

    videos = await page.evaluate("""() => {
        const items = document.querySelectorAll('ytd-video-renderer');
        return Array.from(items).slice(0, 10).map(el => {
            const title = el.querySelector('#video-title')?.innerText?.trim();
            const channel = el.querySelector('#channel-name')?.innerText?.trim();
            const meta = el.querySelector('#metadata-line')?.innerText?.trim();
            const href = el.querySelector('#video-title')?.href;
            const desc = el.querySelector('#description-text')?.innerText?.trim();
            return { title, channel, meta, url: href, description: desc };
        }).filter(v => v.title && v.url);
    }""")
    return videos


def synthesize_with_claude(data: dict, task: str) -> str:
    """Send collected data to Claude for analysis and synthesis."""
    if not ANTHROPIC_API_KEY:
        return "[No Anthropic API key set — set ANTHROPIC_API_KEY env var]"

    client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)

    content = json.dumps(data, indent=2)[:12000]  # stay within token limits

    response = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=2048,
        system=(
            "You are Thurnos Prime — research analyst for Thurr Solutions. "
            "Therrance Carrothers asked you to research something. "
            "Synthesize the web data you receive into a clear, actionable brief. "
            "Be direct. Use bullet points. Flag the most important insights first. "
            "If it's YouTube results, summarize what the best videos cover and which ones are worth watching. "
            "If it's a website, extract the key facts, opportunities, or data points relevant to Therrance's business."
        ),
        messages=[
            {
                "role": "user",
                "content": f"Task: {task}\n\nData collected:\n{content}"
            }
        ]
    )
    return response.content[0].text


# ── Main ─────────────────────────────────────────────────────────────────────

async def run(task: str):
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page(
            user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
        )

        data = {}

        if task.startswith("youtube:") or task.startswith("yt:"):
            query = task.split(":", 1)[1].strip()
            print(f"[Thurnos] Searching YouTube: {query}")
            videos = await search_youtube(page, query)
            data = {"type": "youtube_search", "query": query, "results": videos}

        elif task.startswith("search:"):
            query = task.split(":", 1)[1].strip()
            print(f"[Thurnos] Web searching: {query}")
            results = await search_web(page, query)
            data = {"type": "web_search", "query": query, "results": results}

            # Deep-read top 3 results
            pages = []
            for r in results[:3]:
                if r.get("url"):
                    print(f"[Thurnos] Reading: {r['url']}")
                    page_data = await get_page_content(page, r["url"])
                    pages.append(page_data)
            data["pages"] = pages

        else:
            # Treat as direct URL
            url = task.strip()
            print(f"[Thurnos] Browsing: {url}")
            page_data = await get_page_content(page, url)
            data = {"type": "direct_browse", "page": page_data}

            # If it's a search-results page, also follow top links
            if page_data.get("links"):
                sub_pages = []
                for link in page_data["links"][:3]:
                    print(f"[Thurnos] Following: {link['href']}")
                    sub = await get_page_content(page, link["href"])
                    sub_pages.append(sub)
                data["sub_pages"] = sub_pages

        await browser.close()

        print("\n" + "="*60)
        print("[Thurnos] Synthesizing with Claude...")
        print("="*60 + "\n")
        summary = synthesize_with_claude(data, task)
        print(summary)
        print("\n" + "="*60)

        # Also save raw data for reference
        out_file = "/tmp/thurnos-research-last.json"
        with open(out_file, "w") as f:
            json.dump(data, f, indent=2)
        print(f"[Thurnos] Raw data saved to {out_file}")


def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print('  python3 thurnos-browser.py "https://example.com"')
        print('  python3 thurnos-browser.py "search: n8n best practices"')
        print('  python3 thurnos-browser.py "youtube: roofing contractor leads automation"')
        sys.exit(1)

    task = " ".join(sys.argv[1:])
    asyncio.run(run(task))


if __name__ == "__main__":
    main()
