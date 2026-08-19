---
type: hub
updated: 2026-08-19
---

> Segundo cerebro para registrar proyectos de software: qué hacen, cómo están hechos, con qué tecnologías y cómo encontrarlos rápido.

Este es el **proyecto base** y la nota de inicio (hub) del vault. Conecta todos los documentos, skills, scripts y carpetas que lo componen.

---

## Qué es

Un **knowledge graph** de proyectos de software. No es un catálogo aislado: es una red donde los **proyectos** referencian **conceptos**, los conceptos se comparten entre proyectos, los **patrones** emergen de la arquitectura, y las **decisiones** se documentan como ADRs reutilizables.

Cada proyecto vive en su **carpeta propia** en `Proyectos/<Nombre>/`, con la ficha como nota central y su registro (worklog + ADRs) dentro de la misma carpeta. El conocimiento genérico reutilizable (conceptos, patrones, herramientas, lecciones, decisiones) vive en las carpetas de raíz y se **enlaza** desde los proyectos.

---

## Mapado de documentos

| Documento | Rol |
|-----------|-----|
| [[_Config/AGENTS]] | Constitución del vault, reglas para opencode y formato de notas |
| [[_Config/AGENTS]] | Guía de uso portátil que se copia a cada proyecto para conectarlo al grafo |
| [[Meta/Conventions\|Conventions]] | **Cómo está organizado el vault. Leer esto primero.** |
| [[Meta/Setup del vault y scripts]] | Instalación de scripts y setup del vault |
| [[Meta/Integración MCP knowledge-graph]] | Cómo conectar el MCP semántico a Obsidian |
| [[Brain/_INDEX]] | Memoria de auto-mejora del agente: errores resueltos y aciertos (crudo) |
| [[_Dashboard]] | Panel Dataview con métricas del grafo (via Obsidian) |
| [[OpenBrainCode]] | **Esta nota** — hub que conecta todo |
| [[_Outbox/README]] | Zona de salida: donde el conocimiento se exprime en outputs |
| [[Worklog/OpenBrainCode/2026-08-19]] | Worklog del vault (historia append-only de sesiones) |
| [[Worklog/OpenBrainCode/2026-08-13]] | Worklog del vault (historia append-only de sesiones) |
| [[Reglas/Comunes/Changelog]] | Regla general: formato del changelog de todo proyecto |
| [[Reglas/Comunes/Documentacion]] | Regla general: documentación obligatoria (CHANGELOG, README, AGENTS, semver) |
| [[Reglas/Backend/Arranque Backend]] | Regla: stack, estructura y arranque canónico (con banner) para nuevos backends |
| [[Reglas/Frontend/Arranque Frontend]] | Regla: stack, estructura y reglas para nuevas SPA de frontend |
| [[Reglas/Backend/Convenciones Backend]] | Regla normativa: config/env única, errores uniformes, secretos |
| [[Reglas/Comunes/Arranque VSCode]] | Regla: todo proyecto nuevo DEBE incluir `.vscode/tasks.json` |
| [[Reglas/Comunes/Repositorio]] | Regla: 1 repo por servicio (git + changelog + readme), salvo monorepo |

## Flujo (Estado vs Historia)

El vault separa **estado durable** (fichas de `Proyectos/Conceptos/...`) de **historia** (`Worklog/` + `Decisiones/`).
El trabajo entra por el worklog diario (dentro de la carpeta del proyecto) y se promueve a durable cuando cambia algo que es cierto.
Los **errores y aciertos** se escriben primero en `Brain/` (auto-mejora) y se promueven a `Lecciones/`
cuando valen como lección curada. Reglas completas en [[Meta/Conventions]].

---

## Skills (documentos enlazados)

Los skills son documentos que definen cómo opencode actúa sobre el proyecto. La **fuente canónica** vive en `_Config/.opencode/skills/` (plantilla que se copia a los proyectos). Acá enlazo las versiones de `_Config`:

