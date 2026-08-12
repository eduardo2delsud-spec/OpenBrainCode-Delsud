---
type: proyecto
project: Nombre del Proyecto
status: activo
created: YYYY-MM-DD
updated: YYYY-MM-DD
stack: [TypeScript, React, Express, SQLite]
arch: spa-api
dominio: ejemplo
tags: [proyecto, ejemplo]
---
# Template — Ficha de Proyecto

> Plantilla de ejemplo. Copiá este archivo a `Proyectos/<Nombre>/<Nombre>.md` y reemplazá el contenido. Cada proyecto vive en su **carpeta propia** con la ficha como nota central. Las secciones marcadas con `<...>` son obligatorias.

> **Carpeta del proyecto (el agente lleva el registro SIEMPRE dentro de esta carpeta)**
> ```
> Proyectos/<Nombre>/
> ├── <Nombre>.md          ← esta ficha (hub del proyecto)
> ├── Decisiones/           ← ADRs EXCLUSIVOS de este proyecto
> ├── Notas/                ← runbook/setup/endpoints propios (opcional)
> └── Worklog/YYYY-MM-DD.md ← historial propio (append-only, siempre)
> ```
> Conceptos/Patrones/Reglas/Decisiones (general) **compartidos** siguen en sus carpetas de raíz.

## Estado actual

<1-2 líneas: qué está *cierto* hoy. En qué lugar encaró el desarrollo, si está estable, next steps.>
Estado holders: `activo` | `pausado` | `completado` | `legacy` (reflejá en el frontmatter `status` y en `updated` cada cambio).

> Historial de qué pasó y por qué → en `Proyectos/<Nombre>/Worklog/` (append-only). Esta nota es el **estado durable**.

## Qué hace

<Descripción de 2-3 líneas del propósito del proyecto: qué problema resuelve y para quién.>

## Stack

| Capa | Tecnología | Detalle |
|------|-----------|---------|
| Frontend | `<React>` | `<SPA con Vite + Tailwind>` |
| Backend | `<Express>` | `<API REST, autenticación JWT>` |
| Base de datos | `<SQLite>` | `<Drizzle ORM>` |
| Infra | `<Docker>` | `<docker-compose para dev>` |

## Arquitectura

```
<Nombre>/
├── frontend/     ← SPA
├── backend/      ← API REST
│   └── src/
│       ├── routes/
│       └── db/
└── docker-compose.yml
```

## Conceptos que usa

[[Conceptos/Template Concepto]], [[Conceptos/Template Concepto]] ...

## Patrones que sigue

[[Patrones/Template Patrón]]

## Decisiones clave

[[Decisiones/Template ADR]]

## Lecciones

[[Lecciones/Template Lección]]

## Historial (worklog)

- `Proyectos/<Nombre>/Worklog/YYYY-MM-DD.md` — <resumen del día>
- Enlace al worklog más reciente del proyecto. La historia append-only va en `Proyectos/<Nombre>/Worklog/`.

## Dónde buscar más

- `README.md` — <detalles>
- `.opencode/agents/` — <agentes definidos>
- `docs/` — <documentación adicional>
