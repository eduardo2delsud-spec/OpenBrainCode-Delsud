---
type: proyecto
project: crm-back
path: C:\Users\edu\Desktop\DelSud\Desarrollos\crm-back
stack:
  - Node
  - Express
  - JavaScript
  - Sequelize
  - MySQL
arch: simple
dominio: inmobiliario-gestion
updated: 2026-08-14
---

# crm-back

> API principal del sistema CRM de Grupodelsud (Node 18 + Express 4 + Sequelize 6 + MySQL), que gestiona clientes, leads, reservas y procesos de venta, con base de datos dual (CRM + Gestión).

## Qué hace

Backend REST del CRM: contacto/clientes, desarrollos y lotes, reservas (booking), usuarios y roles, estadísticas del asesor, targets mensuales, exportaciones y usuarios de Gestión. Sincroniza reservas y clientes con la base de la plataforma de Gestión Desarrollos.

## Estado actual

En desarrollo / mantenido. Documentación centralizada en `docs/` (2026-08-14).

## Stack

| Capa | Tecnología | Detalle |
|------|-----------|---------|
| Runtime | Node.js 18+ | JavaScript ES6+ con Babel |
| Framework | Express 4.18 | cluster 4 workers en producción |
| ORM | Sequelize 6 | 25 modelos CRM + 4 Gestión |
| Base de datos | MySQL | dual: `DB_NAME` + `DB_GESTION_NAME` |
| Autenticación | JWT (Bearer, HS256) | 5 middlewares de rol |
| Archivos | AWS SDK v2 (S3) | multer memoryStorage |
| Email | Nodemailer + SendGrid | SMTP |
| Tareas | node-cron | vencimiento de reservas (cada hora) |
| Excel/PDF/Img | ExcelJS · PDFKit · Sharp | exportaciones, fichas, imágenes |

## Comandos útiles

```bash
npm run dev            # nodemon + babel-node
npm run build          # babel src → dist
npm start              # producción (dist)
npm run start:adapter  # adaptador de integración
npm run migrate        # migraciones Sequelize
npm run seeders        # seeders de documentos
```

## Arquitectura

```
workspace: none
arch: simple
top_folders:
  docs
  scripts
  src
```

## Servicios y puertos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| crm-back (API) | 4005 (`PORT`) | Express; prefijos `/api/client`, `/api/admin`, `/api/users`, `/api/web`, `/api/adapter` + `/health` |

## Agentes opencode

- (sin agentes opencode)
<!-- /AUTO -->

## Documentación

- `docs/` — documentación centralizada del servicio (en `C:\Users\edu\Desktop\DelSud\Desarrollos\crm-back\docs\README.md`): arquitectura, catálogo de endpoints, base de datos, módulos, integraciones y entorno.
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

- `docs/` del servicio (arquitectura, api-endpoints, base-de-datos, modulos, integraciones, entorno).
- Frontend que consume: `crm-front`.

## Historial (worklog)

- [[Proyectos/Desarrollos/crm-back/Worklog/2026-08-14]] — documentación centralizada + README actualizado.