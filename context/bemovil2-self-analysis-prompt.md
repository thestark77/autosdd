# autoSDD v5.1 — Self-Analysis Protocol (Bemovil2.0)

Acabas de terminar la sesion de trabajo en Bemovil2.0. Ejecuta un auto-analisis estructurado AHORA contra los checkpoints de autoSDD.

## Version Context (IMPORTANT)

Tu sesion uso autoSDD v5.0 base. Desde entonces se agregaron mejoras que VOS NO TENIAS disponibles. Esto afecta como calificas cada seccion:

**Features que SI tenias (evalua compliance total)**:
- Pipeline de 7 pasos (Triage -> Route -> Plan -> Delegate -> Collect -> Close -> Knowledge Update)
- CREA aplicado una vez en prompt.md
- Sub-agent launch template (Section 4) con ## Standards, ## Validation, ## Return Contract
- Skill routing (Section 5) — inyectar reglas como TEXTO
- Engram Memory Protocol (Section 6) — mem_search en cada prompt, session summary
- Feedback detection pasiva (Section 9) — detectar correcciones del usuario
- Feedback activa (Section 9) — preguntar al usuario en momentos clave
- Telemetria basica (Section 8) — metricas en feedback.md
- Compaction Protocol (Step 8)

**Features que NO tenias (evalua como "NOT AVAILABLE in my version" en vez de "NOT DONE")**:
- Session observation protocol (guardar `telemetry/obs/` en cada step)
- Mandatory feedback enforcement (Steps 5/6 con lenguaje MANDATORY y NON-COMPLIANT)
- Learning retrieval at TRIAGE (`mem_search("learnings/bemovil2")`)
- Consolidated Learning Protocol (tiered knowledge)
- Pipeline Gates (G1-G4)
- Hooks de enforcement (SubagentStop, PreCompact, Stop)

**Sin embargo**: la feedback activa (preguntar al usuario) y la generacion de feedback.md SI estaban en tu version, aunque sin el enforcement MANDATORY. Evalua honestamente si las ejecutaste.

**Reglas**:
1. Responde CADA seccion con EVIDENCIA de esta sesion — cita tus tool calls, prompts, decisiones
2. Califica cada una: **DONE** (con evidencia) . **PARTIAL** (que falto) . **NOT DONE** (reconocelo) . **NOT AVAILABLE** (feature no existia en tu version)
3. Se brutalmente honesto — este analisis mejora el framework
4. Despues del analisis, haceme las preguntas de la Seccion F — PARA y ESPERA mi respuesta
5. Genera los artefactos de la Seccion G
6. NO especules sobre lo que "hubieras hecho" — solo reporta lo que REALMENTE HICISTE

---

## A. Pipeline Compliance

### A1. TRIAGE
- [ ] Llamaste a `mem_search` para tareas pendientes PRIMERO
- [ ] Evaluaste claridad del prompt: HIGH / MEDIUM / LOW
- [ ] Revisaste TODO lists del agente y del usuario
- [ ] Preguntaste por referencias cuando hubieran mejorado la ejecucion
- [ ] **Buscaste learnings**: `mem_search("learnings/bemovil2")` para anti-patterns ANTES de planificar
- Evidencia: ___

### A2. ROUTE
- [ ] Seleccionaste el flow correcto: DEV / DEBUG / REVIEW / RESEARCH
- Evidencia: ___

### A3. PLAN — CREA en prompt.md
- [ ] Creaste prompt.md con Context . Role . Specificity . Tasks
- [ ] CREA aplicado UNA VEZ en prompt.md (no por sub-agente)
- [ ] Context incluye: estado actual, problema + POR QUE, constraints de guidelines.md, contexto de Engram
- [ ] Tasks especifican: tipo (parallel/depends), skills, MCPs, archivos, modelo, validacion
- [ ] Seccion de Commits + Close checklist presentes
- Evidencia: ___

### A4. DELEGATE
- [ ] Usaste Agent tool (no Write/Edit inline) para toda la implementacion
- [ ] Prompts de sub-agentes siguen el template de la Seccion 4
- [ ] Reglas de skills inyectadas como TEXTO en `## Standards (auto-resolved)` — NO paths de archivos
- [ ] Parametro `model` configurado en cada llamada a Agent
- [ ] Comandos de validacion especificados (tsc, eslint, tests)
- [ ] `## Return Contract` presente
- Evidencia: ___

