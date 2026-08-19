---
type: proyecto
project: crm-front
path: C:\Users\eduar\OneDrive\Desktop\DelSud\Desarrollos\crm-front
stack:
  - React
  - Vite
  - MaterialUI
  - TanStack Query
arch: simple
dominio: inmobiliario-gestion
updated: 2026-08-19
---

# crm-front

> Panel de administración del sistema CRM de Grupodelsud (React 18 + Vite 5 + MUI 5), para la gestión de leads, clientes, desarrollos y reservas, que consume `crm-back`.

## Qué hace

SPA de administración del CRM: oportunidades/leads, clientes, desarrollos y lotes, reservas (wizard de 5 pasos), usuarios (CRM y Gestión), documentación, zonas, datos/targets y estadísticas. Consume la API de `crm-back` (`VITE_URL_API`, puerto 4005).

## Estado actual

En desarrollo / mantenido. Documentación centralizada en `docs/` (2026-08-14). El 2026-08-18 se migró el estado de servidor de Redux Toolkit a **TanStack Query** (migración completa, sin Redux en el repo), se quitaron la CSP del build y dependencias muertas, y se agregaron tests de performance (Playwright `perf`). El 2026-08-19 se migró el campo del documento de contacto de `numberId` a `documentNumber` (alineado con el rename de `Contacts.numberId` en crm-back). ADR-003/004 reconstruidos en el vault.

## Stack

| Capa | Tecnología | Detalle |
|------|-----------|---------|
| Frontend | React 18 / Vite 5 / MUI 5 | SPA, lazy loading, terser + chunk splitting |
| Estado servidor | TanStack Query 5 | `src/app/queryClient.js` + hooks por feature (`src/features/*/hooks/use*.js`) |
| Routing | React Router 7 | createBrowserRouter |
| Formularios | Formik + Yup | validación |
| HTTP | Axios | `src/shared/api/index.js`: baseURL `VITE_URL_API`, interceptor JWT con chequeo de expiración, redirección a /login |
| Mapas/gráficos/PDF | Leaflet · ApexCharts · pdfmake/@react-pdf | |
| Calidad/Tests | ESLint + Prettier · Vitest · Playwright | proyectos `public`, `routes`, `perf`, `booking-flow` |

> Nota: el `docs/data-layer.md` del repo quedó desactualizado (2026-08-19): aún describe Redux Toolkit + Zustand, que ya no existen en el código. Pendiente de corrección en el repo.

## Comandos útiles

```bash
npm run dev            # desarrollo (Vite)
npm run build          # build producción (terser, chunk splitting)
npm run preview        # vista previa del build
npm run test           # Vitest
npm run test:routes    # Playwright (proyectos public + routes)
npm run test:perf      # Playwright (proyecto perf: medidores DSR-453/454)
npm run test:booking-flow  # Playwright (flujo de reserva)
```

## Arquitectura

```
workspace: none
arch: simple
top_folders:
  docs
  public
  src
src/:
  app/        # App.jsx, main.jsx, queryClient.js, router, theme, layouts, pages
  features/   # account, auth, bookings, clients, contacts, dashboard, developments, documents, targets, users, zones (cada una con hooks use*)
  shared/     # api (axios + token), utils
```

## Servicios y puertos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| crm-front (SPA) | 5173 (dev) | Frontend Vite; consume crm-back en 4005 |

## Agentes opencode

- (sin agentes opencode)
<!-- /AUTO -->

## Documentación

- `docs/` — documentación centralizada del servicio (en `C:\Users\eduar\OneDrive\Desktop\DelSud\Desarrollos\crm-front\docs\README.md`): arquitectura, routing, módulos, data layer, API/integración, deployment.
- `AUDITORIA-hallazgos-2026-08-18.md` — hallazgos de la auditoría del 2026-08-18 (incluye la migración a React Query).
- `Decisiones/` — ADR-003 (validación MIME en DragDrop) y ADR-004 (reseteo de `fichaData`).
- `README.md` / `CHANGELOG.md` — del repo.

## Conceptos que usa

- (por completar)

## Patrones que sigue

- (por completar)

## Decisiones clave

- [[Proyectos/Desarrollos/crm-front/Decisiones/ADR-003-validacion-mime-dragdrop]] — validación programática de tipos MIME en subida de archivos.
- [[Proyectos/Desarrollos/crm-front/Decisiones/ADR-004-reset-estado-redux-fichaData]] — reseteo de `fichaData` entre navegaciones de reservas.
- Migración del estado de servidor a TanStack Query (2026-08-18) — fin de Redux Toolkit/Zustand en el repo; ver CHANGELOG.

## Lecciones

- (por completar)

## Dónde buscar más

- `docs/` del servicio (arquitectura, routing, módulos, data layer, API/integración, deployment).
- Backend consumido: `crm-back`.

## Historial (worklog)

- [[Proyectos/Desarrollos/crm-front/Worklog/2026-08-19]] — migración `numberId` → `documentNumber` + reestructuración `src/` + docs.
- [[Proyectos/Desarrollos/crm-front/Worklog/2026-08-18]] — migración a TanStack Query, remoción de CSP, dependencias muertas y `cancelAdvisorBooking`, tests de performance (DSR-453/454), auditoría de hallazgos.
- [[Proyectos/Desarrollos/crm-front/Worklog/2026-08-14]] — documentación centralizada + README + ADRs reconstruidos en el vault.