---
type: leccion
category: practica
updated: 2026-08-20
tags: [leccion, arquitectura, transacciones, saga, dual-db, atomicidad]
---

# Atomicidad entre dos bases de datos con saga CRM-first

> Cuando una operación escribe en **dos bases MySQL independientes** (sin transacción distribuida), la atomicidad no se logra anidando escrituras en una sola transacción de una de las bases: hay que separar en fases con transacción propia cada una y compensar explícitamente con un snapshot previo si la segunda fase falla.

## Qué es

Lección extraída del refactor de `gestion-desarrollos-back` (Fase 4 de la auditoría): el backend mantiene una DB local de gestión y una DB del CRM como segunda fuente. Escribir en la local **dentro** de `crmDb.transaction` no da atomicidad (mysql2 no coordina dos pools): la tx CRM se revierte si falla una escritura local, pero lo local ya quedó persistido, y viceversa. El patrón que sí funciona y quedó estandarizado es la **saga CRM-first**:

1. **Fase CRM** (`crmDb.transaction`): capturar snapshot del estado previo al inicio, aplicar escrituras CRM, y **retornar** todo lo que la fase local necesita (`{ snap, eventos, ids insertados }`). Donde hay un recurso compartido con disponibilidad (lotes), usar `FOR UPDATE` + re-check bajo lock.
2. **Fase local** (`db.transaction` propia): aplicar las escrituras locales con los datos devueltos por la fase CRM.
3. **Compensación**: si la fase local falla, restaurar TODO lo que la fase CRM escribió desde el snapshot (booking status/`reasonCanceled`/`updatedAt`, lotes `selled`/`contactId`, contacto `stateId`, e historiales insertados). La compensación parcial (solo algunas columnas) corrompe el CRM.

Detalles que lo hacen viable:

- Helpers con firma `(data, { crmTx?, localTx? })` permiten componer la saga desde flujos integrados sin anidar transacciones ni duplicar lógica (modo standalone vs modo "solo locales" con `skipCrm`).
- Los helpers que insertan historial deben **retornar el id insertado** para poder borrarlo en la compensación.
- Cambiar `return await tx(...)` por `const phase = await tx(...)` al convertir un método a saga (si no, la fase local queda inalcanzable y sus variables fuera de scope).

## De dónde viene

- [[Proyectos/Desarrollos/gestion-desarrollos-back]] — worklog 2026-08-20 (Fase 4 de la auditoría): `cancelContract`, cancelaciones/devoluciones/completaciones, `editReservation`, `createNewReservation`, `externalSold`, `certifyCancel`, `addDocumentToBooking`, `addAttachment`.
- [[Brain/Errores/atomicidad-dual-db-local-crm-sin-compensacion]] · [[Brain/Aciertos/saga-crm-first-atomicidad-dual-db]].

## Regla

- **NUNCA** `db.*` dentro de `crmDb.transaction` (ni viceversa) sin plan de compensación: dos pools = dos transacciones independientes + saga.
- **SIEMPRE** snapshot previo dentro de la tx CRM y compensación **exhaustiva** (todas las tablas tocadas + historiales insertados) si la fase local falla.
- **SIEMPRE** `FOR UPDATE` + re-check para disponibilidad de un recurso compartido entre conexiones concurrentes (doble venta).
- **SIEMPRE** firma de retorno correcta en helpers (`Promise<number | null>` si devuelven id) y `const phase = await tx(...)` para la fase local.
- Auditoría rápida al cerrar: `grep "db\.(insert|update|delete)"` dentro de bloques `crmDb.transaction`.

## Relacionado

- [[Brain/Errores/return-await-tx-impide-fase-local-saga]] — gotcha de implementación.
- [[Conceptos/saga]] · [[Conceptos/transaccion-distribuida]] — si se formalizan como conceptos.
- [[Patrones/Convencion variables de entorno]] — contexto del mismo servicio.