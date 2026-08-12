<!-- @changelog -->
# Changelog — OpenBrainCode-Delsud

> Regla general del formato: [[Reglas/Comunes/Changelog]]. Cualquier cambio en este archivo debe cumplirla.

## Unreleased

- **Added**: Setup primer inicio en `edu` (2026-08-12): config global `~/.config/opencode/opencode.json`
  (instrucciones, skills, plugins, agentes, comandos, MCP `openbraincode-kg`), MCP knowledge-graph clonado
  como hermano e indexado (38 nodos / 135 aristas), índice del vault 2026-08-12: **17 proyectos** con fichas
  en `Proyectos/<grupo>/<nombre>/` + ficha manual `Proyectos/Zimula/Zimula.md` + `Proyectos/_INDEX.md`,
  espejo SQLite `openbraincode.db`. Auditoría final exit 0. [2026-08-12]
- **Fixed**: `indexar-todo.ps1` fallaba con multi-raíz (`OPENBRAIN_PROJECTS_EXTRA`): param
  `[string]$Root` → `[string[]]$Root` evitaba `Substring` out of range y rutas de fichas correctas
  ([[Brain/Errores/indexar-todo-multi-raiz]]). `indexar-sqlite.ps1`: `& $invocation` → `& $node @invocation`
  para invocar node ([[Brain/Errores/sqlite-invocation-array]]). [2026-08-12]
- **Added**: Template inicial del vault — estructura scaffold completa sin proyectos: `_Config/` (skills,
  scripts, agentes, AGENTS.md, PRIMER-INICIO), `Reglas/`, `Meta/`, índices por área, plantillas por tipo
  de nota (`Template Proyecto`, `Template Concepto`, `Template Patrón`, `Template Herramienta`,
  `Template Lección`, `Template ADR`, `Template Error`, `Template Acierto`, `Template Worklog`) y hub
  `OpenBrainCode.md` genérico. [2026-08-12]

## Referencia de historial

- El historial del vault original (OpenBrainCode) vive en su propio repo. Este repo arranca como template
  limpio para documentar los proyectos de trabajo desde cero.