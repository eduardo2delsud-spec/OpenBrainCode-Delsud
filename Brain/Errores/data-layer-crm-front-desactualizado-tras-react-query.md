<!-- @brain error -->
---
type: error
category: practica
status: pendiente
updated: 2026-08-19
tags: [error, documentacion, desactualizado, crm-front, stack]
---

# docs/data-layer.md de crm-front describe Redux/Zustand que ya no existen

> Hallazgo de auditoría (2026-08-19): la documentación interna del repo quedó desactualizada tras la migración a TanStack Query y no refleja el stack real.

## Nivel

`practica` — documentación del repo que contradice el código.

## Contexto

- Proyecto: [[Proyectos/Desarrollos/crm-front/crm-front]]
- Stack: React 18 + Vite 5 + TanStack Query (ex Redux Toolkit + Zustand)
- Archivo: `C:\Users\eduar\OneDrive\Desktop\DelSud\Desarrollos\crm-front\docs\data-layer.md`

## Síntoma

`docs/data-layer.md` abre con "Hay dos sistemas de estado global conviviendo: **Redux Toolkit** (10 slices, con thunks) y **Zustand** (5 stores)" y describe `src/redux/store.js` con 10 slices y `src/api/index.js`. Esos archivos **no existen**: no hay carpeta `src/redux/` ni `src/api/`, y `package.json` no declara `@reduxjs/toolkit` ni `zustand`.

## Causa

El 2026-08-18 el front migró su estado de servidor de Redux Toolkit a **TanStack Query** (commit `270927e`: `src/App.jsx` → `src/app/App.jsx`, `src/api/` → `src/shared/api/`, nuevo `src/app/queryClient.js` + hooks `src/features/*/hooks/use*.js`). La doc `data-layer.md` se creó el 14/8 (antes de la migración) y no se reescribió al migrar; el mtime de `docs/` es del 19/8 pero el contenido quedó del 14/8.

## Solución / Fix

- Reescribir `docs/data-layer.md` en el repo: describir TanStack Query (`src/app/queryClient.js`, hooks por feature, staleTime/retry), la capa de red real (`src/shared/api/index.js`: `axios.create` con `baseURL: VITE_URL_API`, interceptor JWT con `hasExpiredToken` + redirect a `/login` y `PUBLIC_ENDPOINTS`) y eliminar toda mención a Redux/Zustand.
- Aplicar la regla: **la doc del repo se actualiza en el MISMO cambio que migra el stack** (ver Regla práctica).

## Regla práctica

- NUNCA dejar documentación describiendo un stack viejo al migrar de estado; la migración y la doc van en el mismo commit.
- Al auditar un frontend, verificar contra el código real (grep de imports) y no contra `docs/`.

## Prevención

- En la revisión de PRs de migración de stack, chequear que `docs/data-layer.md` (o el doc equivalente) cambie junto al código.
- En auditorías del vault: comparar ficha + `docs/` del repo con los imports reales (grep `@tanstack/react-query` / `@reduxjs/toolkit`).

## Keywords para /buscar

`data-layer`, `redux`, `zustand`, `tanstack query`, `react-query`, `crm-front`, `documentación desactualizada`

## De dónde viene

- Auditoría de servicios de Desarrollos del vault (2026-08-19) — [[Worklog/OpenBrainCode/2026-08-19]].

## Relacionado

- [[Proyectos/Desarrollos/crm-front/crm-front]] — ficha (ya refleja el stack real).
- [[Proyectos/Desarrollos/crm-front/Worklog/2026-08-18]] — migración a TanStack Query.