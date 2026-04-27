# autoSDD /improve — ProHuella Post-Analysis

Vas a ejecutar el ciclo `/improve` de autoSDD usando los resultados del self-analysis que el agente de ProHuella acaba de completar.

**Tu objetivo**: consumir las observaciones de la sesión de ProHuella (v2.6.2-v2.6.7), consolidarlas en learnings, y proponer mejoras concretas al framework.

---

## Version Context (IMPORTANT — read before evaluating)

La sesión de ProHuella usó autoSDD v5.0 base (commit `362b8ea`). Desde entonces se agregaron mejoras en 8 commits que el agente NO TENÍA disponibles. Esto afecta cómo interpretás el self-analysis report.

**Features que el agente SÍ tenía (evaluá compliance total — gaps en estas SÍ son failures)**:
- Pipeline de 7 pasos (Triage → Route → Plan → Delegate → Collect → Close → Knowledge Update)
- CREA aplicado una vez en prompt.md
- Sub-agent launch template (Section 4) con ## Standards, ## Validation, ## Return Contract
- Skill routing (Section 5) — inyectar reglas como TEXTO
- Engram Memory Protocol (Section 6) — mem_search en cada prompt, session summary
- Feedback detection pasiva (Section 9) — detectar correcciones del usuario
- Feedback activa (Section 9) — preguntar al usuario en momentos clave (SIN enforcement MANDATORY)
- Telemetría básica (Section 8) — métricas en feedback.md
- feedback.md generation por version close
- Compaction Protocol (Step 8)

**Features que el agente NO tenía (tratá como INFORMATIVO, NO como failures)**:
- Session observation protocol (guardar `telemetry/obs/` en cada step)
- Mandatory feedback enforcement (Steps 5/6 con lenguaje MANDATORY y NON-COMPLIANT)
- Learning retrieval at TRIAGE (`mem_search("learnings/prohuella")`)
- Consolidated Learning Protocol (tiered knowledge)
- Pipeline Gates (G1-G4)
- Hooks de enforcement (SubagentStop, PreCompact, Stop)

**Regla para el /improve agent**: cuando el self-analysis report marque algo como "NOT DONE" o "PARTIAL" que corresponde a una feature de la lista "NO tenía", NO lo incluyas en "What's Failing". Incluilo en una sección separada "Version Gap (informational)" para contexto, pero NO propongas fixes para gaps que ya fueron resueltos en commits posteriores. Enfocá los proposed changes en gaps de features que SÍ estaban disponibles.

**Nota**: la feedback activa (preguntar al usuario) y la generación de feedback.md SÍ estaban en la versión del agente, aunque sin enforcement MANDATORY. Si el agente no las ejecutó, eso SÍ es un gap legítimo.

---

## Paso 1: Recuperar contexto

```
mem_context
mem_search("telemetry/obs/prohuella")
mem_search("telemetry/session-analysis/prohuella")
mem_search("learnings/prohuella")
mem_search("feedback/user/prohuella")
```

Buscá TODAS las observaciones pendientes (Status: pending) y el session analysis report que el agente generó.

---

## Paso 2: Leer el self-analysis report

El agente de ProHuella generó un reporte estructurado en:
- `context/appVersions/session-*-analysis.md` (archivo local)
- Engram: `telemetry/session-analysis/prohuella/{date}`

Leé AMBOS. Extraé:
- Compliance score
- Feedback Gap Analysis (tabla de versiones con/sin feedback.md)
- Anti-patterns detectados
- Improvement opportunities
- User feedback summary (respuestas de la Sección F)

**Importante**: el self-analysis se ejecutó con una versión del prompt que NO tenía el Version Context section. El agente puede haber marcado como "NOT DONE" cosas que en realidad eran "NOT AVAILABLE" en su versión. Reclasificá según la tabla de Version Context (arriba) antes de consolidar.

---

## Paso 3: Consolidar observaciones en learnings

**Nota de versión**: el agente de ProHuella NO tenía el Session Observation Protocol, así que probablemente no haya observaciones en `telemetry/obs/prohuella`. Usá el self-analysis report como fuente primaria en vez de observaciones de Engram. Si hay observaciones guardadas retroactivamente, usalas también.

Aplicá el **Consolidated Learning Protocol** (autosdd-telemetry v2.1.0):

1. Agrupá las observaciones pendientes por TEMA (no por sesión/step)
2. Para cada tema con **2+ observaciones**: creá o actualizá un learning consolidado
3. Para cada tema con **1 observación + HIGH severity**: creá learning inmediatamente
4. Para cada tema con **1 observación + LOW/MED severity**: dejala pending (esperá recurrencia)

