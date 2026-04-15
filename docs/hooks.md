# Claude Code Hooks Configuration

Hooks automate quality enforcement. They run at defined points in Claude Code's tool lifecycle — before or after specific tool calls — without requiring the agent to remember to run them manually.

---

## All Hook Events

| Event | When it fires | Can block? |
|-------|--------------|------------|
| `PreToolUse` | Before any tool execution | Yes — return non-zero to block |
| `PostToolUse` | After tool execution | No — output is logged only |
| `SessionStart` | Session begins | No — use to load context |
| `Stop` | Claude finishes responding | No — use for quality checks |
| `SubagentStart` | A sub-agent launches | No |
| `SubagentStop` | A sub-agent completes | No — use for output validation |
| `TaskCreated` | A task is created | No |
| `TaskCompleted` | A task is completed | No |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | A file is modified | No |
| `PermissionDenied` | A permission request is denied | No |
| `PreCompact` | Before context compaction | No — use to backup state |
| `PostCompact` | After context compaction | No — use for recovery |
| `UserPromptSubmit` | Before processing user input | Yes — use for cleanup pipeline |
| `Notification` | When Claude sends a notification | No — use for routing to Telegram/Slack |

---

## Handler Types

| Type | Description | Best for |
|------|-------------|---------|
| `command` | Shell script executed in the project root | Quality gates, validation, formatting |
| `prompt` | LLM judgment — runs against `$ARGUMENTS` (the tool input) | Ambiguity detection, content review |
| `http` | POST JSON payload to an external endpoint | Notifications, webhooks, external integrations |
| `agent` | Sub-agent with full tool access (Read, Grep, Glob) | Complex validation, context-aware checks |

### `command` example

```json
{ "type": "command", "command": "pnpm validate" }
```

### `prompt` example

```json
{
  "type": "prompt",
  "prompt": "Review this user input for clarity. If ambiguous, suggest clarifying questions. If clear, respond with APPROVE."
}
```

### `http` example

```json
{
  "type": "http",
  "url": "https://api.telegram.org/bot{TOKEN}/sendMessage",
  "headers": { "Content-Type": "application/json" }
}
```

### `agent` example

```json
{
  "type": "agent",
  "prompt": "Review the modified file for security issues. Check for exposed secrets, SQL injection risks, and unvalidated inputs. Report CRITICAL if any are found."
}
```

---

## Hook Types

---

## The Pre-Push Quality Gate

The most important hook in AutoSDD runs `pnpm validate` before any `git push`:

```json
{
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

### What This Does

Every time Claude Code (or you) runs any `git push` command, this hook fires first:

1. Runs `pnpm validate` (lint + typecheck + unit/integration tests)
2. If validation **passes** → push proceeds
3. If validation **fails** → push is blocked with the error output

### Why This Matters

Without this hook, an agent could push code with:
- TypeScript errors it didn't notice
- Failing tests it didn't run
- Lint violations it forgot to check

The hook makes quality gates **structural** — they cannot be bypassed through inattention.

### Never Use `--no-verify`

```bash
# WRONG — bypasses the hook, ships broken code
git push --no-verify

# CORRECT — fix the issue, then push
pnpm validate  # see what's failing
# fix issues...
git push       # hook runs, gate passes
```

---

## `pnpm validate` Contents

```json
{
  "scripts": {
    "validate": "pnpm lint && pnpm typecheck && rtk vitest run",
    "validate:full": "pnpm validate && rtk playwright test"
  }
}
```

The hook runs the standard `validate` script. For changes with E2E implications, run `validate:full` manually before pushing.

---

## Adding More Hooks

### Pre-commit linting

Run lint before every commit:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git commit*)",
        "hooks": [
          {
            "type": "command",
            "command": "pnpm lint"
          }
        ]
      }
    ]
  }
}
```

### Post-migration type generation

Regenerate Prisma client after every migration:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash(prisma migrate*)",
        "hooks": [
          {
            "type": "command",
            "command": "rtk prisma generate"
          }
        ]
      }
    ]
  }
}
```

### Notify on test failure

Save test failures to Engram for tracking:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash(rtk vitest run*)",
        "hooks": [
          {
            "type": "command",
            "command": "if [ $? -ne 0 ]; then echo 'Test suite failed — check Engram for details'; fi"
          }
        ]
      }
    ]
  }
}
```

---

## AutoSDD Hook Configuration

The recommended baseline hook setup for any AutoSDD project covers three key automation points:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git push*)",
        "hooks": [{ "type": "command", "command": "pnpm validate" }]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Review this user input for clarity. If ambiguous, suggest clarifying questions. If clear, respond with APPROVE."
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "http",
            "url": "https://api.telegram.org/bot{TOKEN}/sendMessage",
            "headers": { "Content-Type": "application/json" }
          }
        ]
      }
    ]
  }
}
```

| Hook | Purpose |
|------|---------|
| `PreToolUse` on `git push*` | Blocks all pushes unless `pnpm validate` passes |
| `UserPromptSubmit` | LLM reviews every user input for ambiguity before execution starts |
| `Notification` | Routes all Claude notifications to Telegram (Iron Man mode) |

---

## Settings File Location

- **Project-scoped**: `.claude/settings.json` (committed to repo — shared with team)
- **User-scoped**: `~/.claude/settings.json` (personal — not committed)

For team projects, keep the pre-push hook in the project-scoped settings so every developer (and every agent) runs the same quality gates.

---

## Full Example Settings File

```json
{
  "mcpServers": {
    "plugin:engram:engram": {
      "command": "node",
      "args": ["/home/user/.engram/server/dist/index.js"]
    },
    "playwright": {
      "command": "npx",
      "args": ["@anthropic-ai/playwright-mcp", "--headless"]
    },
    "prisma": {
      "command": "npx",
      "args": ["--yes", "mcp-remote", "https://mcp.prisma.io/mcp"]
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
      },
      {
        "matcher": "Bash(git commit*)",
        "hooks": [
          {
            "type": "command",
            "command": "pnpm lint"
          }
        ]
      }
    ]
  }
}
```

---

## Troubleshooting

### Hook not firing

1. Check the matcher syntax — it must match the exact Bash command format
2. Restart Claude Code after changing settings
3. Verify the settings file is valid JSON: `cat .claude/settings.json | jq .`

### Hook running but command not found

1. Use full paths in hook commands: `/usr/local/bin/pnpm validate`
2. Or ensure the project's `node_modules/.bin` is in PATH for hook execution

### Validation takes too long

Split into faster checks for commit hooks and full validation only for push:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git commit*)",
        "hooks": [{ "type": "command", "command": "pnpm lint && pnpm typecheck" }]
      },
      {
        "matcher": "Bash(git push*)",
        "hooks": [{ "type": "command", "command": "pnpm validate" }]
      }
    ]
  }
}
```
