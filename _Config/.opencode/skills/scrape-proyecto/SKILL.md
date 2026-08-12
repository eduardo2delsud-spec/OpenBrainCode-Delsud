---
name: scrape-proyecto
description: Use when the user wants to scrape a single project and generate/update its registry note with connections to concepts, patterns, and lessons. Triggers: "scrape", "registrar proyecto", "indexar proyecto", "qué tiene X", "cómo está hecho X". Reads project sources and creates interlinked notes in the brain vault.
---

# Scrape Proyecto (Brain Mode)

Genera o actualiza la ficha de un proyecto en el vault OpenBrainCode, **creando conexiones** con conceptos, patrones, lecciones y decisiones.

## Ruta del vault

El vault es la raíz de este proyecto (donde vive `OpenBrainCode.md`). Las notas van en:
- `Proyectos/<Nombre>/<Nombre>.md` — ficha del proyecto (carpeta por proyecto; subcarpetas `Decisiones/`, `Notas/`, `Worklog/` para lo propio del proyecto, **siempre dentro de esa carpeta**)
- `Conceptos/<Nombre>.md` — conceptos reutilizables
- `Patrones/<Nombre>.md` — patrones arquitectónicos
- `Lecciones/<Nombre>.md` — lessons learned
- `Decisiones/ADR-XXX <Título>.md` — ADRs

Para resolver el directorio donde están los proyectos usá la variable de entorno `OPENBRAIN_PROJECTS_ROOT` (o el parámetro `-ProjectsRoot`).

## Input esperado

El usuario proporciona el proyecto a scrapear. Puede ser:
- Ruta absoluta: `<ruta al proyecto>`
- Nombre simple: `<Nombre>` (buscar en `$OPENBRAIN_PROJECTS_ROOT\<Nombre>`)

## Proceso de scrape

### Paso 1: Validar proyecto
Verificar que exista al menos uno de: `package.json`, `requirements.txt`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `docker-compose.yml`, `README.md`.

### Paso 2: Extraer información

Leer y extraer de:
- **README.md** → propósito (2-3 líneas). Si el README sigue [[Reglas/Comunes/README Proyecto]], el propósito
  está en `## Qué hace`, el stack en la tabla `## Stack`, comandos en `## Scripts` y servicios en
  `## Servicios y puertos`: extraé directo de esas secciones. Si no la sigue, extraé lo que haya.
