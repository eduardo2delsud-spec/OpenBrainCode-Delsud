<!-- @brain error -->
---
type: error
category: data
status: resuelto
updated: 2026-08-26
tags: [error, data, vizta, dbml, corrupcion]
---

# DBML corrupto — todas las tablas truncadas a solo id

> El archivo `vizta-dbdiagram.dbml` se corrompió y quedó con solo 296 líneas, todas las tablas truncadas a la definición de `id`.

## Nivel

data — corrupción de archivo de schema canónico.

## Contexto

- Proyecto: [[Proyectos/VIZTA/VIZTA]]
- Stack: dbdiagram.io DBML
- Archivo: `ViztaDocs/Schema/vizta-dbdiagram.dbml`

## Síntoma

El archivo pasó de ~1100 líneas (46 tablas completas) a 296 líneas. Cada tabla contenía solo:
```
Table <nombre> {
  id uuid [primary key]
}
```

Todas las columnas, indexes, refs, seeds y comentarios fueron eliminados.

## Causa

Probablemente una operación de escritura fallida o truncada (tool `write` con contenido parcial, o error de encoding).

## Solución / Fix

El usuario reseteó el archivo manualmente (mismo método que se usó antes). Se verificó que el archivo restaurado tenía 1121 líneas y 46 tablas completas.

## Regla práctica

- **NUNCA** hacer `write` directo a un archivo `.dbml` de más de 500 líneas sin antes validar el contenido.
- **SIEMPRE** usar `edit` para cambios puntuales en archivos grandes (una tabla a la vez).
- Si se necesita reescribir completo, generar el contenido primero y mostrarlo al usuario para confirmación.

## Prevención

- Usar `edit` para cambios en DBML en lugar de `write`.
- Mantener backup del DBML en git antes de edits grandes.
- Validar que el archivo tiene todas las tablas después de cada edición (`grep -c "Table " file.dbml`).

## Keywords para /buscar

`dbml`, `corrupcion`, `truncado`, `write`, `vizta`, `schema`, `perdida de datos`

## De dónde viene

- [[Proyectos/VIZTA/VIZTA]] — worklog 2026-08-26

## Relacionado

- [[Conceptos/diagrama-entidad-relacion]]
