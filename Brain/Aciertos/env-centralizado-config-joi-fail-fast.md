---
type: acierto
category: config
project: gestion-desarrollos-back
date: 2026-08-18
tags: [acierto, env, config, joi, centralizacion]
---

# Env centralizado en config (Joi fail-fast) + AWS opcional en dev

> Registro crudo del acierto. Versión curada como patrón: [[Patrones/Convencion variables de entorno]].

## Síntesis

Centralizar el acceso a variables de entorno en un objeto `config` tipado, validado al arranque con Joi y con variables `AWS_*` **opcionales en development** — aplicado a `gestion-desarrollos-back`.

## Qué funcionó

- El relevamiento encontró 19 lecturas dispersas de `process.env.AWS_BUCKET_URL` en 5 services, variables obsoletas sin uso y otras usadas sin estar documentadas.
- `config.ts` quedó como **único** lector de `process.env` (verificado por grep) y expone campos tipados (`logLevel`, `sendgridApiKey`, `awsBucketUrl`, etc.) que los services importan.
- El boot **sin credenciales AWS** en dev funciona: arranca, conecta DBs y responde `GET /api/v1/health` → 200 `ok` (antes Joi abortaba por `AWS_*` requeridas).
- Joi fail-fast imprime la lista de variables faltantes y sale con error: onboarding sin adivinar.
- Matriz dev/test/prod documentada en `docs/entorno.md` (backend) y `docs/deployment.md` (frontend, mismo patrón con `import.meta.env.VITE_*`).

## Claves para repetir

- Joi `.when("NODE_ENV", { is: "development", then: optional, otherwise: required })` para secretos de infraestructura.
- Defaults en Joi y en el objeto `config` (`|| ""`), con concatenaciones protegidas ante falta de barra final.
- Regla dura: ningún service toca `process.env`; todo entra por `config`.
- Frontend: nunca `process.env` en el navegador; unificar en `import.meta.env.VITE_*` con fallback al valor real de prod.

## Keywords

env, variables de entorno, config.ts, Joi, fail-fast, process.env, AWS, import.meta.env, VITE, .env.example, entorno.md