- [[_Config/.opencode/skills/scrape-proyecto/SKILL]] — scrapea un proyecto individual y genera/actualiza su ficha con conexiones
- [[_Config/.opencode/skills/indexar-proyectos/SKILL]] — indexa **todos** los proyectos de `$OPENBRAIN_PROJECTS_ROOT` y reconstruye el grafo
- [[_Config/.opencode/skills/buscar-proyecto/SKILL]] — busca info en el grafo siguiendo las conexiones
- [[_Config/.opencode/skills/web-clipper/SKILL]] — captura contenido web útil al vault (_Inbox / conceptos / patrones / lecciones)
- [[_Config/.opencode/skills/nuevo-proyecto-base/SKILL]] — scaffold base full-stack (backend + SPA) con auth y componentes UI según `Reglas/Arranque Backend`, `Arranque Frontend`, `Autenticacion` y `Componentes UI` (`/nuevo-proyecto-base`)
- [[_Config/.opencode/skills/nuevo-proyecto-gestionado/SKILL]] — encuesta la idea hasta definir el producto (spec + ADRs) y construye con TDD (`/nuevo-proyecto-gestionado`)

> **Modelo:** `_Config/` (AGENTS.md genérico + opencode.json + skills + scripts) es la plantilla que se copia a cada
> proyecto para conectarlo al segundo cerebro. La raíz del vault mantiene su propia copia operativa de `opencode.json`.
> Más en [[_Config/PRIMER-INICIO]].

---

## Agentes (subagentes por rol, fuente portable)

Definidos en `_Config/.opencode/agents/` (portables; registro en config global vía `{file:...}`).
Cada subagente lee **las reglas de su carpeta** en `Reglas/<Carpeta>/` + `Reglas/Comunes/` antes de trabajar.

- `brain` — **curador del grafo (primary)**: consultas, ordenar/enlazar el vault, reconstruir índices.
- `pm` — **orquestador (primary)**: descompone features en tareas y delega a `backend`/`frontend`.
- `backend` — backend (Express + Drizzle + Biome, contract-first + TDD) → `Reglas/Backend/`.
- `frontend` — frontend (React + Vite + TanStack Query, a11y + Core Web Vitals) → `Reglas/Frontend/`.

Skills web de la comunidad copiadas a `_Config/.opencode/skills/`: `api-and-interface-design`,
`test-driven-development`, `code-simplification`, `code-review-and-quality`, `frontend-ui-engineering`,
`obsidian-markdown`, `playwright-cli`, `customize-opencode`.

---

## Scripts

Automatización en PowerShell, en `_Config/.opencode/scripts/`. El vault se auto-detecta desde la ubicación del script (no se hardcodea ninguna ruta).

| Script                | Función                                                                           |
| --------------------- | --------------------------------------------------------------------------------- |
| `scrape-proyecto.ps1` | Extrae los hechos de un proyecto (stack, deps, scripts, carpetas, agentes) a JSON |
| `indexar-todo.ps1`    | Orquesta el scandiseo de todos los proyectos en `$OPENBRAIN_PROJECTS_ROOT`        |
| `buscar.ps1`          | Busca texto en las carpetas del grafo                                             |
| `metricas.ps1`        | Cuenta notas por carpeta + enlaces wiki                                           |
| `validar-vault.ps1`   | Valida frontmatter, campos requeridos y secciones por tipo                        |
| `auditar-grafo.ps1`   | Detecta enlaces rotos, huérfanos y notas stale                                    |
| `construir-indices.ps1` | Regenera los `_INDEX.md` de cada área                                           |
| `indexar-sqlite.ps1`  | Espeja el vault completo en `openbraincode.db` (SQLite, notas + grafo)            |

### Variable de entorno

Los scripts usan la variable `OPENBRAIN_PROJECTS_ROOT` para saber dónde están tus proyectos. Definila a nivel de sistema o por sesión:

```powershell
# Windows
[Environment]::SetEnvironmentVariable("OPENBRAIN_PROJECTS_ROOT", "C:\Users\<usuario>\Proyectos", "User")
# o por sesión
$env:OPENBRAIN_PROJECTS_ROOT = "C:\Users\<usuario>\Proyectos"
```

