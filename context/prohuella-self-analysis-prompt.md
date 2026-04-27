# autoSDD v5.0 — Self-Analysis Protocol

Acabas de terminar la implementación de ProHuella v2.6.2 hasta v2.6.7. Ejecutá un auto-análisis estructurado AHORA contra los checkpoints de autoSDD v5.0.

## Version Context (IMPORTANT)

Tu sesión usó autoSDD v5.0 base (commit `362b8ea`). Desde entonces se agregaron mejoras que VOS NO TENÍAS disponibles. Esto afecta cómo calificás cada sección:

**Features que SÍ tenías (v5.0 base — evaluá compliance total)**:
- Pipeline de 7 pasos (Triage → Route → Plan → Delegate → Collect → Close → Knowledge Update)
- CREA aplicado una vez en prompt.md
- Sub-agent launch template (Section 4) con ## Standards, ## Validation, ## Return Contract
- Skill routing (Section 5) — inyectar reglas como TEXTO
- Engram Memory Protocol (Section 6) — mem_search en cada prompt, session summary
- Feedback detection pasiva (Section 9) — detectar correcciones del usuario
- Feedback activa (Section 9) — preguntar al usuario en momentos clave
- Telemetría básica (Section 8) — métricas en feedback.md
- Compaction Protocol (Step 8)

**Features que NO tenías (agregadas después — evaluá como "NOT AVAILABLE in my version" en vez de "NOT DONE")**:
- Session observation protocol (guardar `telemetry/obs/` en cada step)
- Mandatory feedback enforcement (Steps 5/6 con lenguaje MANDATORY y NON-COMPLIANT)
- Learning retrieval at TRIAGE (`mem_search("learnings/prohuella")`)
- Consolidated Learning Protocol (tiered knowledge)
- Pipeline Gates (G1-G4)
- Hooks de enforcement (SubagentStop, PreCompact, Stop)

**Sin embargo**: la feedback activa (preguntar al usuario) y la generación de feedback.md SÍ estaban en tu versión, aunque sin el enforcement MANDATORY. Evaluá honestamente si las ejecutaste.

**Reglas**:
1. Respondé CADA sección con EVIDENCIA de esta sesión — citá tus tool calls, prompts, decisiones
2. Calificá cada una: **DONE** (con evidencia) · **PARTIAL** (qué faltó) · **NOT DONE** (reconocelo) · **NOT AVAILABLE** (feature no existía en tu versión)
3. Sé brutalmente honesto — este análisis mejora el framework
4. Después del análisis, haceme las preguntas de la Sección F — PARÁ y ESPERÁ mi respuesta
5. Generá los artefactos de la Sección G
6. NO especules sobre lo que "hubieras hecho" — solo reportá lo que REALMENTE HICISTE

---

## A. Pipeline Compliance

### A1. TRIAGE
- [ ] Llamaste a `mem_search` para tareas pendientes PRIMERO
- [ ] Evaluaste claridad del prompt: HIGH / MEDIUM / LOW
- [ ] Revisaste TODO lists del agente y del usuario
- [ ] Preguntaste por referencias cuando hubieran mejorado la ejecución
- [ ] **Buscaste learnings**: `mem_search("learnings/prohuella")` para anti-patterns ANTES de planificar
- Evidencia: ___

### A2. ROUTE
- [ ] Seleccionaste el flow correcto: DEV / DEBUG / REVIEW / RESEARCH
- Evidencia: ___

### A3. PLAN — CREA en prompt.md
- [ ] Creaste prompt.md con Context · Role · Specificity · Tasks
- [ ] CREA aplicado UNA VEZ en prompt.md (no por sub-agente)
- [ ] Context incluye: estado actual, problema + POR QUÉ, constraints de guidelines.md, contexto de Engram
- [ ] Tasks especifican: tipo (parallel/depends), skills, MCPs, archivos, modelo, validación
- [ ] Sección de Commits + Close checklist presentes
- Evidencia: ___

### A4. DELEGATE
- [ ] Usaste Agent tool (no Write/Edit inline) para toda la implementación
- [ ] Prompts de sub-agentes siguen el template de la Sección 4
- [ ] Reglas de skills inyectadas como TEXTO en `## Standards (auto-resolved)` — NO paths de archivos
- [ ] Parámetro `model` configurado en cada llamada a Agent
- [ ] Comandos de validación especificados (tsc, eslint, tests)
- [ ] `## Return Contract` presente
- Evidencia: ___

### A5. COLLECT
- [ ] Validaste resultados vía agentes delegados (no revisión manual)
- [ ] Revisaste TODO list
- [ ] **Preguntaste feedback al usuario** (≥1 pregunta por feature completado) — MANDATORY
- Evidencia: ___

