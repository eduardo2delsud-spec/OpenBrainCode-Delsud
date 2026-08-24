---
type: index
area: VIZTA
updated: 2026-08-24
---

# VIZTA — Decisiones (ADR)

> Los ADRs del proyecto viven en el workspace del proyecto: `C:\Users\eduar\OneDrive\Desktop\DelSud\Vizta\ADRs\` (fuente de la verdad). Este índice los referencia para el grafo sin duplicar contenido. Los ADRs del vault están en `Proyectos/VIZTA/Decisiones/`.

## Aceptados

- **ADR 0001 — Pago verificado y comisión al boleto**: reserva solo con pago verificado por pasarela; sin validación manual de Admin; comisión del asesor al boleto firmado.
- **ADR 0002 — Terminología contacto / comprador / cliente**: estandarización de términos entre flujos y PBL.
- **ADR 0003 — Generación de reserva pre/post pago**: el asesor crea → pendiente → activa al confirmar el pago → pasa a Administración.
- **ADR 0006 — Carga de lotes por rol**: hoy Administración (reutilizando Desarrollos); carga autónoma en el portal público (Fase 6).
- **ADR 0008 — Notificaciones de firma en alcance**: promovida a historia imprescindible.
- **ADR 0010 — Consolidación a PostgreSQL única**: una sola DB reemplaza ambas MySQL; schema nuevo desde cero ([[Decisiones/ADR-0010 Consolidacion a PostgreSQL unica]]).

## Pendientes

- **ADR 0004 — Distribución de consultas y zonas**: criterio de rotación equitativa y modelo de "zona" sin definir.
- **ADR 0005 — Proceso de selección de asesores**: acceso al CRM sujeto a un proceso no descrito.
- **ADR 0007 — Comisión del asesor y fuentes de fondo**: % de comisión y mecanismo de cobro/pago pendientes.
- **ADR 0009 — Pendientes operativos**: Firmante 1/2, destino de la publicación tras reserva inactiva, pago perdedor, DNI.

## Enlaces

- Ficha del proyecto: [[Proyectos/VIZTA/VIZTA]]
- Worklog: [[Proyectos/VIZTA/Worklog/2026-08-24]]
- Conceptos: [[Conceptos/base-de-datos-unificada]], [[Conceptos/diagrama-entidad-relacion]]