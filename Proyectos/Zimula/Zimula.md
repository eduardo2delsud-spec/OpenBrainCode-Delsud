---
type: proyecto
project: Zimula
status: activo
created: 2026-08-12
updated: 2026-08-12
stack: [Node.js]
arch: script
dominio: utilidad
tags: [proyecto, utilidad, cli]
---

# Zimula

> Monitor de actividad del sistema (CLI de humor). No detectado por el indexador automático (sin markers de proyecto); ficha manual.

## Estado actual

- Script Node puro en `C:\Users\edu\Desktop\DelSud\Zimula\zimula.js`. Se ejecuta con `node zimula.js`. Es un toy/animation de "monitoreo" en consola (categorías `NET`, `SYS`, `SEC`), no un servicio real.
- `output.txt` — salida generada por el script.

## Qué hace

- CLI que simula monitorizar la actividad del sistema mostrando acciones de red, sistema y seguridad con progreso animado en la terminal. Útil como base de juguete para animaciones de consola o demos.

## Stack

| Capa | Tecnología | Detalle |
|------|-----------|---------|
| Runtime | Node.js | `readline` + códigos de color ANSI |
| Arch | Script único | `zimula.js` (~428 líneas), sin dependencias |

## Arquitectura

```
Zimula/
├── zimula.js   ← script principal (loop animado por categorías)
└── output.txt  ← salida de ejemplo
```

## Conceptos que usa

## Patrones que sigue

## Decisiones clave

## Lecciones

## Historial (worklog)

- `Proyectos/Zimula/Worklog/2026-08-12.md` — indexación inicial (ficha manual, sin markers de proyecto)

## Dónde buscar más

- `C:\Users\edu\Desktop\DelSud\Zimula\zimula.js` — script fuente