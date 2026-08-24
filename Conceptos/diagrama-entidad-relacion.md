---
type: concepto
category: modelado
updated: 2026-08-24
tags: [der, base-de-datos, modelado, entidad-relacion]
created: 2026-08-24
---

# Diagrama Entidad-Relación (DER)

> Documento que define todas las entidades, atributos, relaciones y cardinalidades del dominio de [[Proyectos/VIZTA/VIZTA]].

## Qué es

El DER es la representación gráfica y documental del modelo de datos de un sistema. Define:

- **Entidades** (tablas): qué objetos del dominio se persisten
- **Atributos** (columnas): qué propiedades tiene cada entidad
- **Relaciones** (FKs y join tables): cómo se conectan las entidades
- **Cardinalidades**: 1:1, 1:N, M:N

## Cuándo se usa

- **Diseño inicial:** antes de escribir código, para validar que el modelo cubre todos los requisitos
- **Migraciones:** como fuente de verdad para generar los `CREATE TABLE`
- **Comunicación:** para que backend, frontend y negocio hablen el mismo idioma

## DER de VIZTA

El DER completo de VIZTA vive en `C:\Users\eduar\OneDrive\Desktop\DelSud\Vizta\DER VIZTA — Documento Completo.md`.

### Resumen

| Aspecto | Valor |
|---------|-------|
| Total de tablas | 38 |
| Schemas lógicos | 5 (auth, crm, operations, financials, admin) |
| Tablas nuevas (PBL) | 12 |
| Tablas eliminadas | 10 (por consolidación + origin_data) |
| Cobertura PBL | 60/60 historias de usuario |
| Preguntas resueltas | 7/7 (24/08/2026) |

### Schemas

```
auth          → 2 tablas  (users, roles)
crm           → 16 tablas (contacts, lots, developments, quotations, agenda, etc.)
operations    → 11 tablas (bookings, contracts, installments, payments, etc.)
financials    → 3 tablas  (commissions, wallets, wallet_transactions)
admin         → 6 tablas  (ipc_indices, lot_records, notifications, templates, etc.)
```

### Decisiones clave del modelado

| Decisión | Fundamento |
|----------|------------|
| `lots.contact_id` + `contact_publications` coexisten | FK = reserva activa; M:N = historial de interés |
| `origin_data` eliminada | Reemplazada por `contacts.origin` + `contact_publications` |
| `zones` opcional | Útil para CRM, no obligatorio al crear contacto |
| `lot_records` separado de `booking_history` | Dominios diferentes: lote vs reserva |
| `booking_second_buyers` nullable | Opcional en la práctica, PBL no lo menciona |
| Campos vehículo eliminados | PBL no menciona permutas |
| `claims` simplificada | Sin serial_number, UUID como PK |

### Entidades clave del dominio

| Entidad | Propósito |
|---------|-----------|
| `contacts` | Personas interesadas / compradores potenciales |
| `lots` | Terrenos y lotes (individuales o dentro de desarrollos) |
| `developments` | Desarrollos inmobiliarios (agrupaciones de lotes) |
| `quotations` | Cotizaciones financiadas enviadas por el asesor |
| `bookings` | Reservas con pago verificado |
| `contracts` | Condiciones definitivas de financiación (del boleto) |
| `installments` | Cuotas individuales |
| `commissions` | Comisiones del asesor (al boleto firmado) |
| `wallets` | Billetera del asesor |

## Relaciones principales

```
CONTACTS ──M:N── LOTS (lotes de interés, via contact_publications)
CONTACTS ──M:N── USERS (contactos compartidos entre asesores)
CONTACTS ──1:N── QUOTATIONS ──1:N── QUOTATION_INSTALLMENTS
BOOKINGS ──M:N── LOTS (via booking_lots)
BOOKINGS ──1:1── CONTRACTS ──1:N── INSTALLMENTS
BOOKINGS ──1:N── COMMISSIONS ──M:1── WALLETS
LOTS ──M:1── CONTACTS (contact_id: lote reservado actualmente)
```

## Referencias

- [[Proyectos/VIZTA/VIZTA]] — ficha del proyecto
- [[Conceptos/base-de-datos-unificada]] — por qué una sola PostgreSQL
- `C:\Users\eduar\OneDrive\Desktop\DelSud\Vizta\DER VIZTA — Documento Completo.md` — documento completo
