# Claude Code Hooks Configuration

Hooks automate quality enforcement. They run at defined points in Claude Code's tool lifecycle — before or after specific tool calls — without requiring the agent to remember to run them manually.

---

## All Hook Events (25)

| Event | When it fires | Can block? |
|-------|--------------|------------|
| `PreToolUse` | Before any tool execution | Yes — return non-zero to block |
| `PostToolUse` | After tool execution succeeds | No — output is logged only |
| `PostToolUseFailure` | After tool execution fails | No — use for error tracking |
| `SessionStart` | Session begins | No — use to load context |
| `SessionEnd` | Session ends | No — use to save summaries |
| `Stop` | Claude finishes responding | No — use for quality checks |
| `StopFailure` | Claude fails to respond | No — use for error recovery |
| `SubagentStart` | A sub-agent launches | No |
| `SubagentStop` | A sub-agent completes | No — use for output validation |
| `TaskCreated` | A task is created | No |
| `TaskCompleted` | A task is completed | No |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | A file is modified | No |
| `ConfigChange` | Settings or config changes | No |
| `Notification` | When Claude sends a notification | No — use for routing to desktop/mobile |
| `PermissionRequest` | A permission is requested | Yes — can approve/deny programmatically |
| `PermissionDenied` | A permission request is denied | No |
| `PreCompact` | Before context compaction | No — use to backup state |
| `PostCompact` | After context compaction | No — use for recovery |
| `UserPromptSubmit` | Before processing user input | Yes — use for cleanup pipeline |
| `TeammateIdle` | A teammate agent is idle | No |
| `InstructionsLoaded` | Agent instructions are loaded | No |
| `WorktreeCreate` | A git worktree is created | No |
| `WorktreeRemove` | A git worktree is removed | No |
| `Elicitation` | Claude elicits user input | No — use for input preprocessing |
| `ElicitationResult` | User responds to elicitation | No — use for response validation |

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
  "url": "https://hooks.slack.com/services/YOUR/WEBHOOK/URL",
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

## Recommended AutoSDD Hooks

Five strategic hooks that cover the most important automation points:

### 1. PreToolUse — Pre-push quality gate

Block all pushes unless `pnpm validate` passes:

```json
{
  "PreToolUse": [
    {
      "matcher": "Bash(git push*)",
      "hooks": [{ "type": "command", "command": "pnpm validate" }]
    }
  ]
}
```

### 2. Notification — Desktop notification

Route Claude Code notifications to a desktop alert (cross-platform):

```json
{
  "Notification": [
    {
      "matcher": "*",
      "hooks": [
        {
          "type": "command",
          "command": "node -e \"const {execSync}=require('child_process');const p=process.platform;const m=process.env.NOTIFICATION_MESSAGE||'Claude Code';if(p==='darwin')execSync('osascript -e \\'display notification \"'+m+'\" with title \"Claude Code\"\\'');else if(p==='linux')execSync('notify-send \"Claude Code\" \"'+m+'\"');else execSync('powershell -Command \"[System.Reflection.Assembly]::LoadWithPartialName(\\'System.Windows.Forms\\');[System.Windows.Forms.MessageBox]::Show(\\''+m+'\\')\"');\""
        }
      ]
    }
  ]
}
```

> For a simpler setup, use the [Remote Control](#) feature to receive notifications on your phone via the Claude mobile app — no bot setup required.

### 3. PreCompact — Save session to Engram before compaction

Preserve session state before context is compacted:

```json
{
  "PreCompact": [
    {
      "matcher": "*",
      "hooks": [
        {
          "type": "prompt",
          "prompt": "The context is about to be compacted. Call mem_session_summary NOW with everything we've done this session — decisions, bugs fixed, files changed, and what remains. This is mandatory. Do not skip it."
        }
      ]
    }
  ]
}
```

### 4. SessionStart — Recover context from Engram after compaction

Restore state when a new session starts (especially after compaction):

```json
{
  "SessionStart": [
    {
      "matcher": "*",
      "hooks": [
        {
          "type": "prompt",
          "prompt": "Session starting. Call mem_context immediately to recover context from previous sessions. If this is a post-compaction start, also call mem_search with the project name to recover the last session summary. Do this before responding to any user message."
        }
      ]
    }
  ]
}
```

### 5. Stop — Verify all tasks completed

After Claude finishes responding, check if any tasks remain open:

```json
{
  "Stop": [
    {
      "matcher": "*",
      "hooks": [
        {
          "type": "prompt",
          "prompt": "Before completing: check if there are any open TODO items, incomplete tasks, or unresolved blockers from this session. If yes, list them. If no, respond with COMPLETE."
        }
      ]
    }
  ]
}
```

---

## Complete `.claude/settings.json` Configuration

Full recommended setup combining all five strategic hooks:

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
    ],
    "Notification": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"const {execSync}=require('child_process');const p=process.platform;const m=process.env.NOTIFICATION_MESSAGE||'Claude Code';if(p==='darwin')execSync('osascript -e \\'display notification \"'+m+'\" with title \"Claude Code\"\\'');else if(p==='linux')execSync('notify-send \"Claude Code\" \"'+m+'\"');else execSync('powershell -Command \"[System.Reflection.Assembly]::LoadWithPartialName(\\'System.Windows.Forms\\');[System.Windows.Forms.MessageBox]::Show(\\''+m+'\\')\"');\""
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "The context is about to be compacted. Call mem_session_summary NOW with everything we've done this session — decisions, bugs fixed, files changed, and what remains. This is mandatory. Do not skip it."
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Session starting. Call mem_context immediately to recover context from previous sessions. If this is a post-compaction start, also call mem_search with the project name to recover the last session summary. Do this before responding to any user message."
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Before completing: check if there are any open TODO items, incomplete tasks, or unresolved blockers from this session. If yes, list them. If no, respond with COMPLETE."
          }
        ]
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
    ]
  }
}
```

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

## Settings File Location

- **Project-scoped**: `.claude/settings.json` (committed to repo — shared with team)
- **User-scoped**: `~/.claude/settings.json` (personal — not committed)

For team projects, keep the pre-push hook in the project-scoped settings so every developer (and every agent) runs the same quality gates.

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
