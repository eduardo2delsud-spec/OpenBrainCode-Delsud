---
type: proyecto
project: gestion-desarrollos
path: C:\Users\edu\Desktop\DelSud\Desarrollos\gestion-desarrollos
stack:
  - React
  - Vite
  - MaterialUI
  - TanStack Query
  - Zustand
arch: simple
dominio: inmobiliario-gestion
updated: 2026-08-18
---

# gestion-desarrollos

> SPA de administración de la plataforma de Gestión de Desarrollos de Grupodelsud (React 18 + Vite 5 + MUI 7), que consume `gestion-desarrollos-back`.

## Qué hace

Panel de administración con dos áreas — **Administración** (clientes, reservas, boletos, lotes, caja, usuarios) y **Cobranza** (caja, stock, clientes, índices/IPC) — sobre la API REST de `gestion-desarrollos-back` (`/api/v1`, puerto 4001). Estado de servidor con TanStack Query, estado local con Zustand/Context, UI con MUI 7.

## Estado actual

En desarrollo / mantenido. Documentación centralizada en `docs/` (2026-08-14). El `docs/` previo se limpió en el commit `c8e9dfd`.

## Stack

| Capa | Tecnología | Detalle |
|------|-----------|---------|
| Frontend | React 18 / Vite 5 / MUI 7 | SPA, lazy loading, chunk splitting (terser) |
| Estado servidor | TanStack Query 5 | staleTime 5 min, retry sin 401/403 |
| Estado local | Zustand + React Context | usersStore, authContext, sideNavContext |
| Routing | React Router 7 | createBrowserRouter |
| Formularios | Formik + Yup | validación |
| HTTP | Axios | interceptor JWT, redirección a /login |
| Calidad | ESLint 9 (flat) + Prettier | lint/format |

## Comandos útiles

```bash
npm run dev            # desarrollo (Vite)
npm run build          # build producción (chunk splitting)
npm run lint           # ESLint
npm run format         # Prettier
```

## Arquitectura

```
workspace: none
arch: simple
top_folders:
  docs
  public
  src
```

## Servicios y puertos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| gestion-desarrollos (SPA) | 5173 (dev) | Frontend Vite; consume back en 4001 |

## Agentes opencode

- (sin agentes opencode)
<!-- /AUTO -->

## Documentación

- `docs/` — documentación centralizada del servicio (en `C:\Users\edu\Desktop\DelSud\Desarrollos\gestion-desarrollos\docs\README.md`): arquitectura, routing, módulos, data layer, API/integración, deployment.
- `README.md` / `CHANGELOG.md` — del repo.

## Conceptos que usa

- (por completar)

## Patrones que sigue

- (por completar)

## Decisiones clave

- (por completar)

## Lecciones

- (por completar)

## Dónde buscar más

- `docs/` del servicio (arquitectura, routing, módulos, data layer, API/integración, deployment).
- Backend consumido: `gestion-desarrollos-back`.

## Historial (worklog)

- [[Proyectos/Desarrollos/gestion-desarrollos/Worklog/2026-08-18]] — limpieza de dead code del frontend: archivos muertos, barrels huérfanos, assets de `public/` sin uso, `@mui/system` removido, `globals` agregado a devDeps, hook `useClientDebtSummary` (ruta inexistente) eliminado.
- [[Proyectos/Desarrollos/gestion-desarrollos/Worklog/2026-08-14]] — documentación centralizada + README + resolución de conflicto de changelog + limpieza de dependencias sin uso.