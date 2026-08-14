---
type: proyecto
project: crm-front
path: C:\Users\edu\Desktop\DelSud\Desarrollos\crm-front
stack:
  - React
  - Vite
  - MaterialUI
  - Redux Toolkit
  - Zustand
arch: simple
dominio: inmobiliario-gestion
updated: 2026-08-14
---

# crm-front

> Panel de administración del sistema CRM de Grupodelsud (React 18 + Vite 5 + MUI 5), para la gestión de leads, clientes, desarrollos y reservas, que consume `crm-back`.

## Qué hace

SPA de administración del CRM: oportunidades/leads, clientes, desarrollos y lotes, reservas (wizard de 5 pasos), usuarios (CRM y Gestión), documentación, zonas, datos/targets y estadísticas. Consume la API de `crm-back` (`VITE_URL_API`, puerto 4005).

## Estado actual

En desarrollo / mantenido. Documentación centralizada en `docs/` (2026-08-14). ADR-003/004 reconstruidos en el vault.

## Stack

| Capa | Tecnología | Detalle |
|------|-----------|---------|
| Frontend | React 18 / Vite 5 / MUI 5 | SPA, lazy loading, terser + chunk splitting |
| Estado servidor | Redux Toolkit (10 slices) + thunks | clientes, desarrollos, ficha, home, docs, service, zones, datos |
| Estado local | Zustand (5 stores) | bookings, bookingsAdmin, contacts, users, gestionUsers |
| Routing | React Router 7 | createBrowserRouter |
| Formularios | Formik + Yup | validación |
| HTTP | Axios | interceptor JWT, redirección a /login |
| Mapas/gráficos/PDF | Leaflet · ApexCharts · pdfmake/@react-pdf | |
| Calidad | ESLint (react-app) + Prettier | |

## Comandos útiles

```bash
npm run dev            # desarrollo (Vite)
npm run build          # build producción (terser, chunk splitting)
npm run preview        # vista previa del build
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
| crm-front (SPA) | 5173 (dev) | Frontend Vite; consume crm-back en 4005 |

## Agentes opencode

- (sin agentes opencode)
<!-- /AUTO -->

## Documentación

- `docs/` — documentación centralizada del servicio (en `C:\Users\edu\Desktop\DelSud\Desarrollos\crm-front\docs\README.md`): arquitectura, routing, módulos, data layer, API/integración, deployment.
- `Decisiones/` — ADR-003 (validación MIME en DragDrop) y ADR-004 (reseteo de `fichaData`).
- `README.md` / `CHANGELOG.md` — del repo.

## Conceptos que usa

- (por completar)

## Patrones que sigue

- (por completar)

## Decisiones clave

- [[Proyectos/Desarrollos/crm-front/Decisiones/ADR-003-validacion-mime-dragdrop]] — validación programática de tipos MIME en subida de archivos.
- [[Proyectos/Desarrollos/crm-front/Decisiones/ADR-004-reset-estado-redux-fichaData]] — reseteo de `fichaData` entre navegaciones de reservas.

## Lecciones

- (por completar)

## Dónde buscar más

- `docs/` del servicio (arquitectura, routing, módulos, data layer, API/integración, deployment).
- Backend consumido: `crm-back`.

## Historial (worklog)

- [[Proyectos/Desarrollos/crm-front/Worklog/2026-08-14]] — documentación centralizada + README + ADRs reconstruidos en el vault.