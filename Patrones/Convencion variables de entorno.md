---
type: patron
category: arquitectura
updated: 2026-08-18
tags: [patron, config, environment, variables-de-entorno]
---

# Convención variables de entorno

> Patrón de gestión de variables de entorno que emerge de gestion-desarrollos-back (centralizado) y gestion-desarrollos/crm-front (Vite). Fuente de truth del proyecto = `.env.example`; el código nunca lee `process.env` disperso.

## Qué es

Un enfoque por capas para manejar env vars con **un solo punto de entrada validado**:

1. **`.env.example` como fuente de truth documentada** — toda variable que el código usa está declarada (con default y comentario). El `.env` local copia y completa valores reales (nunca se commitea).
2. **Validación fail-fast** — backend: `config.ts` valida con Joi al arranque (`NODE_ENV`, tipos, enum, defaults) y aborta con el detalle de cada variable faltante. Frontend: Vite solo expone `import.meta.env.VITE_*` (compilado en build).
3. **Acceso centralizado** — backend: un objeto `config` (tipado) expone las variables; los services importan `config` y nunca leen `process.env.*`. Frontend: solo `import.meta.env.VITE_*` (nunca `process.env`, que no existe en el navegador).
4. **Requerida según ambiente** — Joi `.when("NODE_ENV", ...)`: p. ej. `AWS_*` opcional en `development` (el backend local arranca sin credenciales) y requerida en `test`/`production`.
5. **Default para no romper** — las opcionales llevan default (`awsBucketUrl` → `""`, `LOG_LEVEL` → `info`, `FROM_EMAIL` → `info@desarrollosdelsud.com.ar`), y las concatenaciones de URL/proxy protegen contra ausencia de barra final.
6. **Matriz por ambiente documentada** — tabla en `docs/entorno.md` (backend) y `docs/deployment.md` (frontend) con qué es requerido en dev/test/prod.

## Cuándo usarla

- Cualquier servicio nuevo del stack (backend Express+Drizzle o SPA Vite).
- Cuando un `.env` crece y empiezan a aparecer variables obsoletas o leídas desde varios archivos.
- Para que un desarrollador nuevo levante el proyecto sin adivinar credenciales (AWS opcional en dev, etc.).

## Proyectos que lo usan

- [[Proyectos/Desarrollos/gestion-desarrollos-back]] — `config.ts` (Joi fail-fast + `config` tipado + `.when` por ambiente), `docs/entorno.md` con matriz.
- [[Proyectos/Desarrollos/gestion-desarrollos]] — `import.meta.env.VITE_*` unificado, fallbacks al bucket real y `docs/deployment.md`.

## Conceptos relacionados

- [[Conceptos/Template Concepto]]

## Lecciones

- [[Lecciones/Template Lección]]