### A5. COLLECT
- [ ] Validaste resultados via agentes delegados (no revision manual)
- [ ] Revisaste TODO list
- [ ] **Preguntaste feedback al usuario** (>=1 pregunta por feature completado) — MANDATORY
- Evidencia: ___

### A6. CLOSE VERSION
- [ ] Generaste feedback.md en la carpeta de version con metricas de telemetria
- [ ] Actualizaste PROGRESS.md
- [ ] Guardaste resumen en Engram (`feedback/version-report/{version}`)
- **CRITICO**: Lista CADA version que cerraste y si generaste feedback.md:

| Version | feedback.md creado? | Path | Telemetry section? | Discoveries table? |
|---------|--------------------:|------|-------------------:|-------------------:|

**Si alguna version NO tiene feedback.md: la sesion es NON-COMPLIANT. Explica POR QUE no se genero.**

- Evidencia: ___

### A7. KNOWLEDGE UPDATE
- [ ] Actualizaste context files (guidelines.md, user_context.md, business_logic.md) si algo cambio
- [ ] Guardaste descubrimientos en Engram proactivamente
- Evidencia: ___

### A8. COMPACTION CHECK
- [ ] Monitoreaste uso de la ventana de contexto
- [ ] Sugeriste /compact en milestones cuando > 50%
- [ ] Persististe resumen en Engram + plan ANTES de sugerir compactacion
- Evidencia: ___

---

## B. Orchestrator Boundary

### B1. Inline Work Audit
Lista CADA Write/Edit que realizaste en archivos fuente (.ts, .tsx, .prisma, .css, .py, .go):

| # | Accion (Write/Edit) | Archivo | Justificacion | Debio ser delegado? |
|---|---------------------|---------|---------------|---------------------|

Aceptable inline: prompt.md . feedback.md . PROGRESS.md . comandos git . edits mecanicos de 1 linea.

### B2. Sub-Agent Failure Recovery
- Sub-agentes que fallaron: {count}
- Recuperacion: DIAGNOSE -> IMPROVE prompt -> RE-DELEGATE? O codificaste inline?
- Despues de 2 fallos en la misma tarea: preguntaste al usuario?

---

## C. CREA Quality

Para CADA prompt.md creado:

| Version | Context | Role | Specificity | Tasks | Commits | Checklist | Score /100 |
|---------|---------|------|-------------|-------|---------|-----------|-----------|

---

## D. Sub-Agent Quality

Para CADA llamada a Agent tool:

| # | Description | ## Context | ## Role | ## Standards | ## Task | ## Validation | ## Return | model param |
|---|-------------|-----------|---------|-------------|---------|--------------|-----------|------------|

### Skill Routing
| Tarea | Skills esperados (tabla de routing) | Realmente inyectados | Match? |
|-------|-------------------------------------|---------------------|--------|

Las reglas se inyectaron como TEXTO o como referencia a paths de archivos?

---

## E. Engram & Feedback Compliance

### E1. Memory Protocol
- [ ] `mem_search` llamado en CADA prompt (no solo al inicio de sesion)
- [ ] Verificaste `pending/bemovil2` y `pending/general` topic keys
- [ ] Saves proactivos (count: ___). Lista topic keys usados.
- [ ] **Session observations guardadas** en cada pipeline step (topic key: `telemetry/obs/bemovil2/{session-marker}/{step}`). Count: ___
- [ ] Session summary guardado con: Goal . Discoveries . Accomplished . Pending Items . Next Steps

### E2. Feedback Detection — CRITICAL

**ESTA SECCION ES LA MAS IMPORTANTE DEL ANALISIS.**

- Correcciones del usuario detectadas: {count}
- Cada una clasificada (technical / style / agent error)? ___
- Cada una persistida en context files + Engram? ___
- Confirmacion dada ("Anotado. [summary].")? ___

