---
type: proyecto
project: VIZTA
status: activo
created: 2026-08-18
updated: 2026-08-18
stack: [React, Vite, TypeScript, TanStack Query, Zustand, MUI, Express, Drizzle, Joi, Biome, MySQL, Mercado Pago]
arch: spa-api
dominio: inmobiliario
tags: [proyecto, inmobiliario, crm, pbl, fintech]
---

# VIZTA

> Plataforma de gestión comercial para la venta y financiación de terrenos y lotes: CRM de asesor, cotizaciones, reservas con pago verificado, billetera de comisiones, Administración, Cobranzas, Superadmin y portal público futuro. En fase de **definición de producto** (PBL + flujos + ADRs); el código aún no arrancó.

## Estado actual

- **Producto en definición.** Fuente canónica: `PBL VIZTA - v0.3 04_08_2026.md` (revisado el 18/08/2026, v0.3.1).
- **Flujos diagramados** en `Flujos/` (8 flujos operativos + flujos por rol: Asesor, Administración, Cobranzas) y **9 ADRs** en `ADRs/` que registran decisiones resueltas y pendientes de la revisión de consistencia.
- Prioridad actual: **Fase 1** — corrección y definición de los diseños del CRM del Asesor (Fases 1-5 del PBL).
- Se reutilizará el motor de [[Proyectos/Desarrollos/gestion-desarrollos/gestion-desarrollos]] como base de Administración y Cobranzas; el CRM del asesor se construye nuevo.
- **Pendientes críticos de negocio** (ADR 0004/0005/0007/0009): criterio de rotación de consultas + zonas, proceso de selección de asesores, % de comisión del asesor y fuentes de fondo, y pendientes operativos (firmantes, re-publicación, pago perdedor, DNI).

## Qué hace

VIZTA organiza la actividad comercial de venta y financiación de terrenos/lotes: centraliza contactos y consultas, vincula interesados con publicaciones, genera cotizaciones financiadas (IPC en pesos), confirma reservas con pago verificado por pasarela (Mercado Pago), gestiona comisiones con billetera y retiros, y acompaña el proceso administrativo (boleto firmado y certificado) y de cobranzas (cuotas, mora, punitorios, cancelación anticipada).

## Stack

| Capa | Tecnología | Detalle |
|------|-----------|---------|
| Frontend (planificado) | React + Vite + TypeScript strict | SPA CRM del asesor + Admin + Cobranzas; TanStack Query + Zustand + MUI |
| Backend (planificado) | Express 5 + TypeScript strict | Drizzle ORM + Joi + Biome; JWT |
| Base de datos | MySQL | Diseño propio; nuevos conceptos: billetera, garantes, checkout |
| Pagos | Mercado Pago / pasarela | Reserva se confirma solo con pago verificado; sin validación manual de Admin |

## Arquitectura

```
Vizta/                      ← workspace del proyecto (C:\Users\edu\Desktop\DelSud\Vizta)
├── PBL VIZTA - v0.3 04_08_2026.md   ← product backlog (fuente de la verdad)
├── Flujos/                ← 8 flujos operativos + flujos por rol (md + canvas)
├── ADRs/                  ← 9 ADRs (decisiones y pendientes)
└── Comparacion VIZTA vs Desarrollos.md ← base de reutilización sobre Desarrollos
```

## Conceptos que usa

- [[Conceptos/pago-verificado-por-pasarela]] — la reserva se confirma solo con pago verificado; Admin no valida comprobantes (ADR 0001)
- [[Conceptos/rotacion-equitativa]] — distribución de consultas entre asesores; criterio pendiente (ADR 0004)
- [[Conceptos/ajuste-por-ipc]] — financiaciones en pesos ajustadas por IPC (periodicidad y fuente pendientes)
- [[Conceptos/garante-y-cogarante]] — financiaciones condicionadas; validación de contacto pendiente
- [[Conceptos/boleto-financiado]] — boleto retenido como respaldo con cláusula a favor de VIZTA
- [[Conceptos/diferenciacion-de-fondos]] — dinero del propietario vs ingresos de VIZTA vs comisiones

## Patrones que sigue

- [[Proyectos/Desarrollos/gestion-desarrollos/gestion-desarrollos]] — motor de Administración y Cobranzas a reutilizar (referencia explícita del PBL)

## Decisiones clave

- ADR 0001 — Pago verificado y comisión al boleto (aceptado)
- ADR 0003 — Generación de reserva pre/post pago (aceptado)
- ADR 0008 — Notificaciones de firma en alcance (aceptado)
- ADR 0004/0005/0007/0009 — pendientes de definición (ver `ADRs/README.md` del workspace)

## Lecciones

- (sin lecciones curadas todavía)

## Historial (worklog)

- `Proyectos/VIZTA/Worklog/2026-08-18.md` — alta del proyecto en el vault; revisión de consistencia de PBL/flujos y creación de ADRs

## Dónde buscar más

- `C:\Users\edu\Desktop\DelSud\Vizta\PBL VIZTA - v0.3 04_08_2026.md` — PBL (fuente canónica)
- `C:\Users\edu\Desktop\DelSud\Vizta\Flujos\00 Indice.md` — índice de flujos
- `C:\Users\edu\Desktop\DelSud\Vizta\ADRs\README.md` — índice de ADRs
- `C:\Users\edu\Desktop\DelSud\Vizta\Comparacion VIZTA vs Desarrollos.md` — comparación con Desarrollos