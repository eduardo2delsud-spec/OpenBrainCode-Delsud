<!-- @brain error -->
---
type: error
category: data
status: resuelto
updated: 2026-08-13
tags: [error, data, gestion-desarrollos, backend, bench, sql]
---

# Cleanup de seed sintético: subquery cruzó de la DB local a una tabla del CRM + huérfanos por `ON DELETE SET NULL`

> El cleanup de datos de bench falló por una subquery que resolvía una tabla del CRM desde la conexión local, y por filas huérfanas que no se borran en cascada.

## Nivel

`data` — gestión de datos de testing/bench y limpieza idempotente.

## Contexto

- Proyecto: [[Proyectos/Desarrollos/gestion-desarrollos-back]]
- Stack: Node + mysql2 + Drizzle (2 DBs: local `gestiondesarrollos_v100_dev` y CRM `crmdesarrollos_99_dev`)
- Script: `scripts/bench/seed-reservations.mjs`

## Síntoma

1. `DELETE FROM clients WHERE contact_id IN (SELECT contactId FROM Bookings WHERE id IN (...))` en la **conexión local** → `ER_BAD_FIELD_ERROR: Unknown column 'contactId'`.
2. Tras borrar los `Bookings` sintéticos quedaron **1200 filas huérfanas** en `HistoryBookings` (`BookingId IS NULL`) y ~8K `clients` locales sin referencia, aunque el script "terminó bien".

## Causa

1. **Cruce de DB en subquery**: el `DELETE` corría sobre `localConn`, pero el subselect nombraba `Bookings` (tabla del **CRM**). MySQL en este entorno resuelve los nombres de tabla case-insensitive a la primer coincidencia → resolvía a la tabla **local** `bookings` (sin columna `contact_id` → error; y si el nombre hubiera coincidido con el local, habría borrado por datos equivocados). El cleanup mezcló las dos conexiones a la vez.
2. **`ON DELETE SET NULL`**: `HistoryBookings.BookingId` está declarado con `{ onDelete: "set null" }` (no cascade). Borrar el `Bookings` padre deja las historias **huérfanas**, no las borra. Igual para clients compartidos: el borrado en cascada no existe en el esquema local.

## Solución / Fix

1. Subqueries siempre sobre la conexión que corresponde: obtener los ids en JS desde `crmConn` y usarlos **como valores** en la conexión local (`DELETE ... WHERE crm_booking_id IN (${ids})`), sin subquery entre DBs.
2. Borrar clients locales solo si dejaron de estar referenciados: `DELETE FROM clients WHERE id IN (${list}) AND id NOT IN (SELECT client_id FROM bookings WHERE client_id IN (${list}))`.
3. Para las huérfanas: borrarlas **por marker** `DELETE FROM HistoryBookings WHERE description LIKE '[BENCH-RESERVATIONS]%'` (el seed ahora escribe ese prefijo en la descripción) ANTES de borrar los bookings.
4. El seed usa **contacts del CRM sin bookings reales** (`id NOT IN (SELECT ContactId FROM Bookings)`), para que los clients locales derivados nunca se compartan con datos reales.

## Regla práctica

- NUNCA referencies una tabla de otra DB dentro de un `DELETE`/`UPDATE` corriendo sobre una conexión dada; traé los ids a JS y pasalos como valores.
- Al diseñar datos de bench, elegí **un marker** por tabla y un **cleanup idempotente por marker**; no confíes en cascades (revisá `onDelete` real del schema).
- Validá el round-trip `seed → cleanup` contando filas antes/después.

## Prevención

- El seed terminó con verificación de baseline: después del cleanup los counts vuelven a 650 bookings CRM / 551 history / 383 local bookings / 317 clients.
- Correr el cleanup del seed como paso final del bench y comprobar que la DB quedó igual a la inicial.

## Keywords para /buscar

`ER_BAD_FIELD_ERROR`, `cross-database subquery`, `ON DELETE SET NULL`, `huérfanos`, `origen`, `seed`, `cleanup`, `HistoryBookings`, `ContactId`, `case-insensitive table`

## De dónde viene

- [[Proyectos/Desarrollos/gestion-desarrollos-back]] — worklog del bench de Reservations (2026-08-13).

## Relacionado

- [[Brain/Aciertos/reservations-groupby-summary-batch-ensurelocal-limit]] — el acierto que motivó el harness.
- [[Lecciones/bench-a-b-con-seed-idempotente-y-marker]] — si se promueve a lección curada.