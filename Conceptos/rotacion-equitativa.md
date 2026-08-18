---
type: concepto
category: asignacion
created: 2026-08-18
updated: 2026-08-18
tags: [concepto, asignacion, crm, asesores]
---

# Rotación equitativa

> Distribución de consultas entrantes entre asesores en ciclo (A → B → C → A…), para que a todos les toque la misma cantidad en lugar de asignar a mano, por zona o por desempeño.

## Qué es

Estrategia de asignación inicial de consultas (leads) donde cada consulta nueva se asigna al siguiente asesor del ciclo. Es la alternativa base antes de criterios más complejos (desempeño, capacitación, zona, seniority).

## Reglas clave (proyecto VIZTA)

- Asignación inicial acordada: **rotación equitativa** (Historia 62; la asignación por desempeño/capacitación es futura).
- **Criterio pendiente** (ADR 0004): ¿equipo completo, por zona, por publicaciones? La "zona" del asesor (Historia 13) no tiene modelo definido.
- Tensión: las desarrolladoras tienen **asesor asignado** (sus consultas no rotarían) y el PBL eliminó la segmentación geográfica en varias vistas.
- El **alta manual** de un contacto no entra a rotación: el asesor que carga el contacto es su dueño.

## Usos

- [[Proyectos/VIZTA/VIZTA]] — CRM del asesor (`Flujos/02 Contactos y consultas.md`)