---
type: decision
status: aceptada
accepted: 2026-08-26
updated: 2026-08-26
tags: [decision, modelado, auditoria, integridad, postgresql]
---

# ADR-0015: Auditoría y correcciones de integridad del DBML

## Estado

Aceptada 2026-08-26 por usuario

## Contexto

Se realizó una auditoría completa del schema DBML de VIZTA (47 tablas) que reveló múltiples inconsistencias de modelado, FKs faltantes, índices incompletos y restricciones de negocio no documentadas.

## Opciones consideradas

1. **Corregir incremental** — arreglar errores puntuales, sin cambiar la estructura
2. **Reescribir desde cero** — aprovechar para replantear el modelo
3. **Auditoría y corrección integral** (elegida) — revisar todo, corregir inconsistencias y documentar reglas de negocio

## Decisión

Se realizó una auditoría completa con correcciones puntuales. Los cambios principales se detallan a continuación.

### 1. Refs inconsistentes (nullable vs obligatoria)
- `bookings.seller_id >?` (nullable) — una reserva puede no tener vendedor
- `contracts.refinanced_from_id >?` (nullable) — solo aplica si es refinanciación
- `downpayments.proof_document_id >?` (nullable) — comprobante se sube después

### 2. FKs nuevas para trazabilidad
- `cash_flows.claim_id` → FK a `claims` (trazabilidad de reclamos)
- `bookings.quotation_id` → FK a `quotations` (trazabilidad cotización→reserva)

### 3. Índices de performance
- `installments(contract_id, expiration_date)` — búsquedas de vencimientos
- `quotations.user_id` — "mis cotizaciones"
- `bookings(user_id, created_at)` — reportes por asesor
- `certified_tickets.contract_id` — trazabilidad
- `ipc_update_log.ipc_index_id` — auditoría IPC
- `wallet_transactions.destination_bank_account_id` — trazabilidad de retiros

### 4. Soft-delete consistente
- Agregado `deleted_at` a 16 tablas que no lo tenían
- Regla: todas las tablas de datos de negocio llevan soft-delete

### 5. Notifications — FKs en lugar de texto libre
- `notifications.lot_number` → `notifications.lot_id` (FK a lots)
- `notifications.development_name` → `notifications.development_id` (FK a developments)

### 6. Redundancias eliminadas
- `lots.owner_type` eliminado (redundante con `sellers.seller_type`)
- `publications.lot_id` unique eliminado (relación uno a muchos)

### 7. Auditoría en tablas de referencia
- `amenities`, `states`, `document_types`: agregados `created_at`/`updated_at`

### 8. Restricción de negocio documentada
- Una publicación activa por lote: `CREATE UNIQUE INDEX idx_one_active_publication_per_lot ON publications (lot_id) WHERE status = 'publicada';`

## Consecuencias

- **Positivas:** schema más limpio, trazabilidad completa, performance mejorada
- **Negativas:** más columnas y refs para mantener
- **Follow-ups:** implementar el índice parcial en la migración SQL inicial

## Proyectos que la aplican

- [[Proyectos/VIZTA]]

## Historial de status

| Fecha | Estado |
|-------|--------|
| 2026-08-26 | Aceptada |

## Relacionado

- [[Conceptos/diagrama-entidad-relacion]]
