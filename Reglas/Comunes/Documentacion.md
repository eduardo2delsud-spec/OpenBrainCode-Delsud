<!-- @regla documentacion -->
---
type: regla
category: documentacion
area: documentacion
updated: 2026-08-06
tags: [regla, documentacion, changelog, readme, semver]
---

# Documentación — Regla de todo proyecto

> Regla general de documentación para **cualquier** proyecto de software.
> Define qué documentación es OBLIGATORIA y cuándo se actualiza. El formato de cada entrada de changelog vive en [[Reglas/Comunes/Changelog]].

## Regla de oro — CHANGELOG obligatorio en cada cambio funcional

Cualquier implementación, modificación de funcionalidad existente, refactor, fix o cambio de
comportamiento **DEBE** actualizar `CHANGELOG.md`. Sin excepción. Esto incluye cambios en: código,
endpoints, workflows, estructura de proyecto, configuración, skills, agentes y scripts.

## Regla de estructura — 1 repo por servicio

En proyectos **nuevos**, cada servicio debe traer **su propio repo git + `CHANGELOG.md` + `README.md`**
(salvo monorepo). Ver [[Reglas/Comunes/Repositorio]]. Se aplica a todo servicio que se cree.

## Qué actualizar con cada cambio

| Archivo | Cuándo |
|---------|--------|
| `CHANGELOG.md` | SIEMPRE (regla de oro). Formato: [[Reglas/Comunes/Changelog]] |
| `README.md` | Si se añaden/eliminan endpoints, nuevas secciones, cambios de setup. Estructura: [[Reglas/Comunes/README Proyecto]] |
| `AGENTS.md` | Si se añaden/eliminan agentes, skills, o cambia la estructura del proyecto |

Si el cambio afecta frontend **y** backend, se documenta en los changelogs de AMBOS lados (mismo
título/categoría, enfoque en los archivos de cada lado).

## Semver

Versión según criterio semver:

- **MAJOR** — cambio que rompe compatibilidad (breaking).
- **MINOR** — nueva funcionalidad (compatible).
- **PATCH** — bugfix o mejora menor.

## Patrón `@register`

Un agente/rol dedicado (ej. `@register`) es el encargado de commitear y actualizar changelogs y
documentación, pero **cada agente** debe dejar claro qué documentación necesita actualización tras
su cambio. El autor puede asumir ese rol manualmente.

## Cómo se aplica

opencode lo aplica vía la skill **`nuevo-proyecto-base`** (crea `CHANGELOG.md`, `README.md` y `AGENTS.md`
desde el arranque) y en cualquier proyecto al generar/registrar cambios.

## Relacionado

- [[Reglas/Comunes/Repositorio]] — 1 repo por servicio (git + changelog + readme).
- [[Reglas/Comunes/Changelog]] — formato de entradas.
- [[Reglas/Comunes/README Proyecto]] — estructura canónica del README.
- [[Reglas/Backend/Arranque Backend]] · [[Reglas/Frontend/Arranque Frontend]] — estructura de nuevos proyectos.