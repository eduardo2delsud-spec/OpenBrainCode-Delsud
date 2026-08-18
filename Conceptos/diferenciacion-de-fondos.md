---
type: concepto
category: contable
created: 2026-08-18
updated: 2026-08-18
tags: [concepto, contable, fondos, comisiones]
---

# Diferenciación de fondos

> Separación contable y operativa entre tres tipos de dinero: el de los propietarios (ventas), el de VIZTA (ingresos propios) y las comisiones de los asesores.

## Qué es

Todo ingreso del sistema se clasifica según a quién pertenece. VIZTA cobra por cuenta y orden: el dinero de los propietarios no se mezcla con ingresos de VIZTA ni con comisiones. La caja debe distinguir movimientos propios vs de terceros para liquidaciones limpias.

## Reglas clave (proyecto VIZTA)

- Tres fuentes: **propietario** (venta del lote), **VIZTA** (gastos de escrituración y comisión), **asesor** (su comisión al boleto).
- "Reclamar ganancia" del asesor es el **retiro de su billetera**; se elimina el término "ganancia" de la caja del asesor (la ganancia de VIZTA es otro concepto).
- La billetera del asesor acumula comisiones y permite retiros (Mercado Pago).
- **Pendiente** (ADR 0007): % de comisión del asesor y el mecanismo (pasarela en el checkout vs pago directo entre asesor y comprador). Si el dinero pasa directo entre asesor y comprador, el sistema no puede interceptar el método de pago: por eso la comisión se integra al checkout de la reserva.
- **Pendiente** (ADR 0009): destino del pago perdedor cuando dos reservas se pagan simultáneamente sobre el mismo lote.

## Usos

- [[Proyectos/VIZTA/VIZTA]] — `Flujos/01 Reserva y boleto.md`, `Flujos/Por Rol/03 Administración.md`, `Flujos/Por Rol/04 Cobranzas.md`