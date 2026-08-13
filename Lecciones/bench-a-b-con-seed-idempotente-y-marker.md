---
type: leccion
category: testing
updated: 2026-08-13
tags: [leccion, testing, seed, cleanup, idempotencia]
---

# Bench A-B con seed idempotente y marker

> El seed de datos de bench debe ser idempotente y usar markers para cleanup seguro.

## Qué es

Cuando creás datos sintéticos para benchmarks, el seed debe poder ejecutarse múltiples veces sin duplicar datos, y el cleanup debe poder eliminar solo los datos sintéticos sin tocar datos reales.

## De dónde viene

- [[Proyectos/Desarrollos/gestion-desarrollos-back]] — el cleanup del seed de Reservations falló por subquery que cruzó de DB local a CRM, y por filas huérfanas que no se borran en cascada.

## Regla práctica

- **SIEMPRE** usá un marker (prefijo en descripción o campo dedicado) para identificar datos sintéticos.
- **NUNCA** referencies una tabla de otra DB dentro de un DELETE/UPDATE; traé los ids a JS y pasalos como valores.
- **NUNCA** confíes en cascades; revisá `onDelete` real del schema.
- Validá el round-trip `seed → cleanup` contando filas antes/después.

## Relacionado

- [[Patrones/bench-a-b-con-git-worktree]]
- [[Brain/Errores/cleanup-seed-cross-db-subquery-y-ondelete-set-null]]