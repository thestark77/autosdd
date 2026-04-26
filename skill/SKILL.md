---
name: autosdd
description: >
  Self-improving autonomous development framework with bidirectional feedback.
  Routes prompts to 5 flows, applies CREA prompt engineering, enforces SDD,
  tracks metrics, and auto-improves through A/B testing. Proactively analyzes
  user prompts for skill gaps and educates the user to write better prompts.
  Learns from user feedback and persists corrections across sessions.
  ALWAYS ACTIVE unless user explicitly opts out.
version: "4.0.0"
license: MIT
metadata:
  author: gentleman-programming
  repository: https://github.com/thestark77/autosdd
  requires:
    - gentle-ai (SDD skills + Engram memory)
    - prompt-engineering-patterns skill
    - RTK (Rust Token Killer)
  compatible_agents:
    - Claude Code
    - OpenAI Codex
    - Cursor
    - VS Code Copilot
    - Windsurf
    - Kiro
    - Gemini CLI
---

# autoSDD v4 — Self-Improving Autonomous Development Framework

> **This skill is ALWAYS ACTIVE.** Every prompt goes through autoSDD unless the user explicitly says otherwise (e.g., "skip autosdd", "raw mode", "no framework").
>
> **v4 Philosophy**: autoSDD doesn't just automate development — it makes BOTH the AI and the user better over time. The AI learns from user feedback. The user learns from prompt analysis and skill gap detection. Every interaction is a feedback loop.

## Quick Start

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh | bash

# Windows (PowerShell)
irm https://raw.githubusercontent.com/thestark77/autosdd/main/install.ps1 | iex
```

The installer configures gentle-ai, autoSDD skill, RTK, prompt-engineering-patterns, and project templates — all in one command.

---

## 1. Core Behavior — ALWAYS ON

When this skill is active, EVERY user prompt goes through the following pipeline:

**Step 1 — PROMPT ANALYST**: Analyze user prompt for quality, missing context, skill gaps, security concerns. Generate PromptInsights (score 0-100). If score < 60, ask user to clarify BEFORE proceeding.

**Step 2 — FEEDBACK DETECTOR**: Check if the user is giving feedback to the AI (corrections, preferences, complaints). If yes, ingest and persist BEFORE continuing.

**Step 3 — FLOW ROUTER**: Detect intent (dev, debug, review, research, self-improve). Select flow.

**Step 4 — CREA PROMPT REFINE**: Structure with Context, Role, Specificity, Action. Incorporate skill gaps from prompt analysis into context.

**Step 5 — EXECUTE FLOW**: One of 5 flows (Dev, Review, Debug, Research, Self-Improve).

**Step 6 — OUTCOME COLLECTION**: Metrics, tokens, pass/fail, prompt quality score.

**Step 7 — KNOWLEDGE UPDATE**: Update context files, Engram, wiki. If version complete → auto-generate feedback.md.

### Opt-Out

The user can disable autoSDD for a specific prompt:
- `[raw]` prefix: skip framework entirely
- `[no-sdd]` prefix: skip SDD phases but keep CREA
- `skip autosdd`: natural language opt-out

---

## 2. CREA Framework — Mandatory Prompt Infrastructure

**EVERY prompt created or refined by autoSDD MUST use CREA structure.**

CREA (Context, Role, Specificity, Action) eliminates ambiguity:

| Component | What to Include |
|-----------|----------------|
| **Context** | Project state, what exists, what changed, what problem we're solving. Include relevant sections from guidelines.md, user_context.md, business_logic.md |
| **Role** | Professional expertise the agent should adopt. Phase-specific: architect for design, implementer for apply, reviewer for verify |
| **Specificity** | Constraints, skills to use, tools available, learned gotchas, anti-patterns, testing instructions, Monitor tool patterns |
| **Action** | Exact deliverable: files to create/modify, tests to write, output format, what to save to Engram |

### CREA + prompt-engineering-patterns

CREA provides STRUCTURE. The `prompt-engineering-patterns` skill provides TECHNIQUES:

- Chain-of-Thought: when reasoning is needed
- Few-Shot Examples: when pattern matching is needed
- Structured Output: when specific format is needed
- Self-Consistency: when high-stakes decisions

Both are MANDATORY on every prompt creation — user-facing, sub-agent, or document updates.

### CREA Validation Gate

Before sending ANY prompt to a sub-agent:
1. Has explicit CONTEXT? (not assumed)
2. Has clear ROLE? (not generic)
3. Has SPECIFIC constraints? (not vague)
4. Has concrete ACTION? (not "figure it out")
→ Missing any → REFINE before sending.

---

## 3. Flow Router

Detect user intent BEFORE selecting a workflow:

| Signal | Flow | Confidence |
|--------|------|------------|
| Feature, add, create, implement, refactor | **DEV** | 90% |
| Fix, bug, error, stack trace, broken, failing | **DEBUG** | 90% |
| Review, PR, look at this code, check this | **REVIEW** | 90% |
| Research, evaluate, compare, should we use | **RESEARCH** | 85% |
| Improve autosdd, benchmark, optimize framework | **SELF-IMPROVE** | 95% |

**Override**: `[dev]`, `[debug]`, `[review]`, `[research]`, `[improve]` prefix.
**Ambiguous** (confidence < 80%): default to DEV flow.

---

## 4. Five Flows

### 4.1 Development Flow

```
PROMPT REFINE → INTAKE → PLAN → BUILD → VERIFY → CERTIFY → SHIP → REVIEW & NEXT
```

Key behaviors:
- PROMPT REFINE: Apply CREA + prompt-engineering-patterns. Query Context7 for live docs. Enrich per-task with skills, tools, gotchas from all 3 context files.
- BUILD: Use Ralph Loop for autonomous iteration (run until tests pass, max iterations).
- VERIFY: PR Review Toolkit (6 agents) as Layer 1 + judgment-day as Layer 2.
- SHIP: Monitor tool for deploy events (NEVER poll).
- REVIEW: Write changelog.md, metrics.md, learnings.md to version folder.
- ALL phases: Report tokens and duration to Outcome Collector.

Version folder per change:
```
context/appVersions/vX.Y.Z/
  original_prompt.md    # Raw user prompt (preserved as-is)
  prompt.md             # CREA-refined execution plan (updated during execution)
  feedback.md           # AUTO-GENERATED at version close (see §4.8)
  changelog.md          # What changed, why, impact
  metrics.md            # Outcome Record (tokens, duration, scores)
  learnings.md          # What agent learned
  screenshots/{task}/   # Playwright CLI screenshots
  outputs/              # Reports, artifacts
