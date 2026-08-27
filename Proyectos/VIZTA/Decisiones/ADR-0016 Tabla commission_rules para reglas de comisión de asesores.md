---
type: decision
status: aceptada
accepted: 2026-08-26
updated: 2026-08-26
tags: [decision, comisiones, asesores, reglas]
---

# ADR-0016: Tabla commission_rules para reglas de comisión de asesores

## Estado

Aceptada 2026-08-26 por usuario

## Contexto

Cada venta de un lote genera una comisión para el asesor participante. El porcentaje de comisión es fijo por asesor, pero puede variar en el tiempo (cambios de política) y por tipo de venta (contado/financiado). Se necesitaba una forma de configurar y auditar estas reglas.

## Opciones consideradas

1. **Campo `commission_rate` en `users`** — simple, pero no permite historial ni variación por tipo de pago
2. **Tabla `commission_rules`** — flexible: soporta historial (vigencia), variación por payment_type, y trazabilidad de quién configuró cada regla
3. **Hardcodear en la lógica de aplicación** — sin configuración en DB, imposible de auditar

## Decisión

1. **Tabla `commission_rules`** (uuid PK): `user_id` FK→users, `rate` decimal(5,2), `payment_type` (null=aplica a todos), `valid_from`/`valid_to` para vigencia, `created_by_id` FK→users (superadmin).

2. **FK `commission_rule_id` en `commissions`** — cada comisión registrada referencia la regla que se aplicó (snapshot del `rate` al momento de la venta).

3. **Fórmula de cálculo:** `commissions.amount = lots.price × commission_rules.rate / 100`

## Consecuencias

- **Positivas:** historial de cambios de política, trazabilidad completa, soporte para futuras variaciones (por desarrollo, por tipo de lote)
- **Negativas:** tabla adicional, query más compleja para obtener la regla vigente
- **Follow-ups:** UI de superadmin para gestionar reglas de comisión

## Proyectos que la aplican

- [[Proyectos/VIZTA]]

## Historial de status

| Fecha | Estado |
|-------|--------|
| 2026-08-26 | Aceptada |

## Relacionado

- [[Conceptos/diagrama-entidad-relacion]]
