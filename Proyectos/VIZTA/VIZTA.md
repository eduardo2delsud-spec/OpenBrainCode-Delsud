---
type: proyecto
project: VIZTA
status: activo
created: 2026-08-18
updated: 2026-08-26
stack: [React, Vite, TypeScript, TanStack Query, Zustand, MUI, Express, Drizzle, Joi, Biome, PostgreSQL, Mercado Pago]
arch: spa-api
dominio: inmobiliario
tags: [proyecto, inmobiliario, crm, pbl, fintech, postgresql]
---

# VIZTA

> Plataforma de gestión comercial para la venta y financiación de terrenos y lotes: CRM de asesor, cotizaciones, reservas con pago verificado, billetera de comisiones, Administración, Cobranzas, Superadmin y portal público futuro. En fase de **definición de producto** (PBL + flujos + ADRs); el código aún no arrancó.

## Estado actual

- **Producto en definición.** Fuente canónica: `ViztaDocs/PBL VIZTA - v0.3 04_08_2026.md` (revisado el 18/08/2026, v0.3.1).
- **Schema canónico:** `ViztaDocs/Schema/vizta-dbdiagram.dbml` — **45 tablas PostgreSQL** (25/08/2026), 5 schemas lógicos. Documentado además en `ViztaDocs/DER VIZTA - Documento Completo.md` + DER simplificado en PNG.
- **Decisión de DB:** una sola PostgreSQL reemplaza ambas MySQL ([[Decisiones/ADR-0010 Consolidacion a PostgreSQL unica|ADR-0010]], aceptada). Schema nuevo desde cero.
- **Flujo del Asesor documentado** (26/08): `ViztaDocs/Flujos/Flujo Asesor.md` v1.1 — 7 etapas mapeadas a las tablas del DBML, con diagramas ER por etapa y secuencia de reserva con pago verificado.
- Prioridad actual: **Fase 1** — corrección y definición de los diseños del CRM del Asesor; próximos flujos: Administración y Cobranzas (misma estructura).
- Se reutilizará el motor de [[Proyectos/Desarrollos/gestion-desarrollos/gestion-desarrollos]] como base de Administración y Cobranzas; el CRM del asesor se construye nuevo.
- **Pendientes críticos de negocio** (registrados en [[Proyectos/VIZTA/Worklog/2026-08-18|worklog 18/08]]): criterio de rotación de consultas, proceso de selección de asesores, % de comisión del asesor y fuentes de fondo, firmantes/re-publicación/pago perdedor/DNI.

> Nota: tras la reorganización del workspace a `ViztaDocs/`, los antiguos "8 flujos operativos" y los ADRs 0001-0009 **ya no están en disco** — solo sobrevive este flujo del asesor y la copia de ADR-0010 en el vault. Ver [[Proyectos/VIZTA/Worklog/2026-08-26|worklog 26/08]].

## Qué hace

VIZTA organiza la actividad comercial de venta y financiación de terrenos/lotes: centraliza contactos y consultas, vincula interesados con publicaciones, genera cotizaciones financiadas (IPC en pesos), confirma reservas con pago verificado por pasarela (Mercado Pago), gestiona comisiones con billetera y retiros, y acompaña el proceso administrativo (boleto firmado y certificado) y de cobranzas (cuotas, mora, punitorios, cancelación anticipada).

## Stack

| Capa | Tecnología | Detalle |
|------|-----------|---------|
| Frontend (planificado) | React + Vite + JavaScript | SPA CRM del asesor + Admin + Cobranzas; TanStack Query + Zustand + MUI |
| Backend (planificado) | Express 5 + TypeScript strict | Drizzle ORM + Joi + Biome; JWT |
| Base de datos | **PostgreSQL** (única) | [[Conceptos/base-de-datos-unificada]] — consolida ambas MySQL; 38 tablas, 5 schemas |
| ORM | Drizzle ORM | dialect `pg`, driver `pg` (node-postgres) |
| Pagos | Mercado Pago / pasarela | Reserva se confirma solo con pago verificado; sin validación manual de Admin |

## Arquitectura

