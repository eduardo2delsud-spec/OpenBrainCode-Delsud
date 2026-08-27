---
type: decision
status: aceptada
accepted: 2026-08-26
updated: 2026-08-26
tags: [decision, modelado, permuta, exclusion]
---

# ADR-0013: Eliminación de permuta (no soportado)

## Estado

Aceptada 2026-08-26 por usuario

## Contexto

El modelo original incluía `permuta` como tipo de pago (`boleto-permuta` en document_types) y columnas `permuta_amount` / `permuta_currency` en `certified_tickets`. El usuario indicó que VIZTA **no soporta** operaciones de permuta (canje de inmuebles).

## Opciones consideradas

1. **Mantener permuta** — modelo más completo, pero sin uso real
2. **Eliminar permuta** — simplifica el modelo, reduce complejidad innecesaria

## Decisión

Eliminar completamente permuta del modelo:

- `payment_type` enum = `{contado, financiado}` (sin `boleto-permuta`)
- `document_types`: eliminar `boleto-permuta` (era ID 16, ahora `documento-reclamo` es 16)
- `certified_tickets`: eliminar columnas `permuta_amount` y `permuta_currency`

## Consecuencias

- **Positivas:** modelo más limpio, enum simpler, menos columnas sin uso
- **Negativas:** si en el futuro se necesita permuta, hay que re-agregar
- **Follow-ups:** asegurar que ningún flujos mencione permuta (ya verificado)

## Proyectos que la aplican

- [[Proyectos/VIZTA]]

## Historial de status

| Fecha | Estado |
|-------|--------|
| 2026-08-26 | Aceptada |

## Relacionado

- [[Conceptos/boleto-financiado]]
