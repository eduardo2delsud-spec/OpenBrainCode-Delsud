---
type: proyecto
project: gestion-desarrollos-back
path: C:\Users\eduar\OneDrive\Desktop\DelSud\Desarrollos\gestion-desarrollos-back
stack:
  - Express
  - Drizzle
  - MySQL
  - TypeScript
  - JWT
arch: simple
dominio: inmobiliario-gestion
updated: 2026-08-20
---

# gestion-desarrollos-back

> Backend del sistema de Gestión de Desarrollos de Grupodelsud: reservas, contratos, cuotas, caja y flujo de cobranza, integrado con el CRM inmobiliario.

## Qué hace

API REST (Express 5 + TypeScript + Drizzle ORM) sobre **MySQL dual** (DB local de gestión + DB del CRM como referencia/escrituras acotadas). Cubre el ciclo de reservas y certificación de boletos, contratos y refinanciación, cuotas/pagos, caja y cobranza, dashboard, lotes, IPC, reclamos, stock, notificaciones, historial, email (SendGrid) y almacenamiento S3. Prefijo `/api/v1`, puerto `4001`.

## Estado actual

En desarrollo / mantenido. Documentación centralizada en `docs/` (2026-08-14). Últimas versiones orientadas a optimización de queries (fin de N+1, batch, cache TTL, índices) — ver CHANGELOG.

## Stack

| Capa | Tecnología | Detalle |
|------|-----------|---------|
| Backend | Node.js 20+ / Express 5 / TypeScript 5 | API REST, `/api/v1`, puerto 4001 |
| Persistencia | Drizzle ORM + mysql2 | MySQL dual: local (`gestion_desarrollos_{dev,test,prod}`) + CRM |
| Auth | JWT + bcryptjs | `verifyAccessToken` + RBAC (`requireRole`) |
| Validación | Joi | `validateSchema` + fail-fast de env |
| Integraciones | AWS S3, SendGrid, node-cron | Presigned URLs, email transaccional, cron diario 00:01 |
| Calidad | Biome, esbuild + tsc-alias | lint/format/check, build |

## Comandos útiles

```bash
npm run dev              # desarrollo (tsx watch)
npm run build            # esbuild + tsc-alias + copy-assets
npm run typecheck        # tsc --noEmit
npm run db:migrate       # migraciones locales
npm run db:seed          # datos base
npm run db:up            # esquema dev
npm run check            # Biome
```

## Arquitectura

```
workspace: none
arch: simple
top_folders:
  docs
  drizzle
  drizzle-crm
  postman
  scripts
  src
```

## Servicios y puertos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| gestion-desarrollos-back | 4001 | API Express (`/api/v1`) |

## Agentes opencode

- (sin agentes opencode)
<!-- /AUTO -->

## Documentación

- `docs/` — documentación centralizada del servicio (en `C:\Users\eduar\OneDrive\Desktop\DelSud\Desarrollos\gestion-desarrollos-back\docs\README.md`): arquitectura, módulos, endpoints, base de datos, diagramas ER, integraciones, entorno.
- `README.md` / `CHANGELOG.md` — del repo.

## Conceptos que usa

- (por completar)

## Patrones que sigue

- [[Patrones/Convencion variables de entorno]] — `config.ts` centraliza y valida env con Joi (fail-fast), `AWS_*` opcional en dev, matriz por ambiente en `docs/entorno.md` (2026-08-18).

## Decisiones clave

- **Atomicidad dual-DB con saga CRM-first** (2026-08-20, cierre de los hallazgos 4.1–4.4): toda operación que escribe en DB local + CRM corre como saga — fase CRM (`crmDb.transaction`) con snapshot previo → fase local (`db.transaction` propia) → compensación exhaustiva desde el snapshot si la local falla; `FOR UPDATE` + re-check para disponibilidad de lotes. Detalle en [[Lecciones/atomicidad-dual-db-saga-crm-first]] y el worklog 2026-08-20.

## Lecciones

- [[Lecciones/atomicidad-dual-db-saga-crm-first]] — patrón saga CRM-first para atomicidad entre dos MySQL independientes.

## Dónde buscar más

- `docs/` del servicio (arquitectura, módulos, endpoints, base de datos, integraciones, entorno).
- `postman/DESARROLLOS-GESTION.postman_collection.json` — colección de la API.

## Historial (worklog)

- [[Proyectos/Desarrollos/gestion-desarrollos-back/Worklog/2026-08-20]] — atomicidad dual-DB: saga CRM-first en cancelaciones/devoluciones/completaciones de reservas, `editReservation`, `createNewReservation`, `externalSold`, `certifyCancel`, `addDocumentToBooking`, `addAttachment`; nuevo `src/core/sagas.ts`; helpers tx-aware.
- [[Proyectos/Desarrollos/gestion-desarrollos-back/Worklog/2026-08-18]] — estandarización de variables de entorno: `.env.example`/`.env` limpiados (obsoletas eliminadas, faltantes documentadas), `AWS_*` opcional en development (boot local sin credenciales S3), acceso centralizado en `config` (sin `process.env` disperso), matriz por ambiente en `docs/entorno.md` + diagramas entidad-relación en `docs/diagrams.md` (ER DB local, ER CRM, puente local↔CRM).
- [[Proyectos/Desarrollos/gestion-desarrollos-back/Worklog/2026-08-14]] — documentación centralizada + README.