```
Vizta/                          ← workspace del proyecto (C:\Users\eduar\OneDrive\Desktop\DelSud\Vizta)
├── ViztaDocs/                  ← documentación del producto
│   ├── PBL VIZTA - v0.3 04_08_2026.md   ← product backlog (fuente de la verdad)
│   ├── DER VIZTA - Documento Completo.md ← diagrama entidad-relación
│   ├── Schema/vizta-dbdiagram.dbml       ← schema canónico (45 tablas, 25/08)
│   ├── Flujos/Flujo Asesor.md            ← flujo del asesor v1.1 (26/08)
│   └── Plan Rol Asesos VIZTA.md          ← arquitectura + fases del rol asesor
├── crm-back/       ← JS/Sequelize/MySQL → se migra a TS/Drizzle/PostgreSQL
├── crm-front/      ← JS/React/MUI v5 (SPA del asesor)
├── gestion-back/   ← TS/Drizzle/MySQL → se adapta a PostgreSQL
├── gestion-front/  ← JS/React/MUI v7 (SPA de admin/cobranzas)
└── oldDocs/        ← DERs legacy de crm-back y gestion-back (MySQL)
```

## Conceptos que usa

- [[Conceptos/base-de-datos-unificada]] — consolidación de ambas MySQL en una sola PostgreSQL (ADR-0010)
- [[Conceptos/diagrama-entidad-relacion]] — DER completo del modelo de datos (38 tablas, 7 preguntas resueltas)
- [[Conceptos/pago-verificado-por-pasarela]] — la reserva se confirma solo con pago verificado; Admin no valida comprobantes (ADR 0001)
- [[Conceptos/rotacion-equitativa]] — distribución de consultas entre asesores; criterio pendiente (ADR 0004)
- [[Conceptos/ajuste-por-ipc]] — financiaciones en pesos ajustadas por IPC (periodicidad y fuente pendientes)
- [[Conceptos/garante-y-cogarante]] — financiaciones condicionadas; validación de contacto pendiente
- [[Conceptos/boleto-financiado]] — boleto retenido como respaldo con cláusula a favor de VIZTA
- [[Conceptos/diferenciacion-de-fondos]] — dinero del propietario vs ingresos de VIZTA vs comisiones

## Patrones que sigue

- [[Proyectos/Desarrollos/gestion-desarrollos/gestion-desarrollos]] — motor de Administración y Cobranzas a reutilizar (referencia explícita del PBL)

## Decisiones clave

- [[Decisiones/ADR-0010 Consolidacion a PostgreSQL unica|ADR-0010]] — Consolidación a PostgreSQL única (aceptada)
- Pendientes de definición (registrados en worklogs, sin ADR vigente en disco): criterio de rotación de consultas, selección de asesores, % de comisión y fuentes de fondo, firmantes / re-publicación / pago perdedor / DNI

## Lecciones

- (sin lecciones curadas todavía)

## Historial (worklog)

- [[Proyectos/VIZTA/Worklog/2026-08-26]] — Flujo Asesor v1.1 (workspace), reorg a `ViztaDocs/`, curaduría del vault
- [[Proyectos/VIZTA/Worklog/2026-08-24]] — relevo de repos, diseño del DER completo, decisión PostgreSQL única
- [[Proyectos/VIZTA/Worklog/2026-08-18]] — alta del proyecto en el vault; revisión de consistencia de PBL/flujos y creación de ADRs

## Dónde buscar más

- `C:\Users\eduar\OneDrive\Desktop\DelSud\Vizta\ViztaDocs\PBL VIZTA - v0.3 04_08_2026.md` — PBL (fuente canónica)
- `C:\Users\eduar\OneDrive\Desktop\DelSud\Vizta\ViztaDocs\Schema\vizta-dbdiagram.dbml` — schema canónico (45 tablas, DBML)
- `C:\Users\eduar\OneDrive\Desktop\DelSud\Vizta\ViztaDocs\DER VIZTA - Documento Completo.md` — DER completo documentado
- `C:\Users\eduar\OneDrive\Desktop\DelSud\Vizta\ViztaDocs\Flujos\Flujo Asesor.md` — flujo del asesor v1.1
- `C:\Users\eduar\OneDrive\Desktop\DelSud\Vizta\ViztaDocs\Plan Rol Asesos VIZTA.md` — arquitectura y fases del rol asesor
- [[Conceptos/base-de-datos-unificada]] — por qué PostgreSQL única
- [[Conceptos/diagrama-entidad-relacion]] — resumen del DER