---
type: decision
status: accepted
accepted: 2026-08-24
date: 2026-08-24
project: VIZTA
updated: 2026-08-24
tags: [decision, arquitectura, base-de-datos, postgresql, consolidacion]
---

# ADR-0010 — Consolidación a PostgreSQL única

## Contexto

El sistema actual opera con 2 bases de datos MySQL separadas (`crmdesarrollos` y `gestiondesarrollos`). `crm-back` escribe en ambas via cross-DB sync. `gestion-back` lee de la DB CRM pero escribe en la suya. Esto genera:

- Sincronización frágil (proceso custom `gestionSync.js`)
- Foreign keys lógicas no enforceables entre DBs
- Patrones de saga complejos para mantener consistencia
- Duplicación de usuarios y reservas en ambas DBs

## Decisión

**Una sola base de datos PostgreSQL** que reemplaza ambas MySQL. Ambos backends (`crm-back` y `gestion-back`) conectan a la misma DB.

### Stack definido

| Capa | Tecnología |
|------|-----------|
| Backend | TypeScript + Express 5 + Drizzle ORM + Biome |
| Frontend | JavaScript + React + Vite + MUI |
| Base de datos | **PostgreSQL** (única) |
| ORM | Drizzle ORM (dialect `pg`) |
| Driver | `pg` (node-postgres) |

### Estructura de repos

- **crm-back** → se migra de JS/Sequelize/MySQL a TS/Drizzle/PostgreSQL
- **gestion-back** → se adapta de MySQL a PostgreSQL (ya es TS/Drizzle)
- Ambos apuntan a la misma DB
- Schema nuevo desde cero (sin migrar datos MySQL existentes)

### Esquema propuesto

5 schemas lógicos:

```
auth          → users, roles
crm           → contacts, lots, developments, quotations, agenda, etc.
operations    → bookings, contracts, installments, payments, etc.
financials    → commissions, wallets
admin         → ipc_indices, lot_records, notifications, templates
```

Total: **39 tablas** (vs 46 actuales).

## Consecuencias

### Positivas

- Consistencia referencial real (FKs en DB)
- Eliminación de cross-DB sync y saga pattern
- Queries transversales con JOINs en una sola query
- Mantenimiento simplificado (un esquema, un set de migraciones)
- Rendimiento mejorado (sin overhead de sincronización)

### Negativas

- Acoplamiento entre servicios (mitigado con schemas lógicos)
- Migración de esquema compleja (se decide hacer desde cero)
- Deploy coordinado de ambos backends

## Estado

**Aceptado** — 2026-08-24. Pendiente de implementación hasta que se cierren los userflows de Administración y Cobranzas.

## Referencias

- [[Conceptos/base-de-datos-unificada]]
- [[Conceptos/diagrama-entidad-relacion]]
- [[Proyectos/VIZTA/VIZTA]]
- `C:\Users\eduar\OneDrive\Desktop\DelSud\Vizta\DER VIZTA — Documento Completo.md`