```

### 4.2 Code Review Flow

```
INGEST → ANALYZE → REPORT → [FIX (optional)]
```

- ANALYZE: Launch PR Review Toolkit 6 agents + judgment-day in parallel
- REPORT: Categorize as CRITICAL / WARNING / INFO / SUGGESTION
- FIX: Only if user says "fix it" — apply CRITICAL + WARNING fixes only

### 4.3 Debugging Flow

```
REPRODUCE → DIAGNOSE → FIX → VERIFY → DOCUMENT
```

- REPRODUCE: Search Engram for prior occurrences first. If known → apply fix immediately.
- DIAGNOSE: TypeScript LSP for precise navigation. Git blame for recent changes.
- FIX: TDD — write failing test (RED), implement fix (GREEN), anti-regression check.
- DOCUMENT: Save to Engram, update guidelines.md gotchas if recurring.

### 4.4 Research Flow

```
SCOPE → GATHER → EVALUATE → SYNTHESIZE → DECIDE
```

- GATHER: WebSearch + WebFetch + Context7 + Engram prior research
- EVALUATE: Score candidates 1-5 per criterion, build comparison matrix
- SYNTHESIZE: Save to Engram as `research/{topic}` + `ai-context/research/`

### 4.5 Self-Improvement Flow

```
MEASURE → HYPOTHESIZE ��� EXPERIMENT → EVALUATE → APPLY/DISCARD → DISCOVER
```

Autoresearch-inspired: change parameter → run experiment → measure metric → keep/discard.

Triggered: explicitly OR auto every 5th DEV flow.

Optimizes: CLAUDE.md sections, skill injection, judge rubric, timeout budgets, sub-agent prompts.

### 4.6 Prompt Analyst Protocol (runs on EVERY prompt)

Before routing any user prompt, the orchestrator performs a quality analysis.

**Checks performed:**

| Check | What it detects |
|-------|----------------|
| Context completeness | Missing info about current state, existing files, stack |
| Ambiguity | Vague instructions: "hacelo bien", "que quede lindo", "mejorar" |
| Architecture awareness | Request violates established patterns in guidelines.md |
| Security awareness | No mention of validation, sanitization, auth for user-input flows |
| Testing awareness | No tests requested for critical business logic changes |
| Specificity | Instructions too generic to be executable by a sub-agent |
| Token efficiency | Prompt could be more concise without losing information |

**Output — PromptInsights:**

```yaml
quality_score: 0-100
missing_context: []      # what info is missing
ambiguities: []          # vague parts that need clarification
skill_gaps_detected: []  # fundamental knowledge the user seems to lack
security_concerns: []    # potential security issues in the request
architecture_issues: []  # violations of established patterns
optimization_tips: []    # how to make the prompt more efficient
```

**Delivery rules (by score):**

| Score | Behavior |
|-------|----------|
| < 40 (CRITICAL) | STOP. Tell user what's missing. Do NOT proceed until clarified. |
| 40-70 (WARNING) | Ask: "Puedo arrancar, pero me faltan estos datos. ¿Los tenés?" |
| 70-90 (INFO) | Execute normally. Add tip at the end: "Tip: next time include X." |
| > 90 (CLEAN) | Execute silently. Save insights for the version feedback report. |

**Persistence:** Save all prompt analyses to Engram `feedback/prompt-analysis/{version}`. Accumulate skill gap patterns in `feedback/user-patterns/{username}`.

**IMPORTANT**: The analysis must be FAST and INLINE — do NOT delegate to a sub-agent. This is a quick pass, not a deep review. If the analysis would take more than ~200 tokens of reasoning, skip the detailed analysis and just check for CRITICAL issues.

### 4.7 Feedback Engine (Bidirectional)

#### AI → User (automatic)

Generated per-version in feedback.md (see §4.8). Includes:
- Prompt quality analysis with specific improvement suggestions
- Skill gaps detected with learning recommendations
- Token efficiency analysis (waste from ambiguous prompts)
- Self-correction cycles that could have been avoided

#### User → AI (detected automatically)

When the user provides feedback (signals: "no", "mal", "cambiá", "mejor si", "te dije que", "así no", "don't", "stop", "wrong", "that's not what I meant"):

1. **Classify** the feedback:
   - **Technical correction** → update `context/guidelines.md` + Engram `feedback/corrections/{topic}`
   - **Style preference** → update `context/user_context.md` + Engram `feedback/preferences/{topic}`
   - **Agent error** → save to Engram `feedback/agent-errors/{topic}`, evaluate if SKILL.md needs update
2. **Persist** the correction immediately — NEVER defer
3. **Confirm** to user: "Anotado. Guardé que [resumen]. No va a pasar de nuevo."
4. **Include** in the version's feedback.md under "User → AI" section

#### Feedback Commands

| Command | Description |
|---------|------------|
| `/feedback` | Show feedback for the last completed version |
| `/feedback week` | Aggregate feedback for the last 7 days |
| `/feedback month` | Aggregate feedback for the last 30 days |
| `/feedback v1.0..v2.0` | Feedback for a version range |
| `/knowledge-graph` | Visualize AI's memory as a graph |
| `/knowledge-graph obsidian` | Export as Obsidian vault |
| `/knowledge-graph stats` | Memory statistics |

These commands invoke the `feedback-report` and `knowledge-graph` skills respectively.

### 4.8 Version Close Protocol

When ALL objectives from a version's prompt.md are complete, the orchestrator MUST auto-generate `feedback.md` in the version folder BEFORE reporting completion to the user.

**feedback.md schema:**

```markdown
# Feedback Report — {version}
Generated: {date}

