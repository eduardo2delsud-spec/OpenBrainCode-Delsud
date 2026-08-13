---
type: leccion
category: rendimiento
updated: 2026-08-13
tags: [leccion, rendimiento, sql, group-by]
---

# Conteo por estado: GROUP BY en vez de fetch-all

> Nunca traigas todas las filas para contar en JavaScript; usá GROUP BY en la base de datos.

## Qué es

Cuando necesitás contar registros por estado (por ejemplo, reservas por status), no hagas `SELECT *` y cuentes en JS. En su lugar, usá `GROUP BY` para que la base de datos haga el trabajo.

## De dónde viene

- [[Proyectos/Desarrollos/gestion-desarrollos-back]] — el endpoint `GET /api/v1/reservations` hacía 2 full-scans: uno para armar el summary en JS y otro para el COUNT. Se reemplazó por un solo `GROUP BY bookings.statusBooking`.

## Regla práctica

- **NUNCA** hagas `SELECT` de todas las filas para contar en JS.
- **SIEMPRE** usá `GROUP BY` de la columna a agrupar y derivá el total de la suma cuando no haya filtros extra.
- Si hay filtros, conservá el COUNT sobre las filas filtradas.

## Relacionado

- [[Conceptos/Full-scan]]
- [[Patrones/Bench A-B con git worktree]]