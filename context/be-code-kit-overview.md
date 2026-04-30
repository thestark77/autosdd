# be-code-kit

## Qué es

Un instalador que en **un solo comando** replica el entorno completo de desarrollo con IA en la máquina de cada desarrollador. Clona repos, instala skills, configura hooks, y deja todo listo para trabajar.

## Qué instala

| Componente | Qué hace |
|------------|----------|
| **autoSDD v6.0** | Orquestador autónomo — delega trabajo a sub-agentes especializados, nunca escribe código directo |
| **E2E Forge** | Crea tests E2E conectados a logs reales de Axiom (producción) |
| **16+ skills** | Prompt engineering, frontend, error handling, Playwright, PR creation, code review adversarial |
| **5 plugins** | Powerline, Engram (memoria), frontend-design, code-review, code-simplifier |
| **Linear MCP** | Gestiona issues/tareas de Linear directamente desde Claude Code |
| **Engram MCP** | Memoria persistente entre sesiones — recuerda decisiones, bugs, convenciones |
| **Contexto completo** | Business logic, guidelines, convenciones, agentes especializados del proyecto |

## Flujo de autoSDD (lo que pasa cuando le pedis algo a Claude)

```
Tu prompt → VERSION INIT → CONTEXT SCOUT → TRIAGE → ROUTE → PLAN → DELEGATE → COLLECT → CLOSE → KNOWLEDGE UPDATE
```

1. **VERSION INIT** — Crea carpeta de versión + guarda tu prompt original
2. **CONTEXT SCOUT** — Un agente barato (haiku) pre-filtra el contexto relevante
3. **TRIAGE** — Clasifica complejidad (alta/media/baja)
4. **ROUTE** — Selecciona skills según qué archivos toca (frontend → frontend-design, API → error-handling, etc.)
5. **PLAN** — Arma un plan estructurado (prompt.md) con tareas y dependencias
6. **DELEGATE** — Lanza sub-agentes especializados (el orquestador NUNCA escribe codigo directo)
7. **COLLECT** — Valida resultados, re-delega si fallan
8. **CLOSE** — Genera changelog + feedback.md
9. **KNOWLEDGE UPDATE** — Guarda lo aprendido en Engram para futuras sesiones

## Qué pueden hacer los devs

- **Trabajar normalmente** — autoSDD se activa solo, sin configurar nada
- **Saltar autoSDD** cuando quieran — prefijo `[raw]` para preguntas rapidas
- **Usar E2E Forge** — `/e2e-forge` crea tests basados en trafico real
- **Hablar por voz** — SuperWhisper dicta prompts en vez de tipear
- **Reportar feedback** — escribir "FEEDBACK DE USO" crea una PR automatica
- **Compartir descubrimientos** — escribir "DESCUBRIMIENTO" documenta hallazgos para todo el equipo
- **Gestionar Linear** — pedirle a Claude que liste, cree o actualice issues directamente

## Ventajas

- **Consistencia** — todos trabajan con el mismo setup, mismas convenciones, mismos skills
- **Memoria colectiva** — lo que descubre un dev queda disponible para todos (via Engram + feedback PRs)
- **Ahorro de tokens** — Context Scout filtra antes de mandar al modelo caro, Knowledge Caching evita releer archivos
- **Calidad** — sub-agentes especializados por dominio, no un modelo generico para todo
- **Trazabilidad** — cada version queda documentada (prompt original, plan, changelog, feedback)

## Consideraciones

- **Requiere Claude Pro** ($20 USD/mes) — la empresa lo cubre
- **Acceso a GitHub** — necesitan estar en la org IT-Bemovil
- **Variables de entorno** — se comparten por canal interno, nunca commitear
- **autoSDD NO es magia** — el dev sigue liderando, la IA ejecuta. Hay que saber QUE pedir
- **Playwright siempre --headed** — tests de browser se ven en pantalla, nunca headless
