---
type: decision
status: aceptada
accepted: 2026-08-26
updated: 2026-08-26
tags: [decision, modelado, postgresql, ids]
---

# ADR-0011: IDs incrementales para roles y document_types

## Estado

Aceptada 2026-08-26 por usuario

## Contexto

En el modelo de VIZTA, la mayoría de las tablas usan `UUID` como PK. Sin embargo, `roles` y `document_types` son tablas de lookup con datos estáticos que se referencian frecuentemente. El usuario indicó que estas tablas deben usar `int` incremental como PK.

## Opciones consideradas

1. **UUID para todo** — consistencia total, pero JOINs más pesados y seeds menos legibles
2. **int para lookup tables** — más liviano, seeds numéricos (1,2,3,4), consistente con patrón de tablas de configuración

## Decisión

`roles` y `document_types` usan `int [primary key]` con seeds `1..4` y `1..21` respectivamente. Todas las demás tablas usan `UUID`.

## Consecuencias

- **Positivas:** JOINs más simples, seeds legibles, rendimiento en tablas de referencia
- **Negativas:** inconsistencia de tipos de PK entre tablas (UUID vs int)
- **Follow-ups:** asegurar que las FK a estas tablas sean `int` (ya aplicado en `users.role_id`, `contacts.id_document_type`, etc.)

## Proyectos que la aplican

- [[Proyectos/VIZTA]]

## Historial de status

| Fecha | Estado |
|-------|--------|
| 2026-08-26 | Aceptada |

## Relacionado

- [[Conceptos/base-de-datos-unificada]]
