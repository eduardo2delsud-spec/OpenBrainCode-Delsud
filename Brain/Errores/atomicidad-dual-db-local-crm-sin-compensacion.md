<!-- @brain error -->
---
type: error
category: data
status: resuelto
updated: 2026-08-20
tags: [error, data, atomicidad, transacciones, dual-db, saga, gestion-desarrollos-back, mysql]
---

# Escrituras duales DB local + CRM sin atomicidad ni compensación (hallazgos Fase 4)

> Operaciones de `gestion-desarrollos-back` escribían en la DB local (`db`) DENTRO de la transacción del CRM (`crmDb.transaction`) o sin plan de compensación: un fallo en una de las dos bases dejaba datos inconsistentes entre ambas.

## Nivel

`data` — integridad de datos entre dos MySQL independientes (local de gestión + CRM).

## Contexto

- Proyecto: [[Proyectos/Desarrollos/gestion-desarrollos-back]]
- Stack: Node + Express + TypeScript + Drizzle ORM (mysql2 ^3.15.3) — dos pools MySQL independientes: `db` (local) y `crmDb` (CRM).
- Versión: 2026-08-20, refactor de atomicidad (Fase 4 de la auditoría).

## Síntoma

Cuatro hallazgos de auditoría:

1. **`db.*` dentro de `crmDb.transaction`** en `cancelContract`/`cancelReservation`/`returnReservation`/`completeReservation`/`extendReservationWithDownpayment`/`editReservation`/`addDocumentToBooking`/`addAttachment`: la tx CRM se revertía si fallaba una escritura local, pero lo ya escrito en local quedaba persistido (la tx local no existía) → reservas canceladas en local sin estarlo en CRM o viceversa.
2. **`createNewReservation` sin lock de lote**: dos requests concurrentes podían reservar el mismo lote (doble venta).
3. **`externalSold`**: marcaba `selled: Vendido` en CRM y después insertaba `externalSales`+`lotRecords` en local **sin transacción**: un fallo local dejaba el lote vendido en CRM sin registro.
4. **Compensación CRM parcial** en cancelaciones (`certifyCancel` y otras): solo restauraba `statusBooking` + `selled`, sin `reasonCanceled`, `contacts.stateId`, historial (`historybookings`/`histories`) ni `updatedAt` → estado CRM corrompido tras compensar.

## Causa

Dos bases MySQL sin transacción distribuida real. El código asumía que meter escrituras de ambas dentro de una sola `crmDb.transaction` daba atomicidad, pero el driver mysql2 no coordina dos conexiones: las escrituras locales (`db.*`) se ejecutan fuera de la tx CRM y quedan commiteadas aunque la tx falle. Faltaba además el patrón de compensación explícita (saga) y locks de fila para la disponibilidad de lotes.

## Solución / Fix

Patrón **saga CRM-first** (decisión del usuario) estandarizado en `src/core/sagas.ts`:

1. **Fase CRM** en `crmDb.transaction`: se captura snapshot previo (`snapshotBookingForCancel`, `snapshotLots`, `snapshotLotForExternalSale`) al inicio; se aplican las escrituras CRM. Se usa **`FOR UPDATE`** donde hay disponibilidad de lote (`createNewReservation`, `externalSold`, cambio de lotes en `editReservation`) con re-check bajo lock.
2. **Fase local** en `db.transaction` propia, FUERA de la tx CRM, usando los datos devueltos por la fase CRM (ids, eventos, snapshots).
3. **Compensación**: si la fase local falla → `restoreBookingSnapshot`/`restoreLotsSnapshot`/`restoreLotSnapshot` revierten TODO lo que escribió la fase CRM (booking status/reason/updatedAt, lotes selled/contactId, contacto stateId, historiales insertados via `deleteHistoriesRows`/`deleteBookingHistoryRows`).
4. **Helpers tx-aware** para reutilización en sagas integradas: `cancelContract(id, { crmTx?, localTx?, description?, userId?, skipCrm? })`, `createContract(..., localTx?)`, `createDownpayment(..., { crmTx?, localTx? })`, `addDownpaymentProof(..., localTx?)`, `addMovement(data, tx?)`.
5. `addHistoryToContact` ahora retorna el id insertado para poder borrarlo en compensación.

Archivos tocados: `src/core/sagas.ts` (nuevo), `history.utils.ts`, `contracts.service.ts`, `downpayments.service.ts`, `reservations.service.ts`, `lots.service.ts`, `certifiedtickets.service.ts`, `contracts.controller.ts`.

## Regla práctica

- **NUNCA** escribir en la DB local (`db.*`) dentro de una `crmDb.transaction` (ni viceversa): el driver no coordina dos pools; no hay atomicidad real. Separar en fase CRM y fase local con transacción propia cada una.
- **SIEMPRE** capturar snapshot del estado CRM previo dentro de la tx CRM y compensar de forma **exhaustiva** (todas las tablas tocadas + historiales insertados) si la fase local falla.
- **SIEMPRE** `FOR UPDATE` + re-check en operaciones que tocan disponibilidad de un recurso compartido entre dos conexiones (lotes).

## Prevención

- Grep de auditoría: buscar `db.(insert|update|delete)` dentro de bloques `crmDb.transaction` tras cada refactor de escritura dual.
- `npm run typecheck` + `npm run build:js` verdes antes de cerrar (los `if (id)` sobre helpers que retornan id exigen firma correcta, no `void`).

## Keywords para /buscar

`atomicidad`, `dual-db`, `saga`, `crm-first`, `crmDb.transaction`, `compensación`, `snapshot`, `FOR UPDATE`, `doble venta`, `hallazgos fase 4`, `db dentro de tx crm`

## De dónde viene

- [[Proyectos/Desarrollos/gestion-desarrollos-back/Worklog/2026-08-20]] — sesión de atomicidad (Fase 4).

## Relacionado

- [[Lecciones/atomicidad-dual-db-saga-crm-first]] — versión curada del patrón.
- [[Brain/Aciertos/saga-crm-first-atomicidad-dual-db]] — por qué funcionó.
- [[Brain/Errores/return-await-tx-impide-fase-local-saga]] — gotcha de implementación del mismo refactor.