<!-- @brain error -->
---
type: error
category: runtime
status: resuelto
updated: 2026-08-13
tags: [error, runtime, mysql, drizzle, backend, testperformance, gestion-desarrollos-back]
---

# ERROR 1064: `CASE id ELSE amount END` sin cláusula `WHEN` es SQL inválido en MySQL

> Al construir el `UPDATE installments SET amount = CASE id WHEN ... END` con zero `WHEN` dinámicos (todos los montos diofánticos o inmutables), el `SET` quedaba con `CASE id ELSE `amount` END` → MySQL 1064 syntax error.

## Nivel

runtime — generación de SQL en el bulk `UPDATE ... CASE` de `updateIpcContracts`.

## Contexto

- Proyecto: gestion-desarrollos-back (optimización de IPC, 2026-08-13)
- Stack: TypeScript + Drizzle ORM (mysql2) + Express
- Entorno: dev local (MySQL 8), benchmark A/B `TestPerformance/bench-ipc.mjs`

## Síntoma

El escenario `actualizar` del bencch daba **HTTP 500** al correr la nueva versión. En el log del server:

```
Failed query: update `installments` set `amount` = CASE `id` ELSE 1489.7800000000002 END where `installment_id` in ( ... )
```

`tsc --noEmit` pasaba perfecto: el error solo aparece cuando el caso "sin cambios" deja un `CASE` sin `WHEN`s.

## Causa

El armado del `SET` construía `CASE id WHEN ${id1} THEN ${amount1} ...` empalmando solo los ids con datos. En esa corrida las condiciones de difieren a cero/`null` para `CASE` → se generó `CASE id ELSE <valor> END`. En MySQL **`CASE` exige al menos una cláusula `WHEN`** (`CASE ... END` sin `WHEN` no es un `CASE`, solo encadena `ELSE`); `tsc` no lo ve porque es SQL generado en runtime.

## Solución / Fix

No generar el `SET` para los campos sin condiciones: si la lista de `when` está vacía, **omitir el campo del `SET`** (el `UPDATE` solo toca `casesEnabled.length > 0`), de modo que el `CASE` nunca queda sin `WHEN`. Alternativa válida descartada: `CASE id WHEN ${id} THEN ... ELSE ${amount} END` (forzaba los `ELSE` del último id a todos los no-listados → comportamiento incorrecto).

## Regla práctica

- AL construir `CASE ... WHEN ...` dinámico en SQL, SIEMPRE chequear que la lista de `WHEN` no esté vacía antes de emitirlo.
- NUNCA confiar en `tsc` para validar SQL generado; los armados bulk tienen casos extremos (cero whens) que solo aparecen con ciertos datos.

## Prevención

- En el patch que construye `SET` dinámicos, incluir bulk variables bajo el template (si la lista queda vacía, `CASE ... ELSE`).
- El bench correr con los **tres** casos: valores con cambio, valores nulos/0, y corrida donde nada difiere.

## Keywords para /buscar

`ERROR 1064`, `CASE id ELSE`, `syntax error`, `bulk update`, `UPDATE CASE`, `actualizar ipc`, `when vacío`, `SET dinámico`

## De dónde viene

- Changelog de gestion-desarrollos-back (2026-08-13) — entrada de optimización de IPC, write masivo de `updateIpcContracts`.

## Relacionado

- [[Proyectos/Desarrollos/gestion-desarrollos-back/gestion-desarrollos-back]]
- [[Brain/Errores/drizzle-alias-faltante-subquery-sql]] (mismo síndrome: errores de SQL generado solo visibles en runtime)