```bash
# Linux/Mac
export OPENBRAIN_PROJECTS_ROOT=~/proyectos
```

---

## Estructura de carpetas

```
OpenBrainCode/               ← raíz del vault
├── AGENTS.md                ← constitución
├── OpenBrainCode.md          ← esta nota (hub)
├── _Dashboard.md             ← panel dataview
├── opencode.json             ← config de opencode (raíz, skills → _Config/)
├── _Config/                 ← plantilla del segundo cerebro (a copiar en proyectos)
│   ├── AGENTS.md             ← guía de uso genérica (brain-usage)
│   ├── PRIMER-INICIO.md      ← checklist de setup en una PC nueva
│   ├── opencode.json         ← config autocontenida
│   └── .opencode/            ← skills/ + scripts/ + agents/ (fuente canónica)
├── Meta/                    ← convenciones y plantillas del vault
├── Reglas/                  ← reglas normativas (arranque, doc, changelog, convenciones)
├── Proyectos/               ← una carpeta por proyecto: <Proyecto>.md + Decisiones/ + Notas/ + Worklog/
├── Conceptos/               ← conceptos reusables que span projects
├── Patrones/                ← patrones arquitectónicos emergentes
├── Herramientas/            ← registro vivo de herramientas y cómo se usan
├── Lecciones/               ← lessons learned (curadas, presentables)
├── Brain/                   ← memoria de auto-mejora del agente (cruda)
│   ├── Errores/             ← errores resueltos (síntoma → causa → solución)
│   └── Aciertos/            ← qué funcionó bien y vale repetir
├── Decisiones/              ← ADRs (Architecture Decision Records) reutilizables
├── _Inbox/                  ← captura temporal a procesar
├── _Outbox/                 ← salida: posts, tutorials, outputs destilados
└── .obsidian/               ← settings de Obsidian (versionado)
```

---

## Plantillas (guías para nuevas notas)

Cada carpeta del grafo tiene un archivo **Template** de ejemplo, listo para copiar y reemplazar. Son la guía canónica del formato de cada tipo de nota:

| Plantilla | Para qué sirve |
|-----------|----------------|
| [[Proyectos/Template Proyecto]] | Ficha de un proyecto (qué hace, stack, arquitectura, conexiones) |
| [[Conceptos/Template Concepto]] | Concepto reutilizable (tecnología, herramienta, práctica) |
| [[Patrones/Template Patrón]] | Patrón arquitectónico que emerge de varios proyectos |
| [[Herramientas/Template Herramienta]] | Ficha de una herramienta (cómo se usa, config, alternativas) |
| [[Lecciones/Template Lección]] | Lección aprendida de una experiencia concreta |
| [[Brain/Errores/Template Error]] | Error resuelto (síntoma, causa, solución) — memoria de auto-mejora |
| [[Brain/Aciertos/Template Acierto]] | Acierto que vale repetir — memoria de auto-mejora |
| [[Decisiones/Template ADR]] | Decisión arquitectónica (ADR) |
| [[Meta/Template Worklog]] | Registro diario append-only de un proyecto (historia) |

Estas plantillas no aparecen en el [[_Dashboard]] ni en las métricas (el filtro excluye los archivos que empiezan con `Template`), pero sí se ven en el grafo de Obsidian con el color de su carpeta.

---

## Uso

### Indexar todos los proyectos
```
/indexar
```
Scanea `$OPENBRAIN_PROJECTS_ROOT`, detecta proyectos de software, genera/actualiza las fichas y el grafo.

### Scrapear un proyecto
```
/scrape-proyecto <ruta o nombre del proyecto>
```

### Buscar información
```
/buscar "Docker"
```
o preguntar directo: "¿Qué proyecto usa X?" / "¿Cómo está hecho Y?"

### Crear proyecto nuevo
```
/nuevo-proyecto-base   → scaffold full-stack con reglas del vault
/nuevo-proyecto-gestionado → encuesta la idea, spec + ADRs, construye con TDD
```

---

## Licencia

Personal. Este vault es para uso propio. Se sincroniza via git.