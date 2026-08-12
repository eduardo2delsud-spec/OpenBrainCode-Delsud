---
type: meta
project: OpenBrainCode
updated: 2026-08-07
tags: [setup, scripts, estructura]
---

# Setup del vault y scripts

## Registro de setups por máquina

> Completá una fila por máquina donde tengas el vault. Las rutas **no se guardan en `_Config/AGENTS.md`**:
> cada máquina apunta al vault desde su `~/.config/opencode/opencode.json` (instrucciones + skills + plugin
> `vault-sync.ts`). Los scripts auto-detectan el vault desde su propia ubicación o aceptan `-VaultPath`.

| Usuario / máquina | VAULT_PATH (opencode global) | OPENBRAIN_PROJECTS_ROOT | Notas |
|-------------------|------------------------------|-------------------------|-------|
| `<usuario>` | `C:\Users\<usuario>\.config\opencode\opencode.json` | `C:\Users\<usuario>\Proyectos` | Configurar en el primer inicio (ver `_Config/PRIMER-INICIO.md`) |

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