- **package.json** (todos niveles) → nombre, scripts, dependencias
- **AGENTS.md** / `.opencode/AGENTS.md` → stack, convenciones, sub-agentes
- **.opencode/agents/*.md** → nombre, rol, invocación
- **docker-compose.yml** → servicios, puertos, DBs
- **Dockerfile** → stages, puertos
- **.env.example** → variables (sin secretos)
- **Estructura de carpetas** → arquitectura (2 niveles)
- **CHANGELOG.md** → versiones, decisiones notables
- **docs/** → documentación adicional

### Paso 3: Identificar conceptos, patrones, lecciones y decisiones

**Conceptos** — tecnologías y herramientas que el proyecto usa:
| Fuente | Conceptos a identificar |
|--------|------------------------|
| package.json dependencies | React, Express, Zod, Drizzle, etc. |
| package.json devDependencies | Biome, TypeScript, Vite, etc. |
| docker-compose.yml | Docker, Docker Compose, PostgreSQL, Redis, etc. |
| AGENTS.md stack | Tecnologías declaradas explícitamente |
| .env.example | Servicios externos (OpenAI, Stripe, etc.) |

**Patrones** — soluciones arquitectónicas que el proyecto implementa:
| Arquitectura detectada | Patrón |
|------------------------|--------|
| `frontend/` + `backend/` separados | SPA + API |
| Múltiples servicios en docker-compose | Microservicios |
| Un solo `src/` con todo junto | Monolito |
| `packages/` o workspaces | Monorepo |
| Solo un `index.ts` | Simple |

**Decisiones** — opciones técnicas documentadas:
| Fuente | Decisión |
|--------|----------|
| AGENTS.md "Stack sagrado" / "No usar" | Preferencias de stack |
| CHANGELOG.md | Cambios de stack, migraciones |
| README.md sección "Decisiones" | Decisiones explícitas |

**Lecciones** — aprendizajes de problemas o decisiones:
| Fuente | Lección |
|--------|---------|
| CHANGELOG.md "Fixed" / "Changed" | Problemas resueltos |
| AGENTS.md "Lo que me define" | Filosofía de desarrollo |
| README.md "Problemas identificados" | Issues conocidos |

### Paso 4: Crear/enlazar notas de concepto

Para cada concepto identificado:
1. **Verificar si ya existe** en `Conceptos/<Nombre>.md`
2. **Si no existe**: crear nota con formato:
   ```markdown
   ---
   type: concepto
   category: <tech|arquitectura|herramienta|practica>
   updated: <YYYY-MM-DD>
   ---
   # <Nombre>
   > <definición corta>
   ## Qué es
   <descripción del concepto>
   ## Proyectos que lo usan
   - [[Proyectos/<ProyectoActual>/<ProyectoActual>]]
   ## Patrones relacionados
   ## Lecciones
   ```
3. **Si existe**: agregar el proyecto a "Proyectos que lo usan" (si no está ya)

### Paso 5: Crear/enlazar notas de patrón

Para cada patrón detectado:
1. **Verificar si ya existe** en `Patrones/<Nombre>.md`
2. **Si no existe**: crear nota con formato:
   ```markdown
   ---
   type: patron
   category: <arquitectura|deploy|desarrollo|data>
   updated: <YYYY-MM-DD>
   ---
   # <Nombre>
   > <descripción del patrón>
   ## Qué es
   <explicación del patrón>
   ## Proyectos que lo usan
   - [[Proyectos/<ProyectoActual>/<ProyectoActual>]]
   ## Conceptos relacionados
   [[Conceptos/...]], ...
   ## Lecciones
   ```
3. **Si existe**: agregar el proyecto a "Proyectos que lo usan"

### Paso 6: Crear/enlazar decisiones

Si el proyecto tiene decisiones notables:
1. **Verificar si ya existe** una ADR similar en `Decisiones/`
2. **Si no existe**: crear `Decisiones/ADR-XXX <Título>.md` con formato:
   ```markdown
   ---
   type: decision
   status: aceptada
   date: <YYYY-MM-DD>
   ---
   # ADR-XXX: <Título>
   ## Estado
   Aceptada
   ## Contexto
   <por qué se tomó esta decisión>
   ## Decisión
   <qué se decidió>
   ## Consecuencias
   <positivas y negativas>
   ## Proyectos que la aplican
   - [[Proyectos/<ProyectoActual>/<ProyectoActual>]]
   ## Relacionado
   [[Conceptos/...]], ...
   ```
3. **Si existe**: agregar el proyecto a "Proyectos que la aplican"

### Paso 7: Crear/enlazar lecciones

Si el proyecto tiene lecciones notables:
1. **Verificar si ya existe** en `Lecciones/`
2. **Si no existe**: crear nota con formato:
   ```markdown
   ---
   type: leccion
   category: <rendimiento|arquitectura|herramienta|practica>
   updated: <YYYY-MM-DD>
   ---
   # <Nombre>
   > <qué aprendí>
   ## Qué es
   <descripción de la lección>
   ## De dónde viene
   - [[Proyectos/<ProyectoActual>/<ProyectoActual>]]
   ## Regla
   <regla práctica que se derivó>
   ## Relacionado
   [[Conceptos/...]], [[Patrones/...]], ...
   ```
3. **Si existe**: agregar el proyecto a "De dónde viene"

### Paso 8: Generar la ficha del proyecto

Crear/actualizar `Proyectos/<Nombre>/<Nombre>.md` con conexiones:

```markdown
---
type: proyecto
project: <Nombre>
path: <ruta absoluta>
stack: [<tech1>, <tech2>, ...]
arch: <monorepo|spa-api|microservicios|monolito|simple>
dominio: <categoría>
updated: <YYYY-MM-DD>
---

# <Nombre>

> <descripción de 1 línea>

## Qué hace

<2-3 líneas del propósito>

## Stack

| Capa | Tecnología | Detalle |
|------|-----------|---------|
| Frontend | ... | ... |
| Backend | ... | ... |

## Arquitectura

```
<árbol de carpetas>
```

## Servicios y puertos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|

## Comandos útiles

```bash
npm run dev
npm run build
```

## Agentes opencode

| Agente | Rol | Invocación |
|--------|-----|-----------|

## Conceptos que usa


## Patrones que sigue


## Decisiones clave



## Lecciones



## Dónde buscar más

- `docs/` — ...
- `.opencode/agents/` — ...

## Tags

#proyecto #typescript #react ...
```

### Paso 9: Verificar el hub

No existe catálogo aparte: las conexiones `[[...]]` entre notas son el mapa. Confirmar que `OpenBrainCode.md` (hub) y `_Dashboard.md` reflejen la nueva ficha y sus enlaces.

### Paso 10: Reportar

Informar:
- Ficha del proyecto creada/actualizada
- Conceptos creados/enlados
- Patrones creados/enlados
- Decisiones creadas/enladas
- Lecciones creadas/enladas
- Total de conexiones nuevas

## Ejemplo de salida

Al scrapear un proyecto `<Nombre>`, se genera:
- `Proyectos/<Nombre>/<Nombre>.md` (con conexiones)
- `Conceptos/React.md` (si no existía, o se agrega el proyecto)
- `Conceptos/Express.md`
- `Conceptos/SQLite.md`
- `Conceptos/Docker.md`
- `Conceptos/Biome.md`
- `Conceptos/TypeScript.md`
- `Conceptos/OpenCode.md`
- `Patrones/SPA + API.md`
- `Patrones/Monorepo.md`
- `Decisiones/ADR-001 <Título>.md`
- `Lecciones/...` (si hay)

Cada concepto/patrón enlaza de vuelta al proyecto y a otros proyectos que lo usan.
