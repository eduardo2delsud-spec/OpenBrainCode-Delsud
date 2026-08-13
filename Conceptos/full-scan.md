---
type: concepto
category: rendimiento
updated: 2026-08-13
tags: [concepto, rendimiento, sql, base-de-datos]
---

# Full-scan

> Operación de base de datos que lee todas las filas de una tabla sin usar índices.

## Qué es

Un full-scan (o full table scan) es cuando el motor de base de datos lee cada fila de una tabla para resolver una consulta, en lugar de usar un índice para saltar directamente a los registros relevantes. Es costoso porque implica I/O y CPU proporcionales al tamaño de la tabla.

## Proyectos que lo usan

- [[Proyectos/Desarrollos/gestion-desarrollos-back]] — se detectó en el endpoint `GET /api/v1/reservations` que hacía 2 full-scans sobre `Bookings`: uno para armar el summary en JS y otro para el COUNT.

## Patrones relacionados

- [[Patrones/Bench A-B con git worktree]] — para medir el impacto de eliminar full-scans.

## Lecciones

- [[Lecciones/Conteo por estado: GROUP BY en vez de fetch-all]] — reemplazar full-scan por GROUP BY.