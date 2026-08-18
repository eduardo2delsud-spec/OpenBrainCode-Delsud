<!-- @brain acierto -->
---
type: acierto
category: herramienta
updated: 2026-08-18
tags: [acierto, herramienta, dead-code, limpieza, verificacion, plan]
---

# Verificar un plan de limpieza contra el código real antes de implementarlo

> Antes de ejecutar un plan de borrado/refactor, verificá cada afirmación contra el código, el lockfile y la doc: se detectaron ítems stale (ya resueltos) y una decisión de equipo documentada, evitando tocar lo que no correspondía.

## Qué pasó

- Se recibió un "Informe de depuración" del frontend con listas de archivos muertos, barrels huérfanos, assets sin uso y dependencias a eliminar.
- Se verificó a fondo: importadores reales por greps dirigidos, `package.json` vs `package-lock.json` vs `node_modules`, rutas del backend, y el `CHANGELOG.md` del repo.
- Se detectaron 3 errores de precisión en el plan: (1) `@babel/plugin-proposal-private-property-in-object` y `source-map-explorer` **ya habían sido eliminados** el 2026-08-14 (solo quedaban carpetas en `node_modules`); (2) eliminar `@mui/system` contradecía la decisión documentada del equipo de mantenerla explícita; (3) dos barrels clasificados como "usados" eran en realidad huérfanos.
- El usuario ratificó la eliminación de `@mui/system`. Implementación final: build OK (1790 módulos), lint sin errores nuevos.

## Por qué funcionó

- Verificar **qué existe hoy** (package.json, lock, imports reales, CHANGELOG) en lugar de confiar en el diagnóstico: un plan elaborado contra un snapshot anterior del repo queda stale.
- La documentación del propio repo (CHANGELOG con historial de decisiones) es fuente de verdad de decisiones de equipo que el código no expresa.
- `npm uninstall`/`npm install` como herramienta de mutación de `package.json`+lock (consistente), no edición manual.

## Contexto

- Proyecto: [[Proyectos/Desarrollos/gestion-desarrollos/gestion-desarrollos]]
- Stack: React + Vite + MUI 7, ESLint 9 flat config, npm
- Momento/versión: 2026-08-18, limpieza de dead code del frontend.

## Cómo repetirlo

1. Antes de implementar cualquier plan de limpieza, verificar **cada ítem** contra el estado actual: `rg` de importadores, contenido de barrels, `package.json`, `package-lock.json`, y rutas en el backend.
2. Revisar `CHANGELOG.md` del repo: puede contener decisiones de equipo (conservar deps) y trabajo ya hecho (ítems que el plan desconoce).
3. Cuando una decisión del plan contradice una decisión documentada, preguntar al usuario antes de ejecutar.
4. Cerrar siempre con build + lint como verificación de que no se rompió nada (el propio CHANGELOG documenta un dead-code cleanup previo que rompió runtime).

## Keywords para /buscar

`verificacion plan`, `limpieza`, `dead code`, `dependencias sin uso`, `changelog`, `decisiones de equipo`, `gestion-desarrollos`, `stack:react`

## De dónde viene

- Worklog 2026-08-18 de [[Proyectos/Desarrollos/gestion-desarrollos/gestion-desarrollos]].

## Relacionado

- [[Brain/Errores/...]] — si en el futuro un plan stale causa un bug, registrarlo acá como contraejemplo.