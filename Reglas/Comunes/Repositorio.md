<!-- @regla repositorio -->
---
type: regla
category: documentacion
area: estructura
updated: 2026-08-08
tags: [regla, repositorio, git, monorepo, changelog, readme]
---

# Repositorio — Regla de estructura (1 repo por servicio)

> Regla general de estructura para **proyectos nuevos**: cada servicio (deployable) del portafolio
> debe tener **su propio repo git**, su **propio `CHANGELOG.md`** y su **propio `README.md`**, salvo
> que el proyecto sea o vaya a ser un **monorepo**.

## Regla

Todo **servicio** que se cree (backend, frontend, microservicio, API, worker…) debe traer:

1. **Su propio repo git** — `git init` + remote propio, con su propio `.gitignore` (nunca `.env` real,
   `node_modules`, build outputs).
2. **Su propio `CHANGELOG.md`** — formato exacto de [[Reglas/Comunes/Changelog]]. Se actualiza en
   cada cambio funcional sin excepción.
3. **Su propio `README.md`** — estructura canónica de  Comunes/README Proyecto]], que alimenta
   al scraper.

## Excepción: monorepo

Si el proyecto **es o va a ser monorepo** (workspace que agrupa varios servicios bajo **un solo repo**),
los servicios **NO** llevan repo propio: comparten el repo del monorepo. Pero **cada servicio igual
conserva su `CHANGELOG.md` y su `README.md` individuales** dentro de su subcarpeta (p. ej.
`packages/<servicio>/` o `servicios/<servicio>/`), con frontmatter/proyecto propio.

## Cómo se decide

- **Frontend + Backend separados** (SPA + API) → **2 servicios, 2 repos** por defecto.
  (Nada impide agruparlos en monorepo si así se decide.)
- **Servicios acoplados / coexistentes** que comparten deploy o entorno → **monorepo**.

La decisión la toma el agente `pm` (o quien orquesta); el criterio por defecto es **un repo por
servicio** salvo decisión explícita de monorepo.

## Quién la aplica

- **`pm`**: decide monorepo vs repos separados y comunica la estructura al delegar.
- **`backend`** / **`frontend`** (subagentes): al scaffoldear/crear un servicio, aseguran su repo +
  changelog + readme propios (salvo que el brief diga "monorepo").
- Skill **`nuevo-proyecto-base`**: crea el remote + `.gitignore` + `CHANGELOG.md` + `README.md` por servicio en el scaffold.

## Relacionado

- [[Reglas/Comunes/Documentacion]] — qué documentación es obligatoria y cuándo se actualiza.
- [[Reglas/Comunes/Changelog]] — formato de entradas de changelog.
- [[Reglas/Comunes/README Proyecto]] — estructura canónica del README.
- [[Reglas/Comunes/Arranque VSCode]] — tasks por servicio.