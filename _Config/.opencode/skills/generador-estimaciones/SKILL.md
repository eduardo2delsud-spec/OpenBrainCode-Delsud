---
name: generador-estimaciones
description: Genera documentos HTML de estimación de esfuerzo de desarrollo por rol. Triggers: "crear estimación", "estimar proyecto", "documento de estimación", "estimar horas", "generar estimación", "estimación backend", "estimación frontend", "estimación QA". Genera docs modulares (backend, frontend, QA, resumen) con la misma estructura HTML profesional, listos para imprimir a PDF.
---

# Generador de Estimaciones

Crea documentos HTML de estimación de esfuerzo de desarrollo, organizados por rol y módulos.
Cada documento es autocontenido (CSS inline), listo para abrir en navegador e imprimir a PDF.

## Paso 0 — Encuesta inicial

Preguntá al usuario:

1. **Nombre del proyecto** (ej: "VIZTA", "SGT")
2. **Stack técnico** (ej: JS + Express + Drizzle + PostgreSQL)
3. **Equipo** — nombre de cada integrante por rol:
   - Backend
   - Frontend
   - QA
   - Diseño (opcional)
4. **Módulos/funcionalidades** a estimar — para cada módulo pedí:
   - Nombre del módulo (ej: "Contactos", "Reservas")
   - Descripción breve de las tareas backend
   - Descripción breve de las tareas frontend
   - Descripción breve de las tareas QA
5. **Documentos a generar** — preguntá cuáles quiere:
   - Backend (para que el dev backend complete las horas)
   - Frontend (para que el dev frontend complete las horas)
   - QA (para que el QA complete las horas)
   - Resumen consolidado (consolida todos los roles)

## Paso 1 — Estructura de cada documento

### Documento por rol (Backend / Frontend / QA)

Cada documento tiene esta estructura:

```
PORTADA
├── Nombre del proyecto
├── Rol específico
├── Stack técnico
└── Equipo

SECCIONES POR FASE/MÓDULO
├── Fase 0 — Infraestructura (si aplica)
├── Fase 1 — Migración/Scaffolding (si aplica)
└── Fase 2 — Módulos funcionales
    ├── Nombre del módulo
    ├── Listado de tareas (con clase según rol)
    └── Tabla de estimación (Tarea × Horas)

RESUMEN
├── Tabla con subtotales por fase/módulo
├── Total general
└── Proyección en semanas (total ÷ 8 h/día ÷ 5 días/semana)
```

### Documento resumen

```
PORTADA
├── Nombre del proyecto
├── Todos los roles
└── Stack

TABLA CONSOLIDADA
├── Columnas: Fase/Módulo | Backend | Frontend | QA
├── Filas: cada fase y módulo
└── Fila TOTAL

RESUMEN BOX
├── Total por rol
├── Proyección en semanas por rol
└── Nota sobre trabajo en paralelo
```

## Paso 2 — Colores por rol

Usá estos colores fijos para mantener consistencia visual:

| Rol | Color primario | BG detalle | BG hover | BG subtotal | BG phase | Border input |
|-----|---------------|-----------|---------|------------|---------|-------------|
| Backend | `#1a5276` | `#f0f4f8` | `#eaf2f8` | `#d4e6f1` | `#eaf2f8` | `#b0c4de` |
| Frontend | `#196f3d` | `#f0faf0` | `#eafaf1` | `#d5f5e3` | `#eafaf1` | `#a9dfbf` |
| QA | `#7d3c98` | `#f5eef8` | `#f5eef8` | `#e8daef` | `#f5eef8` | `#d2b4de` |
| Resumen | `#2c3e50` | `#ebedef` | `#eaf2f8` | `#d5d8dc` | `#ebedef` | `#b0b6be` |

## Paso 3 — Generación

1. Creá el directorio de salida (el usuario indica la ruta, o por defecto `[proyecto]/ViztaDocs/`).
2. Generá cada documento como `estimacion_[rol].html`.
3. El documento resumen va como `estimacion_resumen.html`.
4. Los campos de horas quedan como `___ h` para que cada rol los complete.
5. El resumen consolida las columnas de los documentos individuales.

## Paso 4 — Verificación

Checklist al generar:
- [ ] Portada con proyecto, rol, stack, equipo correctos
- [ ] Cada módulo tiene listado de tareas + tabla de estimación
- [ ] Subtotales por módulo/fase
- [ ] Total general al final
- [ ] Proyección en semanas (total ÷ 8 ÷ 5)
- [ ] CSS inline (autocontenido, sin dependencias externas)
- [ ] Print-friendly (`@page` A4, `page-break`)
- [ ] Sin mencionar modelos de IA específicos

## Notas

- La skill es **modular**: el usuario elige qué documentos generar.
- Los colores son fijos por rol para mantener consistencia visual.
- El CSS está optimizado para A4 y impresión a PDF.
- Los documentos son autocontenidos: se pueden compartir como archivos HTML individuales.
- Cada sección de módulo usa `<div class="task-detail">` para el listado de tareas y `<table>` para la estimación.
