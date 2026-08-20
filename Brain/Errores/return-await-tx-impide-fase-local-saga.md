<!-- @brain error -->
---
type: error
category: practica
status: resuelto
updated: 2026-08-20
tags: [error, practica, refactor, transacciones, saga, typescript, gestion-desarrollos-back]
---

# `return await crmDb.transaction(...)` impide la fase local de la saga (código inalcanzable)

> Al refactorizar un método que terminaba con `return await crmDb.transaction(...)` a saga CRM-first, la fase local (y sus variables) quedaba fuera del flujo: el return corta la función y nada del scope de la tx existe afuera.

## Nivel

`practica` — refactor de código con transacciones.

## Contexto

- Proyecto: [[Proyectos/Desarrollos/gestion-desarrollos-back]]
- Stack: TypeScript + Drizzle ORM (mysql2) — refactor de atomicidad dual-db.
- Versión: 2026-08-20.

## Síntoma

Al agregar la fase local después del cierre de la tx:

```
return await crmDb.transaction(async (tx) => { ... });

try { await db.transaction(...); } catch (err) { ... }
```

- `TS2304: Cannot find name 'removedLotEvents'` (y similares) para todas las variables declaradas dentro del callback de la tx.
- Errores `TS1345: An expression of type 'void' cannot be tested for truthiness` en `if (historyId)` — `addHistoryToContact` estaba tipada `Promise<void>` pero retornaba el id.
- `TS2339: Property 'id' does not exist on type '{}'` con `$returningId()` sobre `historybookings` (PK con nombre propio).

## Causa

1. `return await crmDb.transaction(...)` hace que la función **retorne** el resultado de la tx: todo lo que viene después es código muerto y las variables del callback están fuera de scope.
2. La firma de `addHistoryToContact` decía `Promise<void>` aunque la implementación retornaba `inserted?.id ?? null` → los `if (histId)` fallaban en typecheck.
3. `$returningId()` sobre una tabla cuya primary key tiene nombre explícito (`historybookings_id`) infiere `{}` en lugar de `{ id: number }` → `insertedHistory?.id` daba TS2339.

## Solución / Fix

1. Cambiar el opener a `const phase = await crmDb.transaction(...)`, devolver en el objeto de retorno todo lo que la fase local necesita (snapshot, eventos, ids insertados) y usarlo como `phase.xxx` fuera:
   ```
   const phase = await crmDb.transaction(async (tx) => { ...; return { snap, lotEvents, insertedHistoryIds }; });
   try { await db.transaction(async (ltx) => { ... phase.lotEvents ... }); }
   catch (err) { await restoreBookingSnapshot(phase.snap, now); throw err; }
   ```
2. Corregir la firma: `addHistoryToContact(...): Promise<number | null>`.
3. Cast del id insertado: `(await tx.insert(historybookings).values({...}).$returningId()) as { id: number }[]`.

## Regla práctica

- Al convertir un método `return await tx(...)` en saga de dos fases, el primer cambio es: **`const phase = await tx(...)` + retorno de datos de fase en el objeto**; después se agrega la fase local. Verificar con `tsc --noEmit` antes de continuar.
- Un helper que retorna un valor (ej. id insertado) **debe tiparlo así**; `Promise<void>` oculta el retorno y rompe a los callers que lo usan.
- `$returningId()` puede inferir `{}` según la PK; si TS no ve el id, cast explícito `as { id: number }[]`.

## Prevención

- `npm run typecheck` tras cada paso del refactor (los errores TS2304/TS1345/TS2339 detectan estos problemas exactos).
- Mantener el patrón consistente: fase CRM retorna `{ snap, ... }`; fase local en `db.transaction`; catch solo compensa con `phase.*`.

## Keywords para /buscar

`return await crmDb.transaction`, `fase local inalcanzable`, `TS2304`, `TS1345`, `TS2339`, `$returningId`, `Promise<void> retorna valor`, `refactor saga`

## De dónde viene

- [[Proyectos/Desarrollos/gestion-desarrollos-back/Worklog/2026-08-20]] — refactor de atomicidad (Fase 4).

## Relacionado

- [[Lecciones/atomicidad-dual-db-saga-crm-first]] — patrón curado.
- [[Brain/Errores/atomicidad-dual-db-local-crm-sin-compensacion]] — el problema de fondo que motivó el refactor.