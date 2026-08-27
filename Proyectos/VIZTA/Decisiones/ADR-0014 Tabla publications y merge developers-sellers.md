---
type: decision
status: aceptada
accepted: 2026-08-26
updated: 2026-08-26
tags: [decision, modelado, publicaciones, vendedores]
---

# ADR-0014: Tabla publications y merge developers→sellers

## Estado

Aceptada 2026-08-26 por usuario

## Contexto

VIZTA tiene un portal público donde los propietarios/vendedores publican terrenos (estilo ZonaProp). El modelo original no tenía tabla `publications` separada de `lots`, y la tabla `developers` era redundante con `sellers`.

## Opciones consideradas

1. **Mantener developers separado** — más datos, pero tablas adicionales sin uso claro
2. **Merge developers→sellers** — simplifica, un vendedor puede ser desarrollador o propietario
3. **Sin publications** — publicar sería solo un flag en lots, sin modelo de vidriera

## Decisión

1. **Tabla `publications`** (uuid PK): `lot_id` FK, `code` unique. Representa una publicación en el portal (vidriera comercial). Un lote puede tener múltiples publicaciones.

2. **Merge `developers` → `sellers`**: `sellers` ahora tiene `name`, `contact_name`, `assigned_user_id`. `lots.owner_id` FK a `sellers.id`. Se eliminó la tabla `developers`.

## Consecuencias

- **Positivas:** modelo más simple, publicaciones flexibles (un lote se puede re-publicar), vendedor unificado
- **Negativas:** pérdida de datos específicos de desarrollador (si existían)
- **Follow-ups:** UI del portal debe mostrar publicaciones, no lotes directamente

## Proyectos que la aplican

- [[Proyectos/VIZTA]]

## Historial de status

| Fecha | Estado |
|-------|--------|
| 2026-08-26 | Aceptada |

## Relacionado

- [[Conceptos/diagrama-entidad-relacion]]