**Formato de learning** (5-8 líneas max):
```
mem_save({
  title: "Learning: {título descriptivo corto}",
  type: "learning",
  project: "prohuella",
  topic_key: "learnings/prohuella/{category}/{short-id}",
  content: `
    ## Learning: {título}
    **Category**: {category} · **Severity**: HIGH/MEDIUM/LOW
    **Source**: {observation IDs o session markers}
    **Pattern**: {cuándo aplica — condición trigger, 1 línea}
    **Rule**: {qué hacer o no hacer, 1-2 líneas}
    **Evidence**: {qué pasó que nos enseñó esto, 1 línea}
  `
})
```

**Categorías**: delegation · frontend · backend · testing · architecture · anti-patterns · user-preferences

---

## Paso 4: Leer el framework actual

```
Read: skill/SKILL.md
Read: skills/autosdd-telemetry/SKILL.md
Read: context/questions.md
Read: templates/CLAUDE.md
```

Necesitás saber el estado actual del framework para proponer cambios precisos.

**RESTRICCIÓN CRÍTICA**: `skill/SKILL.md` debe mantenerse bajo 300 líneas (actualmente 299). Cualquier adición requiere comprimir otra cosa.

---

## Paso 5: Generar plan de mejora

```markdown
# Improvement Plan — ProHuella v2.6.2-v2.6.7 Analysis

## What's Working
- {patrones que funcionaron consistentemente}

## What's Failing (only features AVAILABLE in agent's version)
| Issue | Frequency | Root Cause | Proposed Fix |
|-------|-----------|-----------|-------------|
| {issue} | {N/N sessions} | {por qué} | {cambio concreto a SKILL.md sección X} |

## Version Gap (informational — NOT failures)
| Feature missing | Already resolved in commit | Notes |
|----------------|--------------------------|-------|
| {feature} | {commit hash + title} | {context} |

> These gaps are expected — the agent used v5.0 base (commit `362b8ea`). Do NOT propose fixes for items already resolved in subsequent commits.

## Observations Consumed
| Session | Step | Key Finding | Action |
|---------|------|------------|--------|
| {marker} | {step} | {hallazgo} | {qué va a cambiar} |

## Learnings Created/Updated
| Category | Engram Key | Severity | Summary |
|----------|-----------|----------|---------|
| {cat} | `learnings/prohuella/{cat}/{id}` | HIGH/MED/LOW | {1-line} |

## Proposed Changes (requiere aprobación del usuario)
1. {edit específico a SKILL.md sección X}
2. {edit específico a CLAUDE.md}
3. {edit a templates/CLAUDE.md}
4. {skill a agregar/modificar}

## LEARNING.md Entry (para agregar después de aprobación)
## {YYYY-MM-DD} — {título corto}

**Source**: {session markers} · **Observations consumed**: {count} · **Sections affected**: {SKILL.md Section N}

### Learnings Created/Updated
| Category | Engram Key | Severity | Summary |
|----------|-----------|----------|---------|
| {cat} | `learnings/prohuella/{cat}/{id}` | HIGH/MED/LOW | {1-line} |

### Changes Applied
- {cambio específico 1}
- {cambio específico 2}
```

---

## Paso 6: Pedir aprobación

Mostrá el plan completo al usuario y preguntá:

**"¿Aplico estos cambios?"**

---

## Paso 7: Si el usuario aprueba

Ejecutá TODO esto:

### 7a. Aplicar cambios a archivos
- Editá SKILL.md / CLAUDE.md / templates / skills según el plan
- Verificá que SKILL.md siga bajo 300 líneas después de los cambios

### 7b. Marcar observaciones como applied
```
mem_update({
  id: {observation-id},
  content: {contenido original con Status: pending → Status: applied, Applied: {date} - {improvement-id}}
})
```

### 7c. Actualizar LEARNING.md
Agregá la entry del plan al final de `LEARNING.md` (después del comment marker).

### 7d. Guardar plan en Engram
```
mem_save({
  topic_key: "telemetry/improvement-plan/{date}",
  ...
})
```

### 7e. Sincronizar copias instaladas
```bash
cp skill/SKILL.md ~/.claude/skills/autosdd/SKILL.md
cp skills/autosdd-telemetry/SKILL.md ~/.claude/skills/autosdd-telemetry/SKILL.md
```

### 7f. Commit
```bash
git add -A
git commit -m "feat(improve): apply learnings from ProHuella v2.6.2-v2.6.7 analysis"
git push
```

---

## Paso 8: Si el usuario rechaza

Guardá como plan rechazado:
```
mem_save({
  topic_key: "telemetry/improvement-plan/{date}-rejected",
  content: {plan + razón del usuario}
})
```

NO marques observaciones como applied. Quedan pending para el próximo ciclo.

---

## Recordatorios

- **NUNCA escribas código fuente inline** — delegá via Agent tool
- **Preguntá feedback** al usuario (≥1 pregunta) durante el proceso
- **Guardá observaciones** de esta sesión de /improve a Engram
- **Session summary** obligatorio al final

---

*autoSDD v5.0 · /improve Protocol · 2026-04-26*
