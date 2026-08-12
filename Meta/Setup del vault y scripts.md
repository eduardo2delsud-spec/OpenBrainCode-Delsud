---
type: meta
project: OpenBrainCode
updated: 2026-08-12
tags: [setup, scripts, estructura]
---

# Setup del vault y scripts

## Registro de setups por máquina

> Completá una fila por máquina donde tengas el vault. Las rutas **no se guardan en `_Config/AGENTS.md`**:
> cada máquina apunta al vault desde su `~/.config/opencode/opencode.json` (instrucciones + skills + plugin
> `vault-sync.ts`). Los scripts auto-detectan el vault desde su propia ubicación o aceptan `-VaultPath`.

| Usuario / máquina | VAULT_PATH (opencode global) | OPENBRAIN_PROJECTS_ROOT | Notas |
|-------------------|------------------------------|-------------------------|-------|
| `edu` (PC principal, Windows) | `C:\Users\edu\.config\opencode\opencode.json` | `C:\Users\edu\Desktop\DelSud` (User) | Set up 2026-08-12. MCP `openbraincode-kg` en `C:\Users\edu\Desktop\DelSud\knowledge-graph` (kg.db en `~\AppData...\local\share\knowledge-graph\kg.db`). `OPENBRAIN_PROJECTS_EXTRA=C:\Users\edu\Desktop\APIA` está set pero apunta a una carpeta inexistente (los proyectos APIA reales viven en `DelSud\APIA`, cubiertos por la raíz principal). |

## Setup 2026-08-12 (registrado)

- Config global `C:\Users\edu\.config\opencode\opencode.json` apuntando al vault (`_Config/AGENTS.md`, skills, plugins `vault-sync`/`automas`/`brain-guard`, agentes `pm`/`brain`/`backend`/`frontend`, comandos `indexar-sqlite`/`ordenar-brain`, MCP `openbraincode-kg`).
- MCP knowledge-graph clonado como hermano (`DelSud\knowledge-graph`) + `npm install` + fix del bug `_zod` (`z.object({}).catchall(z.unknown())`) + índice del vault (38 nodos / 135 aristas).
- Indexado 2026-08-12: 17 proyectos → fichas en `Proyectos/<grupo>/<nombre>/`. Ficha manual `Proyectos/Zimula/Zimula.md` (script sin markers). `Proyectos/_INDEX.md` manual (por grupo) para enlazar fichas.
- **Bugs de scripts corregidos**: `indexar-todo.ps1` (`[string]$Root` → `[string[]]$Root`, multi-raíz; ver [[Brain/Errores/indexar-todo-multi-raiz]]) y `indexar-sqlite.ps1` (`& $invocation` → `& $node @invocation`; ver [[Brain/Errores/sqlite-invocation-array]]).
- Auditoría final: 0 enlaces rotos, 0 huérfanos, exit 0. Espejo SQLite `openbraincode.db` regenerado.

## Setup en esta PC (plantilla)

- `VAULT_PATH = <ruta del vault>` (en `~/.config/opencode/opencode.json`).
- `OPENBRAIN_PROJECTS_ROOT = <raíz de tus proyectos>` (User env).
- `opencode.json` y `AGENTS.md` de raíz son locales (gitignored); los skills se cargan desde `_Config/.opencode/skills`.
- `indexar-todo.ps1` detecta además sub-proyectos dentro de contenedores/workspaces y soporta múltiples raíces (`-ExtraRoots` / `OPENBRAIN_PROJECTS_EXTRA`).
- Pipeline de indexado determinista (E1, 2026-08-07): `scrape-proyecto.ps1` (BFS `-MaxDepth` 3, manifests/containers/workspaces/env/docker/agentes + `git_head`) → `generar-ficha.ps1` (fichas con marcadores `<!-- AUTO -->`, narrativa preservada, `-DryRun`) → `indexar-todo.ps1` (descubrimiento profundo + delta por hash git con estado en `.cache`, gitignored). Cache en `_Config/.opencode/.cache/` (no versionar); los 3 scripts requieren BOM UTF-8 (PS 5.1 lee ANSI; `generar-ficha.ps1` se auto-re-bomea).

## Estructura
```
OpenBrainCode/
├── _Inbox/          <- inbox de captura
├── Conceptos/        # template base
├── Decisiones/
├── Patrones/
├── Proyectos/
├── _Config/        # plantilla del segundo cerebro (AGENTS.md, opencode.json, skills, scripts)
│   └── .opencode/
│       ├── scripts/
│       └── skills/
└── .obsidian/
```
Cada carpeta tiene una `Template <Tipo>.md` guía con el formato canónico del frontmatter.

## Scripts reutilizables (`_Config/.opencode/scripts/`)
- `aplicar-colores-graph.ps1` — reinyector de `colorGroups` (idempotente).
- `instalar-plugins.ps1` — descarga/idempotente de los plugins núcleo desde GitHub releases.

## Commits de referencia
| Área | Commit |
|------|--------|
| Plantillas guía + colores tipo | `699e034` |
| Colores robustos (script + CSS) | `3c635af` |
| MCP / knowledge-graph | `4b6e8fd` |
| Plugins núcleo | `d8f5868` |

## Diagnóstico habitual
- Si Obsidian corrompió el grafo → re-aplicar `aplicar-colores-graph.ps1`.
- Si el MCP no lista tools → reiniciar opencode (no hot-reload).
- `workspace.json`/`graph.json` `M` sin commitear → regen normal, ignorar.