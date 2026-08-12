<!-- @regla readme-proyecto -->
---
type: regla
category: documentacion
area: documentacion
updated: 2026-08-07
tags: [regla, documentacion, readme, estructura]
---

# README Proyecto — Regla de estructura

> Regla que define la estructura canónica del `README.md` de **cualquier** proyecto de este
> portafolio. Está alineada 1:1 con la ficha que genera el skill **`scrape-proyecto`**
> (en `_Config/.opencode/skills/scrape-proyecto`), de modo que el scraper extrae el propósito, el
> stack y los comandos de forma consistente y los proyectos nuevos no entran en conflicto con el grafo.

## Por qué existe

El scraper de proyectos lee el `README.md` (Paso 2) para obtener el propósito, y la ficha que
genera (Paso 8) tiene una estructura fija. Sin una plantilla, cada README era libre y el scraper no
encontraba secciones consistentes → fichas y grafos inconsistentes. Este README fija esas secciones.

## Estructura canónica del README

El `README.md` que se genere en un proyecto nuevo (o se alinee en uno existente) debe seguir
**ESTA estructura y en ESTE orden**. No se inventan secciones de distinto nombre para lo mismo.

```markdown
# <Nombre del proyecto>

> <descripción de 1 línea del propósito>

## Qué hace

<2-3 líneas del propósito>

## Stack

| Capa | Tecnología | Detalle |
|------|-----------|---------|
| Frontend | ... | ... |
| Backend | ... | ... |
| Persistencia | ... | ... |
| Calidad | ... | ... |

## Arquitectura

```
<árbol de carpetas (2 niveles)>
```

## Requisitos

- Node.js >= ...
- pnpm / npm
- Docker (si aplica)

## Setup

```bash
git clone <url> && cd <proyecto>
npm install
cp .env.example .env
npm run db:migrate   # si aplica
npm run dev
```

## Scripts

```bash
npm run dev          # desarrollo
npm run build        # compilación
npm run check        # calidad (Biome)
npm run db:*         # base de datos
```

## Servicios y puertos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| api | 3000 | Backend Express |
| web | 5173 | Frontend SPA |

## Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|


## Documentación

- `docs/` — ...
- `CHANGELOG.md` — versiones

## Licencia

MIT
```

## Reglas de la plantilla

1. **Secciones fijas y homogéneas**: mismo nombre y mismo orden que arriba. No reenumerar
   (`Objetivo`, `Objetivos`, `Pipeline`, etc. son de READMEs descriptivos, no de esta plantilla).
   Las secciones extra para contexto humano (roadmap, monetización, seguridad) quedan OK después
   de `## Qué hace` si el usuario quiere, pero el bloque de `Stack`/`Arquitectura`/`Scripts` se mantiene.
2. **Sin emojis en títulos de sección** (evita ruido en el texto plano al scrapear).
3. **Sin secretos**: nunca valores reales, siempre `.env.example`.
4. **`## Qué hace` = propósito**, no marketing. Es lo que el scraper usa para la ficha.
5. La **tabla `Stack`** alimenta los conceptos (Scraper Paso 3): cada tecnología se resuelve contra
   `Conceptos/`. Si se agrega una tecnología, aparece en esta tabla.
6. **`## Arquitectura`** con árbol de 2 niveles alimenta el patrón (`spa-api`, `monorepo`, ...).
7. **Tabla `Servicios y puertos`** y **`Endpoints`** alimentan servicios/puertos de la ficha.
8. **Tabla `Agentes opencode`** refleja lo declarado en `.opencode/agents/`.

## Cómo se aplica

opencode lo aplica vía la skill **`nuevo-proyecto-base`** (genera el README con esta plantilla en el
arranque) y al alinear proyectos existentes. El scraper **`scrape-proyecto`** la da por sentada:
si el `README.md` sigue esta regla, la extracción ya está estructurada.

## Relacionado

- [[Reglas/Comunes/Documentacion]] — qué documentación es obligatoria y cuándo se actualiza.
- [[Reglas/Comunes/Changelog]] — formato de entradas de changelog.
- `_Config/.opencode/skills/scrape-proyecto` — el scraper que consume el README.
- [[Reglas/Backend/Arranque Backend]] · [[Reglas/Frontend/Arranque Frontend]] — estructura de nuevos proyectos.