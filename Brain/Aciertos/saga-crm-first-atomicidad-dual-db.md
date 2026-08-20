<!-- @brain acierto -->
---
type: acierto
category: arquitectura
updated: 2026-08-20
tags: [acierto, arquitectura, saga, crm-first, atomicidad, transacciones, dual-db, gestion-desarrollos-back, mysql]
---

# Saga CRM-first con snapshot/restore para atomicidad entre DB local y CRM

> Estandarizar toda escritura dual (DB local + CRM) con el patrón saga CRM-first: tx CRM con snapshot previo → tx local propia → compensación exhaustiva con `FOR UPDATE` en disponibilidad de lotes. Typecheck + build verdes y sin escrituras locales residuales dentro de tx CRM.

## Qué pasó

La Fase 4 de la auditoría detectó que `cancelContract`, cancelaciones/devoluciones/completaciones de reservas, `editReservation`, `createNewReservation`, `externalSold`, `certifyCancel`, `addDocumentToBooking` y `addAttachment` escribían en la DB local dentro de la tx CRM o sin compensación completa. Se refactorizó todo a **saga CRM-first** con un módulo central `src/core/sagas.ts`:

- `snapshotBookingForCancel` / `restoreBookingSnapshot`: captura y revierte booking (status/`reasonCanceled`/`updatedAt`), lotes (selled/contactId), contacto (`stateId`) e historiales insertados (`histories`/`historybookings`).
- `snapshotLots`/`restoreLotsSnapshot`/`snapshotLotForExternalSale`/`restoreLotSnapshot`: compensación de lotes.
- Helpers tx-aware: `cancelContract(id, { crmTx?, localTx?, skipCrm? })`, `createContract(..., localTx?)`, `createDownpayment(..., { crmTx?, localTx? })`, `addDownpaymentProof(..., localTx?)`, `addMovement(data, tx?)`.
- `FOR UPDATE` + re-check bajo lock en `createNewReservation`, `externalSold` y el cambio de lotes de `editReservation` → se elimina la doble venta.
- `certifyCancel` ahora compensa de forma completa (antes solo statusBooking + selled).

Verificación: `npm run typecheck` ✅, `npm run build:js` ✅, grep sin `db.*` dentro de `crmDb.transaction` en los métodos refactorizados ✅.

## Por qué funcionó

- Separar las dos fases en transacciones **propias** respeta la realidad del driver (mysql2 no coordina dos pools): la atomicidad se logra con **compensación explícita**, no con una tx "que abarque ambos".
- El **snapshot previo dentro de la tx CRM** es la fuente de verdad para revertir: no hay que adivinar qué se tocó.
- `FOR UPDATE` + re-check convierte el check de disponibilidad en atómico entre conexiones concurrentes.
- La **firma `{ crmTx?, localTx? }`** en los helpers permite componer sagas sin anidar transacciones ni duplicar lógica (modo standalone vs modo integrado con `skipCrm`).

## Contexto

- Proyecto: [[Proyectos/Desarrollos/gestion-desarrollos-back]]
- Stack: Node + Express + TypeScript + Drizzle ORM (mysql2 ^3.15.3) — MySQL dual (local + CRM).
- Momento: 2026-08-20, refactor Fase 4 de la auditoría.

## Cómo repetirlo

1. Identificar toda operación que escriba en ambas bases dentro del mismo flujo.
2. Fase CRM: `crmDb.transaction` → snapshot previo → escrituras → retornar `{ snap, eventos, ids insertados }` (cambiar `return await tx(...)` a `const phase = await tx(...)`).
3. Fase local: `db.transaction` propia con los datos de `phase`.
4. Catch: compensar con los helpers de `sagas.ts` (restaurar booking + lotes + contacto + borrar historiales insertados) y re-lanzar.
5. Disponibilidad compartida (lotes): `FOR UPDATE` + re-check dentro de la tx CRM.
6. Helpers reutilizables con `{ crmTx?, localTx? }` para que otros flujos los compongan.
7. Cerrar con `typecheck` + `build` + grep de `db.*` dentro de `crmDb.transaction`.

## Keywords para /buscar

`saga`, `crm-first`, `snapshot`, `restore`, `compensación`, `FOR UPDATE`, `dual-db`, `atomicidad`, `crmDb.transaction`, `localTx`, `skipCrm`, `externalSold`, `certifyCancel`

## De dónde viene

- [[Proyectos/Desarrollos/gestion-desarrollos-back/Worklog/2026-08-20]] — sesión de atomicidad (Fase 4).

## Relacionado

- [[Lecciones/atomicidad-dual-db-saga-crm-first]] — versión curada del patrón.
- [[Brain/Errores/atomicidad-dual-db-local-crm-sin-compensacion]] — el problema resuelto.
- [[Brain/Errores/return-await-tx-impide-fase-local-saga]] — gotcha de implementación.