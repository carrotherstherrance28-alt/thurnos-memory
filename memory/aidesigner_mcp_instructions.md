# AIDesigner MCP — Website Creation Instructions

## What it is
AIDesigner MCP is a Model Context Protocol server that gives Claude production-ready UI design capabilities directly inside the editor. It reads your project's framework, component library, CSS/Tailwind tokens, and design system, then generates UI code that fits your existing stack.

## How to use it for websites
When building websites for ThurrSolutions clients, always:
1. Run `/mcp` and select "aidesigner" to connect
2. Tell it the client name and website goal (e.g. "GoL1ve needs a landing page for a sports coaching brand")
3. Specify the stack: HTML/CSS, React, WordPress, etc.
4. Prompt with: "Use AIDesigner to generate a [page type] for [client] with [key features]"
5. Iterate on the design before handing off to the client

## Good prompts for client websites
- "Use AIDesigner to generate a service landing page for a contractor business with a quote request form"
- "Use AIDesigner to generate a hospice care homepage that is warm, professional, and mobile-first"
- "Use AIDesigner to generate a nail salon booking page with gallery and pricing table"

## Source
- Docs: https://www.aidesigner.ai/docs/claude-code-mcp
- Registry: https://a2a-mcp.org/entry/aidesigner-mcp
