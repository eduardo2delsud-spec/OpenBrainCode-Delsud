---
type: meta
category: arquitectura
project: OpenBrainCode
updated: 2026-08-07
---

# Decisiones de arquitectura y plugins

## Base limpia y portátil
El vault nace como **base limpia**: reproducible en cualquier máquina. Reglas:

- Nada de rutas `D:\Proyectos\...\` hardcodeadas dentro del vault.
- Cualquier herramienta externa (como el MCP) se clona **como hermano** del vault (fuera del repo) y se referencia con paths relativos.
- `workspace.json` y `graph.json` se generan con cada apertura de Obsidian → fuera de commits.

## Plugins núcleo instalados (commit `d8f5868`)
Se eligió un set local y portable (nada de cloud/API). Instalados vía `_Config/.opencode/scripts/instalar-plugins.ps1` (idempotente, baja releases de GitHub). Activos en `.obsidian/community-plugins.json`: `dataview`, `obsidian-linter`, `templater-obsidian`, `metadata-menu`, `extended-graph`.

### Linter (`obsidian-linter` v1.32.0)
Consistencia del frontmatter al guardar. Reglas activas en `data.json`:
- `yaml-title`: el H1 debe coincidir con el nombre del archivo.
- `yaml-timestamp`: actualiza `updated` (formato `YYYY-MM-DD HH:mm`).
- `format-tags-in-yaml`: tags en formato inline `[a, b]` (coherente con `Template Concepto.md` restaurado).
- `add-blank-line-after-yaml`, `header-increment`.

### Templater (`templater-obsidian` v2.25.0)
Plantillas dinámicas (`<% tp. %>`). `templates_folder: "."`, inserción manual (no auto al crear). Las guías `Template <Tipo>.md` de cada carpeta son plantillas usables.

### Metadata Menu (`metadata-menu` v0.8.12)
Campos tipados y comandos sobre el frontmatter (edición en línea, vistas por tipo).

### Extended Graph (`extended-graph` v2.7.7)
Upgrade visual del grafo local (filtros, estilos) sin salir del vault. Nota: no reemplaza la gestión de colores por tipo (ver [[Colores del grafo]]).

## Descartado a propósito
- InfraNodus / Cloud / Graph Plus: dependen de servicios externos o son pesados → rompen la portabilidad.
- "Bases Power Pack" y paneles: overkill para un segundo cerebro.