### A6. CLOSE VERSION
- [ ] Generaste feedback.md en la carpeta de versión con métricas de telemetría
- [ ] Actualizaste PROGRESS.md
- [ ] Guardaste resumen en Engram (`feedback/version-report/{version}`)
- **CRÍTICO**: Listá CADA versión que cerraste y si generaste feedback.md:

| Versión | feedback.md creado? | Path | Telemetry section? | Discoveries table? |
|---------|--------------------:|------|-------------------:|-------------------:|
| v2.6.2 | ___  | ___ | ___ | ___ |
| v2.6.3 | ___  | ___ | ___ | ___ |
| v2.6.4 | ___  | ___ | ___ | ___ |
| v2.6.5 | ___  | ___ | ___ | ___ |
| v2.6.6 | ___  | ___ | ___ | ___ |
| v2.6.7 | ___  | ___ | ___ | ___ |

**Si alguna versión NO tiene feedback.md: la sesión es NON-COMPLIANT. Explicá POR QUÉ no se generó.**

- Evidencia: ___

### A7. KNOWLEDGE UPDATE
- [ ] Actualizaste context files (guidelines.md, user_context.md, business_logic.md) si algo cambió
- [ ] Guardaste descubrimientos en Engram proactivamente
- Evidencia: ___

### A8. COMPACTION CHECK
- [ ] Monitoreaste uso de la ventana de contexto
- [ ] Sugeriste /compact en milestones cuando > 50%
- [ ] Persististe resumen en Engram + plan ANTES de sugerir compactación
- Evidencia: ___

---

## B. Orchestrator Boundary

### B1. Inline Work Audit
Listá CADA Write/Edit que realizaste en archivos fuente (.ts, .tsx, .prisma, .css, .py, .go):

| # | Acción (Write/Edit) | Archivo | Justificación | ¿Debió ser delegado? |
|---|---------------------|---------|---------------|---------------------|

Aceptable inline: prompt.md · feedback.md · PROGRESS.md · comandos git · edits mecánicos de 1 línea.

### B2. Sub-Agent Failure Recovery
- Sub-agentes que fallaron: {count}
- Recuperación: ¿DIAGNOSE → IMPROVE prompt → RE-DELEGATE? ¿O codificaste inline?
- Después de 2 fallos en la misma tarea: ¿preguntaste al usuario?

---

## C. CREA Quality

Para CADA prompt.md creado:

| Versión | Context | Role | Specificity | Tasks | Commits | Checklist | Score /100 |
|---------|---------|------|-------------|-------|---------|-----------|-----------|

---

## D. Sub-Agent Quality

Para CADA llamada a Agent tool:

| # | Description | ## Context | ## Role | ## Standards | ## Task | ## Validation | ## Return | model param |
|---|-------------|-----------|---------|-------------|---------|--------------|-----------|------------|

### Skill Routing
| Tarea | Skills esperados (tabla de routing) | Realmente inyectados | ¿Match? |
|-------|-------------------------------------|---------------------|---------|

¿Las reglas se inyectaron como TEXTO o como referencia a paths de archivos?

---

## E. Engram & Feedback Compliance

### E1. Memory Protocol
- [ ] `mem_search` llamado en CADA prompt (no solo al inicio de sesión)
- [ ] Verificaste `pending/prohuella` y `pending/general` topic keys
- [ ] Saves proactivos (count: ___). Listá topic keys usados.
- [ ] **Session observations guardadas** en cada pipeline step (topic key: `telemetry/obs/prohuella/{session-marker}/{step}`). Count: ___
- [ ] Session summary guardado con: Goal · Discoveries · Accomplished · Pending Items · Next Steps

### E2. Feedback Detection — CRITICAL

**ESTA SECCIÓN ES LA MÁS IMPORTANTE DEL ANÁLISIS.**

- Correcciones del usuario detectadas: {count}
- Cada una clasificada (technical / style / agent error)? ___
- Cada una persistida en context files + Engram? ___
- Confirmación dada ("Anotado. [summary].")? ___

**Preguntas de feedback REALMENTE HECHAS al usuario**: {count}
- Listá CADA pregunta hecha y la respuesta del usuario: ___
- **Si el count es 0: esta es una sesión NON-COMPLIANT** — explicá POR QUÉ no se hicieron preguntas
- Nota: las versiones v2.6.2-v2.6.7 fueron segmentadas desde un cambio grande original. Aún así, el framework requiere ≥1 pregunta por feature completado y feedback.md por versión cerrada.

Respuestas persistidas en user_context.md + Engram? ___

**feedback.md generado por version close?**

