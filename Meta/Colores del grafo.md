---
type: meta
project: OpenBrainCode
updated: 2026-08-07
tags: [grafo, obsidian, colores]
---

# Colores del grafo

Obsidian **regenera** `.obsidian/graph.json` y `.obsidian/workspace.json` en cada apertura. El arreglo `colorGroups` se pierde o se corrompe (Obsidian llegó a escribir un grupo basura `{"query": "", "color": {"a":1,"rgb":14048348}}`).

CSS no puede colorear por carpeta (solo por tipo de nodo) → decidimos un **script reinyector** + CSS para líneas.

## Solución
- **Script**: `_Config/.opencode/scripts/aplicar-colores-graph.ps1` — idempotente. Reemplaza `colorGroups` (vacíos o corruptos) con la lista canónica y valida el JSON. Movida por un guard si `path:Proyectos` ya está aplicado.
- **CSS**: `.obsidian/snippets/grafo-lineas.css` colorea líneas/flechas, inmune a la regen. Habilitado en `.obsidian/appearance.json`.

## Colores por tipo (canónicos)
| Tipo | Color |
|------|-------|
| Proyectos | `#22c55e` |
| Conceptos | `#3b82f6` |
| Patrones | `#a855f7` |
| Decisiones | `#ef4444` |
| Lecciones | `#f97316` |
| `_Inbox` | `#9ca3af` |
| `_Config` | `#06b6d4` |
| index `OpenBrainCode` | `#facc15` |

## Cómo re-aplicar
```powershell
_Config\.opencode\scripts\aplicar-colores-graph.ps1
```
Commit de referencia: `3c635af`.