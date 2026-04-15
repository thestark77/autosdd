# MCP Server Configuration Guide

MCPs (Model Context Protocol) extend Claude Code with real-world capabilities. AutoSDD depends on several MCPs for persistent memory, browser automation, database management, deployment, and error tracking.

---

## Settings File Location

MCPs are configured in `.claude/settings.json` in your project root (project-scoped) or `~/.claude/settings.json` (user-scoped).

```json
{
  "mcpServers": {
    "engram": { ... },
    "playwright": { ... },
    "prisma": { ... },
    "railway": { ... },
    "sentry": { ... }
  }
}
```

---

## Engram — Persistent Memory (CRITICAL)

Engram gives Claude Code memory that survives across sessions, compactions, and restarts. Without it, every session starts blind.

**Repository**: https://github.com/nicobailon/engram

### Installation

```bash
# Install Engram server
npx -y @nicobailon/engram
```

### Configuration

```json
{
  "mcpServers": {
    "plugin:engram:engram": {
      "command": "node",
      "args": ["/path/to/engram/dist/index.js"],
      "env": {
        "ENGRAM_STORAGE_PATH": "~/.engram"
      }
    }
  }
}
```

### What Gets Saved

- Architecture and design decisions
- Bug fixes with root causes
- Team conventions and patterns
- Workflow changes
- Non-obvious codebase discoveries
- User preferences and constraints

### Usage Pattern

```
mem_save     — Save a decision or discovery immediately
mem_search   — Find prior context from previous sessions
mem_context  — Get recent session history
mem_get_observation — Get full content of a search result
mem_session_summary — End-of-session summary (mandatory)
```

---

## Playwright — Browser Automation

Playwright MCP enables Claude Code to navigate browsers, fill forms, take screenshots, and verify UI behavior.

**Repository**: https://github.com/anthropics/claude-code/tree/main/packages/playwright-mcp

### Installation

```bash
npx @anthropic-ai/playwright-mcp
```

### Configuration

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@anthropic-ai/playwright-mcp", "--headless"]
    }
  }
}
```

### Key Tools

| Tool | Use |
|------|-----|
| `browser_navigate` | Navigate to a URL |
| `browser_snapshot` | Capture accessibility tree |
| `browser_take_screenshot` | Visual capture |
| `browser_fill_form` | Fill and submit forms |
| `browser_click` | Click elements |
| `browser_wait_for` | Wait for conditions |

### Usage in AutoSDD

During the **verify** phase, agents use Playwright to:
1. Navigate user flows end-to-end
2. Verify UI renders correctly
3. Check form validation messages
4. Test role-based access control
5. Validate mobile responsiveness

---

## Prisma — Database Management

The Prisma MCP enables agents to query the database, run migrations, and verify data state directly.

**URL**: https://mcp.prisma.io/mcp

### Configuration

```json
{
  "mcpServers": {
    "prisma": {
      "command": "npx",
      "args": ["--yes", "mcp-remote", "https://mcp.prisma.io/mcp"]
    }
  }
}
```

### Usage in AutoSDD

- Run `prisma migrate dev` after schema changes
- Verify data state after operations
- Run seeds before test suites
- Check migration history

### Direct CLI (preferred for migrations)

```bash
rtk prisma migrate dev     # Run pending migrations
rtk prisma db seed         # Seed database
rtk prisma generate        # Regenerate client after schema change
rtk prisma studio          # GUI for data inspection
```

---

## Railway — Deployment

Railway MCP enables agents to deploy, monitor, and manage environment variables in production.

**Repository**: https://github.com/nicholasgriffintn/railway-mcp-server

### Installation

```bash
npm install -g @nicholasgriffintn/railway-mcp-server
```

### Configuration

```json
{
  "mcpServers": {
    "railway-mcp-server": {
      "command": "railway-mcp-server",
      "env": {
        "RAILWAY_API_TOKEN": "your-railway-api-token"
      }
    }
  }
}
```

### Key Tools

| Tool | Use |
|------|-----|
| `deploy` | Deploy current branch |
| `get-logs` | Fetch deployment logs |
| `list-variables` | View environment variables |
| `set-variables` | Update environment variables |
| `list-deployments` | Check deployment history |

### Usage in AutoSDD

- Used in the **post-verify** phase to deploy to staging
- Check deployment logs for runtime errors
- Manage environment variables for new features

---

## Sentry — Error Tracking

Sentry MCP enables agents to query production errors and pull full stack traces.

**Repository**: https://github.com/sentry-ai/sentry-mcp-server

### Configuration

```json
{
  "mcpServers": {
    "sentry": {
      "command": "npx",
      "args": ["@sentry/mcp-server"],
      "env": {
        "SENTRY_AUTH_TOKEN": "your-sentry-auth-token",
        "SENTRY_ORG": "your-org-slug"
      }
    }
  }
}
```

### Usage in AutoSDD

- Used during **monitoring** to check for production regressions after deployment
- Pull stack traces to diagnose bugs before writing fix specs
- Verify that known errors stop appearing after a fix is deployed

---

## Linear — Issue Tracking

Linear is integrated via Claude.ai's native Linear integration (not a local MCP server).

### Setup

Enable Linear integration in Claude.ai settings → Integrations.

### Usage in AutoSDD

The orchestrator uses Linear to:
- Create issues for discovered bugs
- Link PRs to issues
- Update issue status as phases complete
- Track blocked items with `user-pending` tags

---

## Full `.claude/settings.json` Example

```json
{
  "mcpServers": {
    "plugin:engram:engram": {
      "command": "node",
      "args": ["/home/user/.engram/server/dist/index.js"],
      "env": {
        "ENGRAM_STORAGE_PATH": "/home/user/.engram/data"
      }
    },
    "playwright": {
      "command": "npx",
      "args": ["@anthropic-ai/playwright-mcp", "--headless"]
    },
    "prisma": {
      "command": "npx",
      "args": ["--yes", "mcp-remote", "https://mcp.prisma.io/mcp"]
    },
    "railway-mcp-server": {
      "command": "railway-mcp-server",
      "env": {
        "RAILWAY_API_TOKEN": "${RAILWAY_API_TOKEN}"
      }
    },
    "sentry": {
      "command": "npx",
      "args": ["@sentry/mcp-server"],
      "env": {
        "SENTRY_AUTH_TOKEN": "${SENTRY_AUTH_TOKEN}",
        "SENTRY_ORG": "${SENTRY_ORG}"
      }
    }
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git push*)",
        "hooks": [
          {
            "type": "command",
            "command": "pnpm validate"
          }
        ]
      }
    ]
  }
}
```

---

## Troubleshooting

### MCP not connecting

1. Check the command path is correct: `which npx`, `which node`
2. Check env variables are set: `echo $RAILWAY_API_TOKEN`
3. Restart Claude Code after config changes
4. Check MCP server logs in Claude Code's developer panel

### Engram not persisting across sessions

1. Verify `ENGRAM_STORAGE_PATH` points to a writable directory
2. Check the storage file exists: `ls ~/.engram/data`
3. Confirm the agent called `mem_session_summary` before ending the session

### Playwright tests failing in headless mode

1. Install browser binaries: `npx playwright install chromium`
2. Try headed mode to debug: change `--headless` to `--headed`
3. Check for missing system dependencies: `npx playwright install-deps`