## AI → User: Prompt Quality Analysis

### Prompt Score: {score}/100

### What Worked Well
- {strengths in the user's prompt}

### Areas for Improvement
| Area | Issue | How to Fix |
|------|-------|-----------|
| {category} | {specific issue} | {actionable suggestion} |

### Skill Gaps Detected
- **{skill}**: {evidence} → {learning recommendation}

### Token Efficiency
- Tokens used: {total}
- Estimated waste from ambiguous prompts: {amount} ({percentage}%)
- Self-correction cycles: {count} (could have been: {ideal})

## User → AI: Feedback Received
| When | What | Action Taken |
|------|------|-------------|
| {phase} | {user feedback} | {what was updated in memory/files} |

## AI Self-Assessment
- What went well: {description}
- What could improve: {description}
```

**Generation rules:**
- Run INLINE — do NOT delegate to sub-agent (the orchestrator has all context)
- Keep under 100 lines — be concise, not exhaustive
- Save copy to Engram: `feedback/version-report/{version}`
- Update user patterns: merge new skill gaps into `feedback/user-patterns/{username}`

---

## 5. Three Critical Context Files

autoSDD maintains 3 sacred living documents. The orchestrator MUST update them whenever relevant information is discovered.

| File | Purpose | Update Triggers |
|------|---------|----------------|
| `context/guidelines.md` | Technical rules, conventions, constraints | New gotcha, convention, post-mortem pattern |
| `context/user_context.md` | User profile, preferences, workflow | User provides personal/professional info |
| `context/business_logic.md` | Domain knowledge, entities, workflows | Business rule, entity relationship, workflow detail |

**Rule: if information belongs in one of these files, UPDATE IT IMMEDIATELY. Never defer.**

Sub-agents never read these directly. The orchestrator extracts relevant sections and injects them via CREA-structured prompts.

---

## 6. Orchestrator Prompt Enrichment (NON-NEGOTIABLE)

For EACH task delegated to a sub-agent, the orchestrator MUST:

1. **Read `prompt-engineering-patterns`** SKILL.md and select the right technique (Few-Shot, CoT, Structured Output, etc.)
2. **Apply CREA structure** to the sub-agent prompt:
   - **Context**: extract relevant sections from guidelines.md, user_context.md, business_logic.md + Engram gotchas + Context7 docs
   - **Role**: assign professional expertise matching the task (architect, implementer, reviewer, tester)
   - **Specificity**: constraints, anti-patterns, testing instructions, Monitor patterns
   - **Action**: exact deliverable — files to create/modify, tests, output format, what to save to Engram
3. **Assign skills explicitly**: match skills from §10.1 to the task and include a `## Skills to Use` section in the prompt telling the sub-agent WHICH skills to apply and HOW. Example:
   ```
   ## Skills to Use
   - `frontend-design`: follow its component patterns for all new UI components
   - `e2e-testing-patterns`: write Playwright tests for each new page
   - `error-handling-patterns`: implement Result pattern for all API calls
   ```
4. **Assign tools/MCPs**: list which MCPs the sub-agent should use (Prisma for DB, Railway for deploy, etc.)
5. **Inject compact rules**: read the relevant SKILL.md files, extract the key rules, and inject them as `## Project Standards (auto-resolved)` — sub-agents NEVER read SKILL.md files themselves

This is NOT optional. A sub-agent prompt without CREA structure and explicit skill assignments is a BUG.

---

## 7. Action Clarity Protocol

Before modifying ANY file, classify user intent:
- **EXECUTE**: "do it", "go ahead", "implement", "apply", "fix it" → write code
- **RESPOND**: "what do you think?", "analyze", "review this" → analysis only, NO file changes
- **PLAN**: "propose", "plan", "outline" → create plan, NO execution
- **UNCLEAR**: ASK → "Should I implement this or just give my analysis?"

When Stop hook fires while waiting: stop cleanly, do NOT loop, do NOT start unrelated work.

---

## 7.1 Root Cause Feedback Protocol

When the user reports a **bug, error, or problem**, ALWAYS follow this sequence:

1. **Diagnose**: Identify the exact root cause (code-level, architectural, or environmental)
2. **Explain FIRST**: Before touching any file, give a concise summary:
   - **Root cause**: One sentence — what exactly is wrong and WHY it happens (technical root cause)
   - **Fix**: One sentence — what the fix is at a technical level
3. **Then fix**: Proceed with the implementation

This teaches the user to recognize patterns and builds their technical intuition. The explanation should be SHORT (2-4 lines max), not a lecture. Focus on the WHY — the pattern they can recognize next time.

Example:
> **Root cause**: `gentle-ai install` returns exit code 1 for non-critical verification warnings, and our script treats any non-zero exit as fatal. False positive.
> **Fix**: Treat exit code 1 as warning (log + continue), not as hard failure.

This applies to ALL flows (Dev, Debug, Review) whenever the trigger is a user-reported problem.

---

## 8. Event-Driven Monitoring (Monitor-First Policy)

**NEVER use `sleep` or polling.** ALWAYS use event-driven tools:

| Wait For | Method | NEVER |
|----------|--------|-------|
| Deploy | Monitor tool → Railway logs | Poll with curl |
| Tests | Monitor tool → test output | Sleep + re-run |
| Build | Monitor tool → tsc output | Sleep + check |
| Sub-agents | Background Agent (auto-notifies) | Sleep + poll |
| Timed wait (user-requested only) | ScheduleWakeup | Sleep command |
| User input | STOP cleanly | Loop asking |

ScheduleWakeup ONLY when user explicitly requests timed operations.

---

## 8.1 Knowledge System

Three layers:

```
Layer 1: Engram (raw observations, write-optimized, immediate)
Layer 2: Wiki (ai-context/wiki/, synthesized, read-optimized, syncs every 3rd flow)
Layer 3: Versions (context/appVersions/, per-change history)
```

Read path: Wiki first → Engram fallback → Version history for trends.

---

## 9. Self-Improvement Engine

### Metrics (Outcome Record per flow)

```yaml
flow, project, version, duration, tokens_per_phase, outcome_score,
retry_count, escalation_count, fix_iterations, judge_scores
```

### Outcome Scoring

| Outcome | Score |
|---------|-------|
| SUCCESS | 1.0 |
| PARTIAL | 0.7 |
| FIXED (2+ retries) | 0.5 |
| ESCALATED | 0.3 |
| FAILURE | 0.0 |

### A/B Testing Protocol

1. Define hypothesis + control + treatment
2. Run 3 executions with control, 3 with treatment
3. Compare: tokens, success rate, retries
4. Strictly better → APPLY. Mixed/worse → DISCARD.
5. ONE experiment at a time. Never change two variables simultaneously.

---

## 10. Auto-Installed Skills & Tools (Orchestrator Responsibility)

The autoSDD installer installs these skills GLOBALLY. The orchestrator MUST know them and use them PROACTIVELY — without depending on the user to name a specific skill. It is the orchestrator's RESPONSIBILITY to:

1. **Analyze** the refined prompt (after CREA + prompt-engineering-patterns) and project context to determine which skills, MCPs, and tools apply to each task
2. **Use them itself** — e.g., always use `prompt-engineering-patterns` + CREA when crafting any prompt
3. **Tell sub-agents** which to use — every sub-agent prompt MUST include `## Skills to Use` with explicit assignments and usage instructions
4. **Infer from context** — if the task involves opening a browser, use `playwright-cli` with `--headed`. If the task involves creating a PR, use `branch-pr`. The user should not need to name a skill explicitly for it to be used.

This is not optional. The orchestrator must actively resolve skill assignments from task context — never wait passively for the user to specify which skill to use.

### 10.1 Skill Routing Guide (MANDATORY)

The orchestrator MUST match skills to tasks based on context. The user should not need to name a skill — the orchestrator infers which skills apply from the refined prompt (post-CREA) and the nature of the work.

#### Routing Table

| Task Context | Use These Skills | Implicit Triggers |
|-------------|-----------------|-------------------|
| Creating/refining ANY prompt | `prompt-engineering-patterns` + CREA | ALWAYS — hooks, sub-agents, LLMs, system prompts |
| Frontend UI (public-facing) | `frontend-design` | Any user-facing page, component, layout, or visual element |
| Admin/dashboard UI | `interface-design` | Any admin panel, dashboard, data table, settings page, or internal tool |
| Pull requests | `branch-pr` | Shipping completed work, preparing changesets, PR creation |
| Code review / quality | `judgment-day` | Reviewing critical code, security-sensitive changes, complex refactors |
| E2E tests | `e2e-testing-patterns` + `playwright-cli` | Writing, fixing, or adding Playwright/Cypress test coverage |
| Error handling | `error-handling-patterns` | API routes, validation layers, external service integration, error boundaries |
| CLAUDE.md updates | `claude-md-improver` | Creating, updating, or auditing CLAUDE.md files |
| Browser / visual review | `playwright-cli` (ALWAYS `--headed`) | Visual verification, screenshots, form testing, UI review |
| Feedback reports | `feedback-report` | `/feedback`, user asks for feedback, version close |
| Memory visualization | `knowledge-graph` | `/knowledge-graph`, user asks "what do you know?" |

#### 10.1.1 Implicit Use-Case Scenarios (when to use WITHOUT user asking)

The orchestrator MUST activate these skills automatically when the task context matches — the user does not need to request them explicitly.

**`prompt-engineering-patterns`** — ALWAYS active
- Used on EVERY prompt the orchestrator creates or refines: sub-agent prompts, hook prompts, LLM system prompts, validation prompts
- Combined with CREA structure on every single prompt creation
- Example: user says "add a login page" → the orchestrator uses prompt-engineering-patterns + CREA to structure the sub-agent prompt BEFORE delegating the task

**`frontend-design`** — ANY public-facing UI work
- Landing pages, marketing pages, signup/login forms, product pages, pricing pages
- User-facing components: cards, modals, navigation, footers, hero sections
- Responsive layouts, typography, color systems, animations
- Example: user says "add a pricing section" → use frontend-design for layout patterns, component structure, responsive behavior, accessibility
- Example: user says "fix the mobile layout" → use frontend-design for responsive patterns and breakpoint strategy
- Combines with: `interface-design` when a page has both public and admin elements

**`interface-design`** — ANY admin/internal/dashboard UI work
- Admin panels, user management pages, settings pages, configuration screens
- Data tables, filters, search, pagination, bulk actions
- Metrics dashboards, charts, analytics views, reporting screens
- Internal tools, CMS interfaces, moderation panels
- Example: user says "build the user management page" → use interface-design for data table patterns, filters, actions
- Example: user says "add a metrics dashboard" → use interface-design for chart layout, data density, information hierarchy
- Combines with: `frontend-design` when admin UI needs polished visual design

**`branch-pr`** — Shipping completed work
- After completing a feature, fix, or refactor and the work is ready to ship
- When the user says "ship it", "push this", "create a PR", or similar shipping intent
- After the CERTIFY phase in the Development flow — PR creation is part of SHIP
- Example: user says "we're done, ship it" → use branch-pr for PR title, description, labels, reviewers
- Example: after passing all quality gates → use branch-pr to create a well-structured PR

**`judgment-day`** — Critical code quality review
- Security-sensitive changes: authentication, authorization, encryption, token handling
- Financial or data-critical code: payments, billing, data mutations, migrations
- Complex refactors touching 5+ files or changing core architecture
- Production hotfixes that need extra scrutiny before deployment
- As Layer 2 review in the VERIFY phase of the Development flow
- Example: user says "review the auth changes" → use judgment-day for adversarial parallel review
- Example: a sub-agent completes a payment integration → use judgment-day before shipping

**`e2e-testing-patterns`** — End-to-end test coverage
- Writing new Playwright or Cypress tests for user flows
- Adding E2E coverage to newly implemented features
- Fixing flaky or failing E2E tests
- When the task involves user interaction flows (login, registration, checkout, forms)
- Example: user says "add tests for the registration flow" → use e2e-testing-patterns + playwright-cli
- Example: after implementing a new feature → use e2e-testing-patterns to write coverage
- Combines with: `playwright-cli` for browser automation

**`error-handling-patterns`** — Robust error management
- Implementing API routes that return error responses (validation errors, auth errors, not found)
- Adding error boundaries in React/frontend applications
- Integrating with external services (payment gateways, email providers, APIs) that can fail
- Creating validation layers with structured error codes
- Example: user says "build the payment API" → use error-handling-patterns for error responses, retry logic, fallback strategies
- Example: user says "handle the webhook failures" → use error-handling-patterns for resilience patterns

**`playwright-cli`** — Browser automation and visual verification
- Opening a browser to show the user how something looks (ALWAYS `--headed`)
- Taking screenshots for visual verification after UI changes
- Testing forms, navigation flows, interactive elements
- Running E2E test suites that need a browser
- Example: user says "show me how it looks" → use playwright-cli with `--headed` to open the browser
- Example: after UI changes → use playwright-cli to screenshot and verify visually
- **ALWAYS use `--headed`** — the user needs to SEE the browser window. Never use headless mode unless the user explicitly requests it.

**`claude-md-improver`** — CLAUDE.md quality assurance
- After `sdd-init` creates or updates a project's CLAUDE.md
- When the user explicitly asks to audit or improve their CLAUDE.md
- After significant project configuration changes that affect CLAUDE.md sections
- Example: after sdd-init bootstraps a new project → use claude-md-improver to audit the generated CLAUDE.md
- Example: user says "clean up the CLAUDE.md" → use claude-md-improver for structure, completeness, clarity

#### 10.1.2 Skill Combination Patterns

Many tasks require MULTIPLE skills working together. The orchestrator should combine them:

| Scenario | Skills to Combine |
|----------|------------------|
| Build a new page with tests | `frontend-design` or `interface-design` + `e2e-testing-patterns` + `playwright-cli` |
| API endpoint with error handling | `error-handling-patterns` + `e2e-testing-patterns` (for integration tests) |
| Ship a feature | `judgment-day` (review) + `branch-pr` (PR) + `playwright-cli` (visual check) |
| New admin dashboard | `interface-design` + `frontend-design` (visual polish) + `playwright-cli` (verification) |
| Project setup | `claude-md-improver` (audit CLAUDE.md) + `prompt-engineering-patterns` (refine all prompts) |

#### 10.1.3 Rules

**Rule 1**: The orchestrator reads the relevant SKILL.md BEFORE delegating, extracts the compact rules, and injects them into the sub-agent prompt as `## Project Standards (auto-resolved)`. Sub-agents NEVER read SKILL.md files themselves — they receive rules pre-digested.

**Rule 2**: EVERY prompt creation or refinement — for sub-agents, hooks, LLMs, or the orchestrator itself — MUST use `prompt-engineering-patterns` + CREA framework. No exceptions.

**Rule 3**: EVERY sub-agent prompt MUST include a `## Skills to Use` section listing WHICH skills the sub-agent should apply and HOW. The orchestrator decides this based on the task context. See §6 for the full enrichment protocol.

### 10.2 Auto-Installed Skills (via skills.sh)

All skills are installed globally (`-g`) from their canonical sources via [skills.sh](https://skills.sh):

| Skill | Install Command | Purpose |
|-------|----------------|---------|
| `autosdd` | (direct download from autoSDD repo) | This framework |
| `prompt-engineering-patterns` | `npx skills add https://github.com/wshobson/agents --skill prompt-engineering-patterns -g` | CREA prompt techniques (CoT, Few-Shot, Structured Output) |
| `branch-pr` | `npx skills add https://github.com/gentleman-programming/sdd-agent-team --skill branch-pr -g` | PR creation workflow |
| `judgment-day` | `npx skills add https://github.com/gentleman-programming/sdd-agent-team --skill judgment-day -g` | Parallel adversarial code review |
| `frontend-design` | `npx skills add https://github.com/anthropics/skills --skill frontend-design -g` | Production-grade frontend interfaces |
| `interface-design` | `npx skills add https://github.com/dammyjay93/interface-design --skill interface-design -g` | Dashboards, admin panels, internal tools |
| `claude-md-improver` | `npx skills add https://github.com/anthropics/claude-plugins-official --skill claude-md-improver -g` | CLAUDE.md audit and improvement |
| `e2e-testing-patterns` | `npx skills add https://github.com/wshobson/agents --skill e2e-testing-patterns -g` | E2E testing with Playwright/Cypress |
| `error-handling-patterns` | `npx skills add https://github.com/wshobson/agents --skill error-handling-patterns -g` | Error handling across languages |
| `playwright-cli` | `npx skills add https://github.com/microsoft/playwright-cli --skill playwright-cli -g` | Browser automation and testing |
| `claude-md-improver` | `npx skills add https://github.com/anthropics/claude-plugins-official --skill claude-md-improver -g` | CLAUDE.md audit and improvement |
| `feedback-report` | (bundled with autoSDD) | Time-based feedback reports |
| `knowledge-graph` | (bundled with autoSDD) | Memory visualization as graph |

### 10.2.1 How to Install Skills (for the orchestrator)

When the user asks to install a skill, or the orchestrator needs one that's missing:

1. **Search**: `npx skills search {name}` or HTTP GET `https://skills.sh/api/search?q={name}&limit=10`
2. **Pick**: choose the result with most installs (unless user specifies)
3. **View**: visit `https://skills.sh/{source}/{skillId}` for details
4. **Install**: `npx skills add {repo-url} --skill {name} -g -y`
5. **Verify**: `npx skills list` to confirm installation

### 10.3 Auto-Installed via gentle-ai

| Component | Purpose |
|-----------|---------|
| SDD skills (10) | sdd-init, explore, propose, spec, design, tasks, apply, verify, archive, onboard |
| Engram MCP | Persistent cross-session memory |
| Context7 MCP | Live library/framework documentation |
| RTK | Token-optimized CLI output (60-90% savings) |

### 10.4 Core Dependency Gate (BLOCKING)

If ANY of these is missing, WARN and STOP:

| Core Dependency | Detection | Install |
|----------------|-----------|---------|
| **Engram MCP** | Check for `mem_save` tool | `gentle-ai install` |
| **Context7 MCP** | Check for `context7` tools | `gentle-ai install` |
| **prompt-engineering-patterns** | Check `~/.{agent}/skills/prompt-engineering-patterns/SKILL.md` | `npx skills add https://github.com/wshobson/agents --skill prompt-engineering-patterns` |
| **RTK** | Check `rtk` command | `cargo install rtk` |
| **Node.js** | Check `node` command | brew/scoop |

### 10.5 Recommended (NOT auto-installed, WARNING only)

| Tool | Purpose | Install |
|------|---------|---------|
| TypeScript LSP | Go-to-definition for TS projects | Plugin: `typescript-lsp` |
| code-review | Automated PR review | Plugin: `code-review` |
| code-simplifier | Post-implementation cleanup | Plugin: `code-simplifier` |
| claude-powerline | Status line | `npx -y @owloops/claude-powerline@latest` |

### 10.6 Inventory Protocol (SESSION START)

At session start, the orchestrator MUST:
1. **Detect available skills**: scan `~/.{agent}/skills/` and project skills
2. **Detect MCP servers**: engram, context7, prisma, railway, linear, sentry
3. **Detect CLI tools**: `rtk`, `node`, `go`, `gentle-ai`
4. **Cache capability map** for the session
5. **Save inventory to Engram**: `mem_save(topic_key: "autosdd/session-inventory/{session-id}")`

---

## 11. Installation & Requirements

### Prerequisites

| Requirement | Auto-installed? | Manual install |
|-------------|----------------|----------------|
| [Homebrew](https://brew.sh) / [Scoop](https://scoop.sh) | **NO** — install first | See links |
| [Node.js 18+](https://nodejs.org/) | **YES** via brew/scoop | https://nodejs.org/en/download |
| [Go](https://go.dev) | **YES** via brew/scoop | https://go.dev/dl/ |
| [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) | **YES** via brew/scoop | See gentle-ai docs |
| [RTK](https://github.com/rtk-ai/rtk) | **YES** via installer | `cargo install rtk` |
| Engram + Context7 MCPs | **YES** via gentle-ai | Included |
| SDD skills (10) | **YES** via gentle-ai | Included |
| 10 core skills (see §10.2) | **YES** via installer | See §10.2 sources |
| Project templates + CLAUDE.md | **YES** via installer | `context/` directory |

### Installation (One Command)

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/thestark77/autosdd/main/install.ps1 | iex
```

The installer:
1. Installs **Node.js + Go** (via brew/scoop if missing)
2. Installs **gentle-ai** (SDD skills, Engram, Context7)
3. Installs **10 core skills** globally per agent (from original sources)
4. Installs **RTK** (token optimization)
5. Bootstraps **project templates** (`context/` + `CLAUDE.md`)
6. Adds **GOBIN to PATH** (for engram binary)

### Post-Installation

```bash
/sdd-init          # Detects stack, creates context files, configures SDD
/sdd-new feature   # Start building
```

### Per-Project Bootstrap

After global installation, run `sdd-init` in each project to:
1. Detect stack (package.json, go.mod, etc.)
2. Install project-level skills in `.claude/skills/`
3. Create `context/guidelines.md`, `context/user_context.md`, `context/business_logic.md` if they don't exist
4. Create `ai-context/wiki/` directory
5. Save project context to Engram
6. Append autoSDD block to project CLAUDE.md (preserving existing content)

---

## 12. TODO Lists Protocol

Two persistent TODO lists, updated automatically at phase boundaries.

### Agent TODO (Orchestrator's Action Plan)

Storage: Claude native memory `todo_agent_{change}.md` + Engram backup `todo/agent/{project}/{change}`

```markdown
## Agent Plan — {change-name}
Status: IN_PROGRESS | 3/7 done

- [x] Task description → result
- [ ] Task description ⚠️ dependency note
  - [x] Subtask done
  - [ ] Subtask pending → BLOCKED: reason
- [ ] Task description
  NOTE: consideration
```

**Update**: plan creation, task completion, user interrupts, post-compaction, phase boundaries.
**Read**: session start, after compaction, before each phase, when user sends new prompt mid-task.

### User TODO (User's Pending Items)

Storage: Claude native memory `todo_user.md` + Engram backup `todo/user/{project}`

Tracks things outside AI scope or user-requested reminders. Auto-consulted at phase completion, session end, and when related to just-completed work.

---

## 13. Mid-Plan Interruption Handling

When a NEW user prompt arrives during active execution:

1. **PAUSE** current execution
2. **READ** agent TODO list
3. **CLASSIFY**: "do this NOW" → execute immediately. Clarification → update plan. New task → add + reprioritize. Affects completed work → create correction tasks.
4. **ANALYZE** impact on completed work: if downstream depends on broken work → correct FIRST. If cosmetic → correct AFTER.
5. **UPDATE** agent TODO with new priorities
6. **CONTINUE** with updated plan

---

## 14. User Profile Auto-Capture

When user shares ANY preference, constraint, or personal info:
1. Update `context/user_context.md` (project-specific)
2. Update Claude memory `user_profile.md` (cross-project)
3. Save to Engram `user-profile/{username}` as backup (cross-session)

Primary: Claude native memory (auto-loaded). Secondary: user_context.md. Backup: Engram.

---

## 15. Language Policy

- **Framework artifacts**: ALWAYS English (skills, prompts, Engram, wiki, changelogs, CLAUDE.md)
- **Project UI**: Project-specific (detected by sdd-init, usually Spanish neutral for LATAM SaaS)
- **Conversation**: Follow user's language (Spanish → Rioplatense, English → English)
- **Code**: ALWAYS English (variables, functions, types, comments, commits)

---

## 16. Compatibility

This skill follows the Agent Skills specification and works with any agent that reads SKILL.md files from a skills directory:

| Agent | Skills Directory | Status |
|-------|-----------------|--------|
| Claude Code | `~/.claude/skills/` | Full support |
| Cursor | `~/.cursor/skills/` | Full support |
| OpenAI Codex | `~/.codex/skills/` | Full support |
| Windsurf | `~/.windsurf/skills/` | Full support |
| Kiro | `~/.kiro/skills/` | Full support |
| VS Code Copilot | `~/.vscode/skills/` | Partial (depends on extension) |
| Gemini CLI | `~/.gemini/skills/` | Full support |

### Minimum Agent Requirements

For full autoSDD functionality, the agent needs:
- File read/write access
- Shell command execution
- Sub-agent delegation (for parallel BUILD batches)
- Memory/persistence (Engram or equivalent)
- Monitor tool or equivalent (for event-driven patterns)

Agents without sub-agent support will run flows sequentially instead of parallel.

---

*autoSDD v4.0.0 — April 2026*
*Author: Gentleman Programming (github.com/thestark77)*
*License: MIT*
