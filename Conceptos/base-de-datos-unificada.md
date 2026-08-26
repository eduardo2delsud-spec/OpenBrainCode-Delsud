---
type: concepto
category: arquitectura
updated: 2026-08-26
tags: [base-de-datos, postgresql, consolidacion, arquitectura]
created: 2026-08-24
---

# Base de datos unificada

> Decisión de consolidar múltiples bases de datos en una única PostgreSQL para el proyecto [[Proyectos/VIZTA/VIZTA]].

## Qué es

Una sola base PostgreSQL que reemplaza las dos MySQL del ecosistema Desarrollos (`crmdesarrollos` + `gestiondesarrollos`). Ambos backends (`crm-back` y `gestion-back`) conectan a la misma DB con esquema compartido, eliminando el cross-DB sync, el saga pattern y los usuarios duplicados.

## Contexto

El sistema actual de [[Proyectos/Desarrollos/crm-back/crm-back|CRM]] y [[Proyectos/Desarrollos/gestion-desarrollos-back/gestion-desarrollos-back|Gestión]] opera con **2 bases de datos MySQL separadas**:

- `crmdesarrollos` — CRM del asesor (contactos, reservas, publicaciones, lotes)
- `gestiondesarrollos` — Gestión/Admin/Cobranzas (contratos, cuotas, pagos, caja)

`crm-back` escribe en AMBAS DBs (cross-DB sync vía `gestion-db.js`). `gestion-back` LEE de la DB CRM pero escribe en la suya. Ambos comparten el mismo JWT secret.

### Problemas de la dualidad

1. **Sincronización frágil:** `crm-back` sincroniza datos a la DB de gestión via un proceso custom (`gestionSync.js`). Si falla, los datos se desincronizan.
2. **FKs lógicas no enforceables:** Las foreign keys entre DBs son solo lógicas (no hay constraints reales).
3. **Sagas complejas:** `gestion-back` necesita patrones de saga (compensating transactions) para mantener consistencia cross-DB.
4. **Duplicación de usuarios:** Users existen en ambas DBs con esquemas diferentes (CRM: numérico `roleId`, Gestión: ENUM `rol`).
5. **Duplicación de reservas:** Bookings existen en ambas DBs (CRM: tabla completa, Gestión: tabla puente con `crmBookingId`).

## Decisión

**Una sola PostgreSQL** que reemplaza ambas MySQL. Ambos backends (`crm-back` y `gestion-back`) conectan a la misma DB.

### Beneficios

| Beneficio | Descripción |
|-----------|-------------|
| Consistencia referencial | FKs reales entre todas las tablas |
| Eliminación de sync | No hay cross-DB sync, no hay saga pattern |
| Queries transversales | JOINs entre CRM y Gestión en una sola query |
| Mantenimiento | Un esquema, un Drizzle config, un set de migraciones |
| Rendimiento | Sin overhead de conexiones duales ni sincronización |

### Trade-offs

| Trade-off | Mitigación |
|-----------|------------|
| Acoplamiento entre servicios | Mantener schemas lógicos separados (auth, crm, operations, financials, admin) |
| Migración de esquema | Schema nuevo desde cero (no migrar datos MySQL existentes) |
| Rolling update | Deploy coordinado de ambos backends |

## Esquema propuesto

5 schemas lógicos en PostgreSQL:

```
vizta
├── auth          → users, roles
├── crm           → contacts, lots, developments, quotations, agenda
├── operations    → bookings, contracts, installments, payments
├── financials    → commissions, wallets
└── admin         → ipc_indices, lot_records, notifications, templates
```

Total: **45 tablas** según el DBML vigente (`ViztaDocs/Schema/vizta-dbdiagram.dbml`, 25/08/2026).

## Proyectos que lo usan

- [[Proyectos/VIZTA/VIZTA]] — decisión ADR-0010; ambos backends apuntan a la misma PostgreSQL
- [[Proyectos/Desarrollos/crm-back/crm-back]] y [[Proyectos/Desarrollos/gestion-desarrollos-back/gestion-desarrollos-back]] — migran de MySQL dual a esta DB única

## Patrones relacionados

- (sin patrones vinculados todavía)

## Lecciones

- (sin lecciones todavía)

## Referencias

- [[Proyectos/VIZTA/VIZTA]] — ficha del proyecto
- [[Decisiones/ADR-0010 Consolidacion a PostgreSQL unica]] — ADR
- `C:\Users\eduar\OneDrive\Desktop\DelSud\Vizta\ViztaDocs\DER VIZTA - Documento Completo.md` — DER completo
- `C:\Users\eduar\OneDrive\Desktop\DelSud\Vizta\ViztaDocs\Schema\vizta-dbdiagram.dbml` — schema canónico (DBML)
