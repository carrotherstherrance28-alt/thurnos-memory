# n8n MCP Server and Skills Setup Guide

## Installation Complete! ✓

I've successfully installed the n8n MCP server configuration and all 7 n8n skills for Claude Code.

## What's Installed

### 1. n8n-mcp-cc-buildier
- Location: `n8n-mcp-cc-buildier/`
- Contains: Documentation, scripts, and agent configurations for n8n workflow building

### 2. n8n Skills (7 total)
- Location: `.claude/skills/`
- All skills are now accessible to Claude Code:
  1. **n8n-expression-syntax** - Correct n8n expression syntax and common patterns
  2. **n8n-mcp-tools-expert** - Expert guide for using n8n-mcp MCP tools effectively
  3. **n8n-workflow-patterns** - 5 proven architectural patterns for workflows
  4. **n8n-validation-expert** - Interpret validation errors and guide fixing
  5. **n8n-node-configuration** - Operation-aware node configuration guidance
  6. **n8n-code-javascript** - Write effective JavaScript code in n8n Code nodes
  7. **n8n-code-python** - Write Python code in n8n Code nodes

### 3. MCP Configuration
- Location: `.mcp.json`
- Status: **REQUIRES YOUR CONFIGURATION**

## Next Steps - Configuration Required

### Step 1: Install n8n-mcp Package

The MCP configuration requires the `n8n-mcp` npm package. Install it globally or locally:

```bash
# Option 1: Global installation
npm install -g n8n-mcp

# Option 2: Using npx (no installation needed, will download on first use)
# This is already configured in .mcp.json
```

### Step 2: Configure Your n8n Instance

Edit the [.mcp.json](.mcp.json) file and replace the placeholder values:

```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["n8n-mcp"],
      "env": {
        "MCP_MODE": "stdio",
        "LOG_LEVEL": "error",
        "DISABLE_CONSOLE_OUTPUT": "true",
        "N8N_API_URL": "YOUR_N8N_INSTANCE_URL",    // Replace with your n8n URL
        "N8N_API_KEY": "YOUR_N8N_API_KEY_HERE"      // Replace with your API key
      }
    }
  }
}
```

**To get your n8n API key:**
1. Open your n8n instance
2. Go to Settings → API
3. Create a new API key
4. Copy the key to the configuration file

### Step 3: Test the Setup (Optional - Using Docker)

The `n8n-mcp-cc-buildier` repository includes a test script to start n8n locally:

```bash
cd n8n-mcp-cc-buildier
./scripts/test-n8n-integration.sh
```

This will:
- Start n8n locally on port 5678
- Launch the n8n-MCP server for Claude Code integration
- Prompt for an n8n API key (saved for future runs)

### Step 4: Restart Claude Code

After configuring `.mcp.json`, restart Claude Code to load the MCP server connection.

## How to Use

### Skills Activate Automatically

The skills will activate automatically when you ask relevant questions:

- "How do I write n8n expressions?" → Activates n8n Expression Syntax
- "Find me a Slack node" → Activates n8n MCP Tools Expert
- "Build a webhook workflow" → Activates n8n Workflow Patterns
- "Why is validation failing?" → Activates n8n Validation Expert
- "How do I configure the HTTP Request node?" → Activates n8n Node Configuration
- "How do I access webhook data in a Code node?" → Activates n8n Code JavaScript
- "Can I use pandas in Python Code node?" → Activates n8n Code Python

### Building Workflows

Once configured, you can ask me to:
- Create new n8n workflows
- Debug existing workflows
- Enhance workflows with new features
- Validate workflow configurations
- Test webhook endpoints

Example: "Create a workflow that sends daily email reports from PostgreSQL"

## Project Structure

```
Agentic Workflows/
├── .claude/
│   └── skills/                    # All 7 n8n skills installed here
│       ├── n8n-code-javascript/
│       ├── n8n-code-python/
│       ├── n8n-expression-syntax/
│       ├── n8n-mcp-tools-expert/
│       ├── n8n-node-configuration/
│       ├── n8n-validation-expert/
│       └── n8n-workflow-patterns/
├── .mcp.json                      # MCP server configuration (needs your credentials)
├── n8n-mcp-cc-buildier/          # Builder documentation and scripts
└── n8n-skills/                    # Source repository for skills
```

## Troubleshooting

### MCP Server Won't Connect
- Verify `n8n-mcp` is installed: `npx n8n-mcp --version`
- Check your n8n instance is accessible
- Verify API key is correct
- Check `.mcp.json` file syntax is valid

### Skills Not Activating
- Verify skills are in `.claude/skills/` directory
- Each skill folder should contain a `SKILL.md` file
- Restart Claude Code

### n8n API Issues
- Confirm your n8n instance is running
- Test API access with curl:
  ```bash
  curl -H "X-N8N-API-KEY: your-key" https://your-instance/api/v1/workflows
  ```

## Resources

- [n8n-mcp Repository](https://github.com/czlonkowski/n8n-mcp)
- [n8n-skills Repository](https://github.com/czlonkowski/n8n-skills)
- [n8n Documentation](https://docs.n8n.io/)
- [MCP Protocol Spec](https://spec.modelcontextprotocol.io/)

## Ready to Build!

Once you've configured your n8n credentials in `.mcp.json`, we can start building flawless n8n workflows together! 🚀
