<!-- @regla convenciones-backend -->
---
type: regla
category: backend
area: convenciones
updated: 2026-08-06
tags: [regla, backend, config, env, errores, secretos]
---

# Convenciones Backend — Regla de todo proyecto

> Regla normativa transversal para **todo backend** del portafolio. Complementa
> [[Reglas/Backend/Arranque Backend]] con las obligaciones y prohibiciones que aplican siempre. Los "cómo"
> estructurales viven en los patrones `api-http`, `autenticacion-jwt-roles` y `base-datos-pool-y-migraciones`.

## 1. Configuración: una única fuente + validación al arranque

- **Un solo módulo de config** (`core/config/index.ts` o `shared/config.ts`) centraliza TODA la lectura
  de `process.env` con defaults inline. Prohibido leer `process.env` disperso en módulos/controllers.
- **Validar al arranque (fail-fast):** validar las variables críticas (required, tipo, número) — con
  Zod o manual — y abortar con un error claro si falta algo. No arrancar "a medias".
- `.env.example` completo y versionado = fuente de truth de defaults.
- **Prohibido duplicar secrets** (`JWT_SECRET`, API keys) entre archivos del proyecto.

## 2. Respuesta y errores uniformes

- Error SIEMPRE `{ error: "<mensaje>" }` con el status HTTP correcto; `payload` directo para éxito.
- **Prohibido** `try/catch` que responda directamente desde el controller: se lanza la excepción de
  negocio y responde el error handler central.
- Stack trace solo en `NODE_ENV !== 'production'`.

## 3. Secretos

- Nunca loguear secretos/API keys. Si mostrás una URL de conexión, **sanitizarla** (ej. reemplazar la
  password: `//***:***@`). Ver [[Reglas/Backend/Arranque Backend]].
- Secrets en repo nunca: solo `.env` (gitignored) y defaults de dev.

## Proyectos que la aplican

- Se aplica a todo backend del portafolio; el state caveat histórico de proyectos con duplicación de
  env/secret y try/catch ad-hoc queda al revisar cada proyecto.

## Relacionado

- Patrones `api-http` · `autenticacion-jwt-roles` · `base-datos-pool-y-migraciones` — cómo implementar.
- [[Reglas/Backend/Arranque Backend]] · [[Reglas/Comunes/Documentacion]]