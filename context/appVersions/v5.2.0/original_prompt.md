# Original Prompt — v5.2.0

> User: sebastianflorez3@gmail.com
> Date: 2026-04-27
> Session: current (autoSDD dogfooding)

## Context dado por el usuario

En la conversacion e135e27e-1196-451e-a039-f69274acb167 (Bemovil2.0, frontend redesign), el agente orquestador:

1. NO siguio la metodologia autoSDD — escribio codigo inline constantemente (14 edits en v0.1.0, 0 delegaciones)
2. NO respeto el versionamiento — no creo carpeta appVersions hasta que el usuario lo senalo
3. Se perdio contexto en cada compactacion — no habia PROGRESS.md, no habia prompt.md, no habia original_prompt.md
4. NO dio feedback alguno — 0 preguntas de feedback
5. Los sub-agentes (cuando se usaron) no recibieron instrucciones detalladas de skills ni CREA

## Tareas solicitadas

1. Revisar la conversacion Bemovil2.0 + self-analysis prompt y dar valoracion general
2. Crear diagrama de flujo del estado actual de autoSDD v5.1 (hooks, memoria, archivos, triggers)
3. Definir como se conecta con gentle-ai
4. Analisis de mejora (/improve) con todo el contexto
5. Crear diagrama nuevo con el flujo corregido
6. Crear nueva version de autoSDD (v5.2.0) con todas las correcciones

## Feedback adicional del usuario (mensajes posteriores)

- Debe haber un flujo MUY bien definido, con hooks y triggers, sin confiar en la memoria del agente
- Menos es mas — SKILL.md y CLAUDE.md demasiado extensos, queman tokens
- Knowledge caching — guardar mapas de flujos para evitar re-escanear archivos
- El feedback que SI hizo bien el agente (preguntar despues de cada tarea) debe persistir
- Usar /claude-md-improver para optimizar
- Changelog debe moverse a la version especifica (context/appVersions/vX.Y.Z/changelog.md)
- autoSDD debe usarse a si mismo (dogfooding)
