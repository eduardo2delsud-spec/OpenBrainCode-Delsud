<!-- @brain acierto -->
---
type: acierto
category: rendimiento
updated: 2026-08-13
tags: [acierto, rendimiento, gestion-desarrollos, backend, sql, bench]
---

# Optimización Reservations: GROUP BY del summary + batch en ensureLocal + LIMIT al historial

> El listado de reservas dejó de traer TODAS las filas para contar y el historial del boleto temporal dejó de transferirse completo.

## Qué pasó

En `gestion-desarrollos-back` el endpoint más polled (`GET /api/v1/reservations`) hacía, por request, **2 full-scans** sobre `Bookings`: primero `SELECT id, statusBooking` de **todas** las filas para armar el `summary` en JS, y después un `COUNT(*)` separado. Además `ensureLocalBookingsForCrm` corría un loop de **3 queries por fila** (upsert client + select + upsert booking) en cada request del listado, casi todas no-op en estado estable. Y `getTemporalVoucher` traía el historial completo sin `LIMIT`.

Cambios:
1. Summary con **un solo `GROUP BY bookings.statusBooking`** (mismos buckets por `includes()`); sin filtro `status` el `total` se deriva de la suma de los grupos (semántica idéntica, se elimina el COUNT). Solo con filtro `status` se conserva el COUNT sobre `finalConditions` (`reservations.service.ts:279`).
2. `ensureLocalBookingsForCrm` en **batch**: selects `IN` de clients/bookings existentes + inserts batch `onDuplicateKeyUpdate` de los faltantes (~4 queries fijas vs 3N) (`reservations.service.ts:90`).
3. Historial del boleto temporal con **`LIMIT 50`** (`reservations.service.ts:2947`).

Medido con bench A/B (harness en `scripts/bench/`): 6 escenarios EQ OK, listado **1.31–1.55x** (23–36% más rápido), temporal **1.14x**.

## Por qué funcionó

- Un agregado `GROUP BY` (8.5K filas) reemplaza un transfer completo a Node + un COUNT que volvía a barrer la misma tabla.
- Eliminar escrituras/lecturas no-op **por fila** en cada poll del front (el estado estable es el caso dominante).
- El harness A/B con dos servers (git worktree en HEAD = "old" vs working tree = "new") sobre el mismo dataset es el método honesto para probar equivalencia + timing.

## Contexto

- Proyecto: [[Proyectos/Desarrollos/gestion-desarrollos-back]]
- Stack: Node + Express + TypeScript + Drizzle (mysql2) — CRM BizDev y DB local
- Momento: 2026-08-13, branch `optimizacion-update`

## Cómo repetirlo

- **Patrón conteo**: nunca `SELECT` de todas las filas para contar en JS; usá `GROUP BY` de la columna a agrupar y derivá el total de la suma cuando no hay filtros extra.
- **Patrón repair por página**: batch `IN` + `onDuplicateKeyUpdate` reemplaza loops de upsert por fila.
- **Historiales**: toda query de historial lleva `LIMIT` + `ORDER BY`.
- **Harness A/B**: `seed-reservations.mjs` → `bench-reservations.mjs` levanta NEW(4101) y OLD(4102, git worktree `HEAD`) y compara digests.

## Keywords para /buscar

`GROUP BY`, `summary`, `COUNT duplicado`, `full-scan`, `ensureLocalBookingsForCrm`, `temporal-voucher`, `LIMIT`, `api-old`, `git worktree`, `bench reservas`

## De dónde viene

- [[Proyectos/Desarrollos/gestion-desarrollos-back]] — optimización Reservations (matriz #1 y #5) + bonus ensureLocal.

## Relacionado

- [[Conceptos/full-scan]] · [[Patrones/bench-a-b-con-git-worktree]]
- [[Lecciones/conteo-por-estado-group-by-en-vez-de-fetch-all]]