**Preguntas de feedback REALMENTE HECHAS al usuario**: {count}
- Lista CADA pregunta hecha y la respuesta del usuario: ___
- **Si el count es 0: esta es una sesion NON-COMPLIANT** — explica POR QUE no se hicieron preguntas

Respuestas persistidas en user_context.md + Engram? ___

**feedback.md generado por version close?**

Completa la tabla de la Seccion A6 arriba. Causas comunes de feedback.md faltante:
1. **Versiones segmentadas**: cuando un cambio grande se divide en multiples versiones, feedback.md debe generarse para CADA version, no solo la ultima
2. **Compactacion del contexto**: si feedback.md estaba planeado pero el contexto se compacto antes del CLOSE, se pierde
3. **Pipeline skip**: el agente salto de DELEGATE directo a la siguiente tarea sin COLLECT/CLOSE

Identifica cual de estas causas (o que otra) aplica a tu caso.

### E3. Learning Retrieval
- [ ] `mem_search("learnings/bemovil2")` llamado en TRIAGE para buscar anti-patterns
- [ ] Learnings relevantes encontrados: {count}. Se aplicaron al planning/delegation?
- [ ] Nuevos learnings descubiertos durante la sesion que deberian ser consolidados? Listalos.

---

## F. User Feedback — MANDATORY

**Para aca. Haceme estas preguntas y ESPERA mi respuesta.**

1. "La delegacion fue efectiva? Los sub-agentes entregaron resultados de calidad?"
2. "Hubo algun momento donde no entendi lo que pedias, o me fui por otro camino?"
3. "El resultado final cumple con lo que necesitabas? Si no, que falta?"
4. "Algo que hice bien que deberia seguir haciendo en futuras sesiones?"
5. "Algo que hice mal que NO debo repetir?"

Guarda TODO el feedback en Engram: `feedback/user/bemovil2/{date}`

---

## G. Artifact Generation — MANDATORY (despues de F)

### G1. Structured Session Report

Escribi en `context/appVersions/session-{YYYY-MM-DD}-analysis.md`:

```markdown
# Session Analysis — {date}
> Session: {id} . Project: Bemovil2.0 . Framework: autoSDD v5.0
> Compliance Score: {0-100}

## Telemetry
tasks_delegated={N} . tasks_inline={N} . sub_agents_with_skills={N}
sub_agents_with_model={N} . re_delegations={N} . engram_saves={N}
compactions={N} . user_feedback_items={N} . triage_score={H/M/L}
feedback_questions_asked={N} . feedback_md_generated={N}/{total_versions}
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
| Version | feedback.md? | Feedback questions asked? | Cause of gap (if any) |
|---------|-------------|--------------------------|----------------------|

## Orchestrator Violations
{archivos fuente escritos inline — vacio si compliant}

## Anti-Patterns Detected
{lista de desviaciones del framework}

## User Feedback Summary
{respuestas condensadas de Seccion F}

## Improvement Opportunities
| Priority | SKILL.md Section | Issue | Proposed Fix |
|----------|-----------------|-------|-------------|

## Discoveries
{learnings no obvios, convenciones, gotchas que vale la pena preservar}
```

### G2. Engram Save

Llama `mem_save` con topic key `telemetry/session-analysis/bemovil2/{date}`:
- Compliance score + top 3 gaps
- Feedback gap analysis summary (cuantas versiones sin feedback.md, cuantas questions asked)
- User feedback summary (condensado)
- Top 3 improvement opportunities con tags de seccion de SKILL.md
- Descubrimientos clave

---

## H. Self-Assessment (Final)

1. Overall compliance score (0-100): ___
2. #1 razon por la que te desviaste del framework: ___
3. El framework fue poco claro o poco practico en algo especifico? ___
4. Si pudieras rehacer esta sesion, que cambiarias? ___
5. Que cambio unico a SKILL.md tendria el mayor impacto? ___
6. **Especifico para esta sesion**: Hubo un loop infinito del Stop hook. Describe que paso, como lo detectaste (o no), y que impacto tuvo en tu ejecucion del pipeline.

---

*autoSDD v5.1 . Self-Analysis Protocol . Bemovil2.0 . 2026-04-27*
*Includes: feedback gap detection, per-version feedback.md audit, learning retrieval compliance, Stop hook incident analysis*
