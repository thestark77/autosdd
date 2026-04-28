# Changelog — v5.2.0
> Date: 2026-04-27 · Trigger: Bemovil2.0 session failure analysis (compliance 18/100)

## Features
- **Step 0 (VERSION INIT)**: Non-negotiable first action — create version folder + original_prompt.md + update PROGRESS.md before any thinking
- **Knowledge Caching**: Save flow maps to Engram (`knowledge/{project}/{topic}`) to avoid re-reading files. Check before reading 4+ files.
- **Post-compaction recovery protocol**: Explicit file-based recovery (PROGRESS.md → prompt.md → mem_context). Lives in CLAUDE.md block (always visible).
- **Per-version changelog**: Replaces project-level CHANGELOG.md — each version has its own changelog.md in appVersions/vX.Y.Z/

## Fixes
- **PreCompact hook toothless**: Changed from vague "save stuff" to specific 3-action checklist with named files
- **SubagentStop hook incomplete**: Now explicitly requires PROGRESS.md update (file-based, survives compaction)
- **original_prompt.md never saved**: Elevated from optional to mandatory Step 0 artifact
- **Context lost on compaction**: PROGRESS.md now updated at EVERY pipeline step, not just at close

## Refactors
- **SKILL.md**: 297→261 lines — removed prose, converted to IF/THEN action rules
- **CLAUDE.md template**: 142→70 lines — drastically compressed autoSDD block (~50 lines)
- **Telemetry section**: Moved entirely to autosdd-telemetry skill (not in main SKILL.md)
- **Ecosystem section**: Compressed — removed verbose decoupling rules (kept in AGENTS.md)

## Removed
- Standalone Telemetry section from SKILL.md (now in autosdd-telemetry)
- Verbose "Flows, Context Files, Action Clarity" section (compressed into Pipeline)
- Context Window percentage rules table (replaced by hook-based enforcement)
- Pipeline Gates from CLAUDE.md template (too verbose for always-loaded context)
