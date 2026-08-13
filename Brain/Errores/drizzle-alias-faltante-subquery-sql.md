<!-- @brain error -->
---
type: error
category: runtime
status: resuelto
updated: 2026-08-12
tags: [error, runtime, drizzle, mysql, backend, gestion-desarrollos-back]
---

# ERROR 1054 "Unknown column 'gs'": Drizzle no emite el alias de un fragmento sql dentro de un subquery envuelto con `.as("t")`

> `/contracts/stats` devolvía HTTP 500 al mover el conteo de `getGlobalStats` a SQL: la query generada referenciaba `gs` pero el subquery no lo nombraba (`Unknown column 'gs'`).

## Nivel

runtime — generación de SQL de Drizzle, no un error de lógica de negocio.

## Contexto

- Proyecto: gestion-desarrollos-back (optimización de Contratos, 2026-08-12)
- Stack: TypeScript + Drizzle ORM (mysql2) + Express
- Entorno: dev local (MySQL 8)

## Síntoma

En el benchmark A/B (`TestPerformance/bench-contracts.mjs`) el escenario `stats` daba **HTTP 500** con `"Error al obtener las estadísticas globales de contratos"`. En el log del server:

```
Failed query: select SUM(CASE WHEN gs = 'Finalizado' THEN 1 ELSE 0 END), ... from (select
    CASE
        WHEN MAX(`contracts`.`status`) = 'Cancelado' THEN 'Cancelado'
        ...
    END
 from `contracts` left join `installments` ... group by `contracts`.`id`) `t`
```

El subquery generaba `CASE ... END` **sin `as gs`**, y el outer referenciaba `gs` → MySQL ERROR 1054. `tsc --noEmit` pasaba perfecto (error solo en runtime).

## Causa

En esta versión de Drizzle, al envolver un query con `.from(statsSub.as("t"))`, los campos definidos como fragmentos `sql<...>` **no reciben su alias** (`as gs`) en el SQL del subquery. El alias sí se emite en selects directos (por eso `getAllContracts` con `status: GLOBAL_STATUS_SQL` funcionaba), pero se pierde al materializar el subquery. Resultado: el SQL generado es sintácticamente inválido sin que TypeScript lo detecte.

## Solución / Fix

Forzar el alias dentro del propio fragmento en lugar de la key del `select`:

```ts
const statsSub = db
    .select({
        gs: sql<string>`(${GLOBAL_STATUS_SQL}) AS gs`,   // alias embebido
    })
    .from(contract)
    .leftJoin(installment, and(eq(installment.contractId, contract.id), isNull(installment.deletedAt)))
    .where(isNull(contract.deletedAt))
    .groupBy(contract.id);

const [statsRow] = await db
    .select({
        finalized: sql<number>`SUM(CASE WHEN gs = 'Finalizado' THEN 1 ELSE 0 END)`,
        cancelled: sql<number>`SUM(CASE WHEN gs = 'Cancelado' THEN 1 ELSE 0 END)`,
        active: sql<number>`SUM(CASE WHEN gs NOT IN ('Finalizado', 'Cancelado') THEN 1 ELSE 0 END)`,
    })
    .from(statsSub.as("t"));
```

La query generada pasa a `... ) AS gs from ... ) t` y ejecuta (verificado 26 contratos → active 26). Otra variante que NO funcionó: referenciar la columna del subquery (`${statsSub.gs}`) dentro del fragmento SQL — se renderiza vacía.

## Regla práctica

- AL envolver un subquery con `.as("t")` y referenciar sus columnas por **nombre** en SQL crudo, verificá que el subquery emita los alias (corré `.toSQL()` antes de asumir). Si falta, embebé `AS <nombre>` dentro del `sql<...>` del campo.
- NUNCA confiar en que `tsc` valide el SQL generado por Drizzle: los errores de alias/columnas aparecen solo en runtime → probar la query (`toSQL()` + ejecución) o correr el benchmark A/B.

## Prevención

- Al refactorizar queries a forma "derived table + agregaciones", imprimir `q.toSQL()` y ejecutar contra la DB dev antes de commitear.
- El benchmark A/B (`bench-contracts.mjs` con escenario `stats`) lo detectó al instante; mantenerlo en el flujo de optimizaciones.

## Keywords para /buscar

`Unknown column`, `ERROR 1054`, `group by`, `SUM(CASE WHEN gs`, `derived table`, `subquery`, `as('t')`, `$dynamic`, `contracts/stats`, `getGlobalStats`

## De dónde viene

- Changelog de gestion-desarrollos-back (2026-08-12) — entrada de optimización de Contratos, sección de getGlobalStats.

## Relacionado

- [[Proyectos/Desarrollos/gestion-desarrollos-back/gestion-desarrollos-back]]
- [[Reglas/Comunes/Changelog]]