# Iron Man Mode — Roadmap

> "I am Iron Man."
> You speak. The system builds.

Iron Man Mode is the end state of AutoSDD — a fully autonomous development loop where the developer communicates intent via voice or text from any device, and the AI executes the full pipeline without hand-holding.

**Mobile interface**: [Remote Control](#phase-1--remote-control-available-now) (built into Claude Code) — no bot setup required.

---

## Vision

```
Developer: "Hey, add a bulk import feature for animal records from CSV. 
            Should support up to 10k rows, show progress, and send 
            a notification when done."

JARVIS: "Got it. A few questions before I start:
         1. Should failed rows be skipped or stop the import?
         2. Does the progress bar need real-time updates or is 
            a final count okay?
         3. Which roles can trigger bulk imports — admin only?"

Developer: "Skip failed rows, real-time progress, admin only."

JARVIS: "Clear. Starting now. I'll ping you when it's ready for review."

--- 45 minutes later ---

JARVIS: "Bulk import feature complete. 
         - 23 tests passing
         - E2E verified with 10k row CSV
         - Deployed to staging
         - PR #47 ready for your review: github.com/..."
```

This is not science fiction. Every component exists. The roadmap below describes how to assemble them.

---

## Architecture

```
┌──────────────────────────────────────────┐
│  INPUT LAYER                             │
│  Claude Mobile App (Remote Control)      │
│  Voice (audio message) or Text           │
└──────────────────────────────────────────┘
    ↓
┌──────────────────────────────────────────┐
│  PROCESSING LAYER                        │
│  1. Transcription (if voice)             │
│  2. Cleanup & punctuation                │
│  3. prompt-engineering-patterns skill    │
│  4. Structured SDD prompt output         │
└──────────────────────────────────────────┘
    ↓
┌──────────────────────────────────────────┐
│  CLARIFICATION LAYER                     │
│  AI generates focused questions          │
│  Sends via Remote Control session        │
│  Waits for user responses                │
│  Iterates until zero ambiguity           │
└──────────────────────────────────────────┘
    ↓
┌──────────────────────────────────────────┐
│  EXECUTION LAYER (AutoSDD)               │
│  Full pipeline: explore → certify        │
│  Runs locally on developer's machine     │
│  Self-corrects on failures               │
│  Escalates after 3 failed attempts       │
└──────────────────────────────────────────┘
    ↓
┌──────────────────────────────────────────┐
│  NOTIFICATION LAYER                      │
│  Completion: "PR #47 ready for review"  │
│  Blocker: "Can't proceed — need approval"│
│  Question: "Should X or Y?"             │
│  Error: "Failed 3x — need your help"   │
└──────────────────────────────────────────┘
```

---

## Phase 1 — Remote Control (Available Now)

### Goal
Connect your phone to your active Claude Code session. Send voice or text from anywhere. No bot setup, no API tokens.

### Setup (30 seconds)

1. Open Claude Code in your terminal
2. Run `/rc` (or start with `claude --rc`)
3. Scan the QR code with the Claude mobile app (iOS/Android)
4. Your phone is now a window into your development session

### What You Get

- **Full session access** — same project context, files, MCPs, and tools
- **Voice input** — send audio messages via Claude mobile; Claude transcribes and processes them
- **Real-time notifications** — Claude pings your phone when it needs input or finishes work
- **Inline keyboards** — approve/reject actions directly from mobile
- **Runs on Pro and Max plans** — no extra setup

### Why This Replaces Telegram Bots

| | Remote Control | Telegram Bot |
|--|--|--|
| Setup | Scan QR code | Create bot, configure API, host server |
| Auth | Anthropic account | Bot token + webhook |
| Context | Full session access | HTTP payload only |
| MCPs | All available | None |
| Voice | Built-in (Claude mobile) | Requires Whisper API |
| Cost | Included in plan | API costs + hosting |

Remote Control gives you everything a Telegram bot would — and more — with zero infrastructure.

---

## Phase 2 — Voice Input Processing

### Goal
Transform raw voice input (or unstructured text) into clean, SDD-ready prompts.

### Implementation

1. **Claude mobile app** receives audio message via Remote Control
2. **Transcription** handled natively by Claude mobile
3. **Cleaning** via `prompt-engineering-patterns` skill:
   - Add proper punctuation
   - Fix grammar
   - Structure into clear request format
4. **Output** — clean text ready for SDD orchestrator

### Prompt Engineering Skill Role

The `prompt-engineering-patterns` skill teaches the AI to:
- Extract intent from vague descriptions
- Identify implicit requirements
- Generate clarifying questions when ambiguous
- Structure output in SDD-ready format

```
Input (raw): "i want to be able to import animals in bulk from like a csv 
              or whatever, needs to work fast and let the admin know when done"

Output (structured): 
## Feature Request: Bulk Animal Import

**Intent**: Allow administrators to import multiple animal records at once 
from a CSV file.

**Identified requirements**:
- CSV file upload (format TBD)
- Batch processing for performance
- Completion notification to admin

**Ambiguities requiring clarification**:
1. Maximum file size / row count?
2. Error handling: skip invalid rows or fail entire import?
3. Notification method: in-app, email, or both?
4. Which admin roles can trigger import?
```

---

## Phase 3 — Proactive Clarification

### Goal
AI asks focused questions before execution, eliminating mid-implementation surprises.

### Protocol

```
1. AI analyzes structured prompt
2. Identifies ambiguities (requirement gaps, edge cases, scope questions)
3. Groups questions by priority (blocking vs. non-blocking)
4. Sends numbered question list via Remote Control (Claude mobile)
5. Waits for user response (async — user can reply hours later)
6. Integrates answers into SDD spec before execution starts
```

### Question Quality Rules

- **One concept per question** — never compound questions
- **Provide options when possible** — "A or B?" is easier than open-ended
- **Explain why each question matters** — user understands the impact
- **Maximum 5 questions per clarification round** — more means the feature is too vague

### Example Exchange

```
JARVIS → User:
Before I start building the bulk import, I need to clarify 4 things:

1. Error handling: If a row fails validation, should I:
   A) Skip it and continue (import partial batch)
   B) Stop and report all errors before importing anything

2. File limits: What's the maximum number of rows per import?
   (This affects whether I need a queue/job system)

3. Progress tracking: Should progress update in real-time (WebSocket) 
   or is a final "X imported, Y failed" summary enough?

4. Permissions: Admin-only, or can org managers also run imports?

User → JARVIS: A, 10k max, real-time, admin only

JARVIS → User: Got it. Starting now. Will ping you when done.
```

---

## Phase 4 — Notification System

### Goal
AI sends updates, questions, and completion notices via Remote Control (Claude mobile). Developer stays informed without checking manually.

### Message Types

| Type | When | Example |
|------|------|---------|
| Started | Execution begins | "Starting bulk import feature. ETA ~40 min." |
| Phase complete | Each SDD phase | "Spec complete. Starting implementation." |
| Blocker | 3 failed attempts | "Stuck on Redis integration. Need your input." |
| Approval needed | Before deployment | "Ready to deploy. Approve? [Yes] [No]" |
| Complete | Pipeline done | "Done. PR #47 ready: github.com/..." |
| Question | Mid-execution | "Found edge case: what should happen if...?" |

### Implementation

1. **Claude Remote Control** for message delivery (built into Claude Code)
2. **Inline keyboards** for approval buttons ([Yes] / [No] / [Later])
3. **Session continuity** — replies go to the active Claude Code session
4. **Rate limiting** — batch notifications to avoid spam

### Optional: Telegram/WhatsApp for External Event Triggers

Telegram or WhatsApp bots remain valid for one specific use case: **external event triggers** that originate outside your development session. For example:

- A CI/CD pipeline failure pings you via Telegram
- A production alert from Sentry routes through WhatsApp
- A team member sends a task via a shared bot

For these scenarios, the bot sends a webhook → Claude Code receives it → executes the task → responds via Remote Control or back through the bot.

Remote Control handles the interactive session. Telegram/WhatsApp handle external event ingestion.

---

## Phase 5 — Conversation Management

### Goal
System guides the conversation intelligently. Developer doesn't need to know SDD commands or execution order.

### Behaviors

**Optimal order suggestion**:
```
User: "Add bulk import AND fix the login bug AND redesign the dashboard"

JARVIS: "Got it — three things. I'd suggest this order:
         1. Fix the login bug first (unblocks everything else)
         2. Bulk import (most complex, needs full pipeline)
         3. Dashboard redesign (lowest risk, can run last)
         
         Start with the login bug?"
```

**Blocker tracking**:
```
JARVIS: "The bulk import is blocked — waiting on your decision about 
         error handling (Q1 from earlier). I'll work on the dashboard 
         redesign while you think about it."
```

**Proactive status updates**:
```
JARVIS: "Update: 2 of 3 tasks complete.
         ✅ Login bug fixed (PR #45 merged)
         ✅ Dashboard redesign (PR #46 in review)  
         ⏳ Bulk import — blocked on error handling decision
         
         What's your call on skipping vs. stopping on errors?"
```

---

## Tech Stack for Iron Man Mode

| Component | Technology | Notes |
|-----------|-----------|-------|
| Mobile interface | Claude Remote Control | Built into Claude Code — `/rc` or `claude --rc` |
| Voice transcription | Claude mobile app | Built-in, no Whisper API needed |
| Prompt processing | `prompt-engineering-patterns` skill | Runs inside Claude Code |
| Orchestration | AutoSDD pipeline | Runs on developer's machine |
| Notifications | Remote Control (Claude mobile) | Native push via Claude app |
| Job state | Engram | Persists job status across sessions |
| External triggers (optional) | Telegram Bot API | For CI/CD events, external system alerts |

---

## Implementation Priority

1. **Phase 1 (Remote Control)** — AVAILABLE NOW. Zero setup. Scan QR code, done.
2. **Phase 3 (Clarification)** — Highest ROI, already mostly doable with current Claude Code
3. **Phase 2 (Voice Processing)** — Handled natively by Claude mobile via Remote Control
4. **Phase 4 (Notifications)** — Native via Remote Control, no bot setup needed
5. **Phase 5 (Conversation Management)** — Most complex, requires state machine

---

## Status

| Phase | Status |
|-------|--------|
| Phase 1 — Remote Control | **AVAILABLE NOW** — built into Claude Code |
| Phase 2 — Voice Processing | Available via Claude mobile + Remote Control |
| Phase 3 — Proactive Clarification | Mostly doable with current Claude Code |
| Phase 4 — Notifications | Native via Remote Control |
| Phase 5 — Conversation Management | Roadmap — requires state machine |

The AutoSDD pipeline (explore → certify) is complete and production-ready. Iron Man Mode is the next frontier.

Contributions welcome — see the main README.
