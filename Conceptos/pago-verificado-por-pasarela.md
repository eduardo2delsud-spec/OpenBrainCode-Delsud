---
type: concepto
category: pagos
created: 2026-08-18
updated: 2026-08-18
tags: [concepto, pagos, pasarela, reserva]
---

# Pago verificado por pasarela

> La operación se confirma **únicamente** cuando la pasarela de pagos confirma el ingreso del dinero; nadie valida comprobantes a mano.

## Qué es

Modelo de confirmación de pagos donde la fuente de verdad es la pasarela (Mercado Pago o similar): el cliente paga por transferencia o checkout, y el sistema activa la operación recién cuando recibe la confirmación de la pasarela. Elimina la verificación manual de comprobantes por parte de un rol interno.

## Reglas clave (proyecto VIZTA)

- Reserva: 100% de los pagos por transferencia o checkout; sin permutas.
- Administración **no** revisa ni verifica comprobantes; no crea reservas manualmente (se elimina el botón "Nueva reserva").
- Pagos simultáneos sobre el mismo lote: vale la **primera confirmación recibida**; destino del pago perdedor pendiente (ADR 0009).
- La comisión del asesor se registra al **boleto firmado y certificado**, no al reservar (ADR 0001).

## Usos

- [[Proyectos/VIZTA/VIZTA]] — flujo de reserva (PBL §Reserva, `Flujos/01 Reserva y boleto.md`)