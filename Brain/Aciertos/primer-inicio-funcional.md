<!-- @brain acierto -->
---
type: acierto
category: herramienta
updated: 2026-08-12
tags: [acierto, herramienta, opencode, mcp, setup]
---

# Primer inicio del segundo cerebro: config global + MCP + indexado determinista

> En una máquina nueva, el checklist de `_Config/PRIMER-INICIO.md` lleva el vault de 0 a funcional en una pasada, y el indexado regenerado quedó 100% rutas correctas + audit exit 0.

## Qué pasó

- Se creó `~/.config/opencode/opencode.json` (instrucciones, skills, agentes con `{file:...}`, plugins `vault-sync`/`automas`/`brain-guard`, comandos `indexar-sqlite`/`ordenar-brain`, MCP `openbraincode-kg`).
- MCP knowledge-graph clonado como hermano del vault, `npm install`, fix del bug `z.record(z.unknown())` → `z.object({}).catchall(z.unknown()).optional()` en `src/mcp/index.ts`; `kg.db` en `~/.local/share/knowledge-graph/` (fuera del vault, no versionado). Índice: 38 nodos / 135 aristas / 10 comunidades.
- Indexado del vault: 17 proyectos scrapeados + fichas en `Proyectos/<grupo>/<nombre>/`, `Proyectos/_INDEX.md` manual para enlazar, espejo SQLite `openbraincode.db`. Auditoría final: 0 enlaces rotos, 0 huérfanos, exit 0.

## Por qué funcionó

- Los scripts se auto-detectan (`while ($cur -and -not (Test-Path .../Proyectos))`), así que con apuntar el `opencode.json` global al vault alcanza.
- `OPENBRAIN_PROJECTS_ROOT` ya estaba persistida a nivel User y la raíz real contiene los proyectos → el descubrimiento de candidatos fue inmediato.
- Usar rutas **absolutas** en la config global (paths relativos a un config global no resuelven bien) evitó sorpresas con MCP y plugins.

## Contexto

- Proyecto: OpenBrainCode (vault)
- Stack: opencode + Obsidian + PowerShell scripts + MCP knowledge-graph
- Momento/versión: 2026-08-12, primera config en esta PC.

## Cómo repetirlo

1. Seguir `_Config/PRIMER-INICIO.md` con las rutas reales (`VAULT_PATH`, `OPENBRAIN_PROJECTS_ROOT`).
2. En Windows: config global en `C:\Users\<usuario>\.config\opencode\opencode.json`.
3. MCP: clonar knowledge-graph afuera del vault + `npm install` + `KG_VAULT_PATH` + `npx tsx src/cli/index.ts index`; luego reiniciar opencode.
4. Indexar `indexar-todo.ps1 -GenerateNotes -RunValidators` y cerrar con `auditar-grafo.ps1` exit 0.

## Keywords para /buscar

`primer inicio`, `setup`, `PRIMER-INICIO`, `config global`, `openbraincode-kg`, `KG_VAULT_PATH`, `mcp`

## De dónde viene

- Trabajo de setup del vault (2026-08-12).

## Relacionado

- [[Meta/Setup del vault y scripts]] — registro por máquina.
- [[Proyectos/knowledge-graph/knowledge-graph]] — el tool MCP escaneado e indexado.