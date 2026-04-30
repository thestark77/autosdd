# PROGRESS

## v6.0.0 — IN-PROGRESS

- [x] Phase 1a: Automation scripts (version-init.sh/.ps1, version-lint.sh/.ps1) — DONE
- [x] Phase 1b: Context Scout skill — DONE (integrated in SKILL.md Step 0.5, haiku model)
- [x] Phase 2: SKILL.md rewrite — DONE (261 lines, 11 sections, pipeline 9 steps, model assignments, event-driven, Engram protocol)
- [x] Phase 3: Hooks optimization — DONE (.claude/settings.json updated: utility agent exclusion, haiku delegation, event-driven reminder)
- [x] Phase 4: templates/CLAUDE.md updated to v6.0 — DONE (full pipeline, model assignments, context scout, routing, knowledge caching, compaction recovery)
- [x] Phase 5: Downstream sync — DONE
  - [x] be-code-kit templates/CLAUDE.md — pushed to feat/autosdd-v6.0-sync (v6.0 block + External Service Routing)
  - [x] be-code-kit templates/.claude/settings.json — pushed (v6.0 hooks)
  - [x] be-code-kit install.sh/install.ps1 — version string update (in-flight, background agent)
  - [x] be-code-kit README.md — v5.3 → v6.0 references (in-flight, background agent)
  - [x] be-code-kit PR creation — in-flight (background agent)
  - [x] Bemovil2.0 CLAUDE.md — updated to v6.0 block + External Service Routing
  - [x] Bemovil2.0 .claude/settings.json — updated to v6.0 hooks
  - [x] ProHuella CLAUDE.md — updated to v6.0 block, removed autoSDDv3.md reference
  - [x] Installed SKILL.md (~/.claude/skills/autosdd/SKILL.md) — copied v6.0
  - [x] Conversation 1b2e2926 — RESOLVED (Engram mandatory already covered by v6.0 Section 9)
  - [x] Research: e2e-forge Axiom + be-code-kit audit — DONE
- [x] Phase 6: Verification — DONE
  - [x] SKILL.md: 261 lines (< 300 hard, < 270 target)
  - [x] SKILL.md: 11 sections
  - [x] SKILL.md version: 6.0.0
  - [x] templates/CLAUDE.md: v6.0 (in sync)
  - [x] Project CLAUDE.md: v6.0 (in sync)
  - [x] Hooks: v6.0 (utility exclusion, haiku delegation, event-driven)
- [ ] Phase 7: Commits + push (autoSDD repo) — PENDING user confirmation
- [x] Presentation summary: context/be-code-kit-overview.md — DONE

### Pending / deferred
- e2e-forge: ad-hoc Axiom log query documentation — deferred (separate repo, ~800 line SKILL.md)