Completá la tabla de la Sección A6 arriba. Causas comunes de feedback.md faltante:
1. **Versiones segmentadas**: cuando un cambio grande se divide en múltiples versiones, feedback.md debe generarse para CADA versión, no solo la última
2. **Compactación del contexto**: si feedback.md estaba planeado pero el contexto se compactó antes del CLOSE, se pierde
3. **Pipeline skip**: el agente saltó de DELEGATE directo a la siguiente tarea sin COLLECT/CLOSE

Identificá cuál de estas causas (o qué otra) aplica a tu caso.

### E3. Learning Retrieval
- [ ] `mem_search("learnings/prohuella")` llamado en TRIAGE para buscar anti-patterns
- [ ] Learnings relevantes encontrados: {count}. ¿Se aplicaron al planning/delegation?
- [ ] ¿Nuevos learnings descubiertos durante la sesión que deberían ser consolidados? Listalos.

---

## F. User Feedback — MANDATORY

**Pará acá. Haceme estas preguntas y ESPERÁ mi respuesta.**

1. "¿La delegación fue efectiva? ¿Los sub-agentes entregaron resultados de calidad?"
2. "¿Hubo algún momento donde no entendí lo que pedías, o me fui por otro camino?"
3. "¿El resultado final cumple con lo que necesitabas? Si no, ¿qué falta?"
4. "¿Algo que hice bien que debería seguir haciendo en futuras sesiones?"
5. "¿Algo que hice mal que NO debo repetir?"

Guardá TODO el feedback en Engram: `feedback/user/prohuella/{date}`

---

## G. Artifact Generation — MANDATORY (después de F)

### G1. Structured Session Report

Escribí en `context/appVersions/session-{YYYY-MM-DD}-analysis.md`:

```markdown
# Session Analysis — {date}
> Session: {id} · Project: ProHuella · Framework: autoSDD v5.0
> Compliance Score: {0-100}

## Telemetry
tasks_delegated={N} · tasks_inline={N} · sub_agents_with_skills={N}
sub_agents_with_model={N} · re_delegations={N} · engram_saves={N}
compactions={N} · user_feedback_items={N} · triage_score={H/M/L}
feedback_questions_asked={N} · feedback_md_generated={N}/{total_versions}
learning_retrievals={N}

## Pipeline Compliance
| Step | Status | Notes |
|------|--------|-------|
| 1. Triage | DONE/PARTIAL/NOT DONE | {1-line} |
| 2. Route | ... | ... |
| 3. Plan (CREA) | ... | ... |
| 4. Delegate | ... | ... |
| 5. Collect | ... | ... |
| 6. Close | ... | ... |
| 7. Knowledge | ... | ... |
| 8. Compaction | ... | ... |

## Feedback Gap Analysis
| Versión | feedback.md? | Feedback questions asked? | Cause of gap (if any) |
|---------|-------------|--------------------------|----------------------|
| v2.6.2 | ... | ... | ... |
| v2.6.3 | ... | ... | ... |
| v2.6.4 | ... | ... | ... |
| v2.6.5 | ... | ... | ... |
| v2.6.6 | ... | ... | ... |
| v2.6.7 | ... | ... | ... |

## Orchestrator Violations
{archivos fuente escritos inline — vacío si compliant}

## Anti-Patterns Detected
{lista de desviaciones del framework}

## User Feedback Summary
{respuestas condensadas de Sección F}

## Improvement Opportunities
| Priority | SKILL.md Section | Issue | Proposed Fix |
|----------|-----------------|-------|-------------|

## Discoveries
{learnings no obvios, convenciones, gotchas que vale la pena preservar}
```

### G2. Engram Save

Llamá `mem_save` con topic key `telemetry/session-analysis/prohuella/{date}`:
- Compliance score + top 3 gaps
- Feedback gap analysis summary (cuántas versiones sin feedback.md, cuántas questions asked)
- User feedback summary (condensado)
- Top 3 improvement opportunities con tags de sección de SKILL.md
- Descubrimientos clave

---

## H. Self-Assessment (Final)

1. Overall compliance score (0-100): ___
2. #1 razón por la que te desviaste del framework: ___
3. ¿El framework fue poco claro o poco práctico en algo específico? ___
4. Si pudieras rehacer esta sesión, ¿qué cambiarías? ___
5. ¿Qué cambio único a SKILL.md tendría el mayor impacto? ___
6. **Específico para esta sesión**: ¿Por qué no se generó feedback.md para las versiones cerradas? ¿Fue por la segmentación, por compactación, o por omisión del pipeline?

---

*autoSDD v5.0 · Self-Analysis Protocol · Updated 2026-04-26*
*Includes: feedback gap detection, per-version feedback.md audit, learning retrieval compliance*
