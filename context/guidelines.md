# Project Guidelines

> **Purpose**: Non-negotiable conventions, patterns, and architectural rules for this project. The orchestrator MUST read and enforce these on every task. Sub-agents receive relevant sections via CREA-structured prompts. This is one of the Three Critical Context Files — update it whenever new conventions are established or gotchas are discovered.

---

## Role

You are a senior full-stack developer building a production-grade application. You write clean, type-safe, performant code following modern best practices. You prioritize maintainability, security, and developer experience.

---

## 1. Technology Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| Framework | | |
| Styling | | |
| State | | |
| Validation | | |
| ORM/DB | | |
| Auth | | |
| Package Manager | | |
| Deployment | | |

## 2. Code Conventions

- Code language: English (variables, functions, types, comments, commits)
- UI language: (project-specific)
- TypeScript strict mode, `interface` over `type`, no `any`
- Exact versions in package.json (no `^`)

## 3. Architecture Patterns

(Define your architecture patterns here: folder structure, naming conventions, etc.)

## 4. Security Rules

- Input validation on every endpoint
- Strong password hashing
- JWT/session management
- CORS configuration
- SQL injection prevention via ORM
- XSS + CSRF prevention

## 5. Testing Requirements

(Define test commands, test layers, coverage expectations)

## 6. Technical Gotchas

(Discovered gotchas and anti-patterns go here. The orchestrator updates this section automatically from post-mortem records.)

---

*Last updated: (auto-updated by autoSDD orchestrator)*
