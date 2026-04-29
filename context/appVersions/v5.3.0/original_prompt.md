---
conversation_id: 57882c2c-81d4-4d7a-965b-674434bf58a6
date: 2026-04-29
---
Perfecto, me gusta. Crea una nueva versión de autoSDD con estos cambios; empiézalos a aplicar desde ya en esta ejecución, en esta sesión. Una vez todo esté listo, commit, push, actualiza autoSDD como dependencia propia con dogfooding y luego, en paralelo, actualízalo en Bemovil y en prohuella

## Context (from conversation)
Two changes agreed upon:
1. PROGRESS.md cleanup: Reset to clean state when starting a new version (Step 0). History lives in changelog.md per version + Engram.
2. Additional Instructions tracking: When user gives mid-pipeline instructions that change scope, append to prompt.md under `## Additional Instructions` with timestamp. Survives compaction since prompt.md is already read post-compaction.
