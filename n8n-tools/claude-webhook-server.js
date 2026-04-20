/**
 * Claude Code Webhook Server
 *
 * This server listens for webhook calls from n8n Cloud
 * and triggers Claude Code to fix failed workflows.
 *
 * Usage:
 *   1. Run this server: node claude-webhook-server.js
 *   2. In another terminal: ngrok http 3456
 *   3. Copy the ngrok URL and use it in your n8n workflow
 */

const http = require('http');
const { spawn } = require('child_process');

const PORT = 3456;

// Full path to Claude Code binary (VS Code extension)
const CLAUDE_PATH = '/home/carrotherstherrance28/.vscode/extensions/anthropic.claude-code-2.1.17-linux-x64/resources/native-binary/claude';

// Optional: Add a secret token for security
// Set this to a random string and add the same value in n8n's HTTP Request headers
const SECRET_TOKEN = process.env.WEBHOOK_SECRET || null;

const server = http.createServer((req, res) => {
  // Health check endpoint
  if (req.method === 'GET' && req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', message: 'Claude webhook server is running' }));
    return;
  }

  // Main webhook endpoint
  if (req.method === 'POST' && req.url === '/fix-workflow') {
    // Check secret token if configured
    if (SECRET_TOKEN && req.headers['x-secret-token'] !== SECRET_TOKEN) {
      console.log('❌ Unauthorized request - invalid token');
      res.writeHead(401, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Unauthorized' }));
      return;
    }

    let body = '';

    req.on('data', chunk => {
      body += chunk;
    });

    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const workflowId = data.workflowId;
        const errorMessage = data.errorMessage || 'Unknown error';
        const workflowName = data.workflowName || 'Unknown workflow';

        console.log('\n' + '='.repeat(60));
        console.log('🚨 WORKFLOW FAILURE DETECTED');
        console.log('='.repeat(60));
        console.log(`📋 Workflow ID: ${workflowId}`);
        console.log(`📝 Workflow Name: ${workflowName}`);
        console.log(`❌ Error: ${errorMessage}`);
        console.log('='.repeat(60));
        console.log('🤖 Triggering Claude Code to fix the workflow...\n');

        // Build the prompt for Claude Code
        const prompt = `
An n8n workflow has failed and needs to be fixed.

**Workflow Details:**
- Workflow ID: ${workflowId}
- Workflow Name: ${workflowName}
- Error Message: ${errorMessage}

**Your Task:**
1. Use the n8n MCP tool \`n8n_get_workflow\` to fetch the workflow details
2. Use \`n8n_executions\` with action="list" to see recent execution history
3. Analyze what went wrong based on the error message and workflow structure
4. Use \`n8n_update_partial_workflow\` or \`n8n_update_full_workflow\` to fix the issue
5. Use \`n8n_validate_workflow\` to verify your fix
6. Provide a summary of what you fixed

Be careful and precise. Only make changes that address the specific error.
`;

        // Spawn Claude Code as a child process
        const claude = spawn(CLAUDE_PATH, [
          '-p', prompt,
          '--allowedTools', 'mcp__n8n-mcp__*',
          '--max-turns', '15'
        ], {
          stdio: ['inherit', 'pipe', 'pipe']
        });

        let output = '';
        let errorOutput = '';

        claude.stdout.on('data', (data) => {
          const text = data.toString();
          output += text;
          process.stdout.write(text);
        });

        claude.stderr.on('data', (data) => {
          const text = data.toString();
          errorOutput += text;
          process.stderr.write(text);
        });

        claude.on('close', (code) => {
          console.log('\n' + '='.repeat(60));
          console.log(`✅ Claude Code finished with exit code: ${code}`);
          console.log('='.repeat(60) + '\n');
        });

        claude.on('error', (err) => {
          console.error('❌ Failed to start Claude Code:', err.message);
        });

        // Respond immediately to n8n (don't wait for Claude to finish)
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          status: 'accepted',
          message: 'Claude Code has been triggered to fix the workflow',
          workflowId: workflowId
        }));

      } catch (parseError) {
        console.error('❌ Failed to parse request body:', parseError.message);
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Invalid JSON in request body' }));
      }
    });

  } else {
    // Unknown endpoint
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found. Use POST /fix-workflow' }));
  }
});

server.listen(PORT, () => {
  console.log('');
  console.log('╔════════════════════════════════════════════════════════════╗');
  console.log('║     🤖 Claude Code Webhook Server Started                  ║');
  console.log('╠════════════════════════════════════════════════════════════╣');
  console.log(`║  Server running on: http://localhost:${PORT}                  ║`);
  console.log('║                                                            ║');
  console.log('║  Next step: Open a NEW terminal and run:                   ║');
  console.log(`║     ngrok http ${PORT}                                        ║`);
  console.log('║                                                            ║');
  console.log('║  Then copy the https://...ngrok.io URL into n8n            ║');
  console.log('╚════════════════════════════════════════════════════════════╝');
  console.log('');
  console.log('Waiting for webhook calls from n8n...\n');
});

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.log('\n👋 Shutting down webhook server...');
  server.close(() => {
    console.log('Server closed.');
    process.exit(0);
  });
});
