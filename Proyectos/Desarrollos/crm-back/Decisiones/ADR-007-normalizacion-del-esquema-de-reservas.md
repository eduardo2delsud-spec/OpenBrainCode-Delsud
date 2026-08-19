---
type: decision
status: aceptada
accepted: 2026-08-18
updated: 2026-08-19
project: crm-back
tags: [decision, adr, reservas, esquema, crm]
---

# ADR-007 — Normalización del esquema de reservas

> Decisión del proyecto `crm-back`. La **fuente canónica vive en el repo**: `C:\Users\eduar\OneDrive\Desktop\DelSud\Desarrollos\crm-back\docs\adr\ADR-007-normalizacion-del-esquema-de-reservas.md`. Esta nota es el enlace desde el vault, no una copia.

## Contexto

El esquema de reservas del CRM arrastra asimetrías (por ejemplo `Bookings.numberId2`, el documento del firmante 2, conviviendo con el rename de `Contacts.numberId` → `documentNumber` del 2026-08-13/19) y necesita normalizarse.

## Decisión

Normalizar el esquema de reservas de `crm-back` según lo detallado en el ADR del repo (`docs/adr/ADR-007-...`), que define el plan de reestructuración de la tabla `Bookings` y sus firmantes.

## Consecuencias

- El front migró el campo del documento del firmante 1 a `documentNumber` (2026-08-19); `numberId2` se resolverá junto con la reestructuración de esa tabla.
- crm-back removió la compatibilidad dual `numberId`/`documentNumber` (2026-08-19).
- Ver también: [[Proyectos/Desarrollos/crm-front/Worklog/2026-08-19]] y [[Proyectos/Desarrollos/crm-back/Worklog/2026-08-19]].

## Relacionado

- [[Proyectos/Desarrollos/crm-back/crm-back]] — proyecto.
- `crm-front` — frontend afectado por la migración.