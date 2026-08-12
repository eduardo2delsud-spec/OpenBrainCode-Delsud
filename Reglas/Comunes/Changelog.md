<!-- @regla changelog -->
---
type: regla
category: documentacion
area: changelog
updated: 2026-08-06
tags: [regla, changelog, documentacion]
---

# Changelog — Regla de todo proyecto

> Regla **general** de cómo se registra el historial de cambios en **cualquier** proyecto de software
> del portafolio (y en este vault). Toda entrada de changelog debe cumplir ESTE formato. Se documenta
> de forma obligatoria según [[Reglas/Comunes/Documentacion]].

## Guía de uso

Para mantener el historial ordenado, utilizaremos las siguientes categorías en cada versión:

- **Added (Nuevo)**: Para nuevas funcionalidades.
- **Changed (Cambio)**: Para cambios en funcionalidades existentes.
- **Fixed (Corrección)**: Para corrección de errores (bugs).
- **Removed (Eliminado)**: Para funcionalidades eliminadas.
- **Maintenance (Mantenimiento)**: Tareas de infraestructura, refactorización y limpieza.

## Formato EXIGENTE de cada entrada

Cada cambio debe seguir ESTRICTAMENTE esta estructura:

```
- **{Categoría}**: {Título descriptivo del cambio}. {Descripción completa: QUÉ se hizo, POR QUÉ (opcional si es obvio), CÓMO se implementó. Mencionar nombres de archivos, funciones, endpoints, tablas, schemas, etc.} [{YYYY-MM-DD}]
  * **Files (Archivos)**: {lista de rutas de archivos modificados, con detalles de líneas si es relevante}. [{YYYY-MM-DD}]
```

### Reglas

1. La descripción debe ser **AUTO-CONTENIDA**: quien lea el changelog debe entender el cambio sin tener que abrir el código.
2. Si el cambio es complejo o tiene contexto importante, usar el formato expandido con subtabla explicativa:
   ```
   - **{Categoría}**: {Título}. {Resumen}. [{YYYY-MM-DD}]
     * **Problema**: {Qué fallaba o qué motivó el cambio}.
     * **Solución**: {Cómo se resolvió}.
     * **Files (Archivos)**: {rutas de archivos}. [{YYYY-MM-DD}]
   ```
3. La categoría va en **NEGRITA**, seguida de dos puntos y espacio, luego el título en **NEGRITA**.
4. La fecha `[{YYYY-MM-DD}]` va al **FINAL** de la línea de descripción principal (o al final de la última línea del bloque expandido).
5. La sección `Files (Archivos)`: opcional pero **RECOMENDADA** para cambios que tocan múltiples archivos.
6. La entrada se ordena cronológicamente inverso (más reciente primero) dentro de `## Unreleased`.
7. **NO usar emojis.** NO usar viñetas anidadas que no sean `*` para subtablas.
8. Si el cambio afecta frontend **y** backend, se documenta en AMBOS changelogs con el mismo título y categoría, pero con enfoque en los archivos de cada lado.

## Unreleased

Sección estándar que va al tope del CHANGELOG para registrar cambios aún sin versión etiquetada.
Cada versión publicada genera su propio bloque (`## [X.Y.Z] - YYYY-MM-DD`). Aplicar semver según
[[Reglas/Comunes/Documentacion]].