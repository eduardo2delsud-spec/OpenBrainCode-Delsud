<!-- @brain error -->
---
type: error
category: build
status: resuelto
updated: 2026-08-13
tags: [error, build, drizzle, mysql, dev-db, migraciones, gestion-desarrollos-back]
---

# `db:migrate` falla en la DB dev de gestión: no existe la tabla `__drizzle__` (la DB se migra con `db:push`/SQL directo)

> Al correr `npm run db:migrate` para aplicar un índice nuevo, Drizzle intentó re-aplicar todas las migraciones del journal desde cero y falló con `Duplicate column name 'synced_from_archive'` (columna de `0017` ya existente).

## Nivel

build — migraciones Drizzle contra la DB dev.

## Contexto

- Proyecto: gestion-desarrollos-back (optimización de Stock, 2026-08-13)
- Stack: Drizzle ORM + drizzle-kit migrate, MySQL 8
- Entorno: dev local (`gestiondesarrollos_v100_dev`)

## Síntoma

```
DrizzleQueryError: Failed query: ALTER TABLE `bookings` ADD `synced_from_archive` tinyint DEFAULT 0 NOT NULL;
cause: Error: Duplicate column name 'synced_from_archive'
```

El journal tenía la migración de esa columna (`0017_fancy_kitty_pryde.sql`, idx 17) pero la DB ya la tenía. Diagnóstico: `SELECT ... FROM __drizzle__` → **`Table 'gestiondesarrollos_v100_dev.__drizzle__' doesn't exist`**.

## Causa

La DB dev **no fue migrada con `db:migrate`**: nunca se creó la tabla `__drizzle__` que registra qué migraciones del journal ya corrieron. Se construyó/sincronizó con `db:push` (o SQL directo), que aplica el schema sin dejar trackeo. Por eso `db:migrate` intenta re-aplicar TODO el journal (0000..NNNN) en orden y explota en la primera columna que ya existe. No es un problema de mis migraciones: es un estado preexistente del dev.

## Solución / Fix

No usar `db:migrate` en este dev DB. Aplicar los cambios DDL directo contra la DB (o con `db:push`) y crear el archivo de migración + entrada de journal solo como artefacto para otros entornos:

```
CREATE INDEX `installments_expiration_date_idx` ON `installments` (`expiration_date`);
CREATE INDEX `installments_payment_date_idx` ON `installments` (`payment_date`);
CREATE INDEX `cash_flows_transaction_date_idx` ON `cash_flows` (`transaction_date`);
```

(comprobando con `information_schema.STATISTICS` que no existan antes) — mismo patrón que ya usaba `0018_naive_joshua_kane.sql` (el índice `cash_flows_source_date_idx` está en la DB dev pero nunca corrió por `db:migrate`).

## Regla práctica

- ANTES de correr `db:migrate` en un ambiente, verificá que exista `__drizzle__` (`SELECT * FROM __drizzle__;`). Si no existe, ese ambiente se sincroniza con `db:push`/SQL directo → aplicá los DDL directo y no toques `db:migrate`.
- El archivo de migración + entrada de `_journal.json` se mantienen SIEMPRE (son la fuente para entornos que sí usan migrate); no se eliminan aunque acá se apliquen directo.
- MySQL no es transaccional para DDL: un `db:migrate` a medio fallar puede dejar objetos aplicados sin registrar — nunca re-intentar sin inspeccionar el estado.

## Prevención

- Script `_apply-stock-idx.cjs` (TestPerformance) que chequea `information_schema.STATISTICS` antes de crear cada índice: idempotente.
- Mantener el patrón "migración en journal + aplicado directo en dev" cuando el dev no tiene `__drizzle__`.

## Keywords para /buscar

`__drizzle__`, `db:migrate`, `Duplicate column name`, `synced_from_archive`, `db:push`, `0019_stock_indices`, `information_schema.STATISTICS`, `CREATE INDEX`, migraciones dev

## De dónde viene

- Changelog de gestion-desarrollos-back (2026-08-13) — entrada de optimización de Stock (aplicación de `0019_stock_indices`).

## Relacionado

- [[Proyectos/Desarrollos/gestion-desarrollos-back/gestion-desarrollos-back]]
- [[Brain/Errores/ipc-case-sin-when-sql-invalido]] (mismo síndrome: errores de SQL/tooling que solo aparecen en runtime/entorno, no en tsc)