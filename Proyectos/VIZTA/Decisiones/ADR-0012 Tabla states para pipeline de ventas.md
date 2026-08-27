---
type: decision
status: aceptada
accepted: 2026-08-26
updated: 2026-08-26
tags: [decision, modelado, crm, pipeline, estados]
---

# ADR-0012: Tabla states para pipeline de ventas

## Estado

Aceptada 2026-08-26 por usuario

## Contexto

El CRM de VIZTA necesita rastrear la posición de cada contacto en el pipeline de ventas (oportunidades). Sin una tabla `states`, el estado se almacenaba como varchar en `contacts` y `contact_history`, lo que generaba inconsistencias y dificultaba la filtering/reporting.

## Opciones consideradas

1. **Enum en contacts** — simples pero no extensible, sin descripción
2. **Tabla states con int PK** — referenciable, extensible, con descripción para UI

## Decisión

Crear tabla `states` con `int [primary key]` y 7 estados predefinidos:

| ID | Estado | Descripción |
|----|--------|-------------|
| 1 | Sin contactar | Contacto inicial, sin interacción |
| 2 | Asesoramiento telefónico | Se contactó vía telefónica |
| 3 | Asesoramiento presencial | Tuvo reunión presencial |
| 4 | Alta / Cliente | Cliente activo |
| 5 | Baja | Cliente dado de baja |
| 6 | Reservado | Tiene una reserva activa |
| 7 | Reservas caídas | Tuvo reservas que cayeron |

`contacts.state_id` FK a `states.id`. `contact_history` usa `old_state_id` / `new_state_id` (FK a `states`).

## Consecuencias

- **Positivas:** pipeline visualizable, estados consistentes, fácil extender con nuevos estados
- **Negativas:** tabla adicional (pero es lookup liviana)
- **Follow-ups:** UI debe mostrar selector de estados, filtros por estado en contactos

## Proyectos que la aplican

- [[Proyectos/VIZTA]]

## Historial de status

| Fecha | Estado |
|-------|--------|
| 2026-08-26 | Aceptada |

## Relacionado

- [[Conceptos/diagrama-entidad-relacion]]
