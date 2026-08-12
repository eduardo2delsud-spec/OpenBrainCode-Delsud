<!-- @brain error -->
---
type: error
category: <bug|build|config|runtime|deploy|practica|data>
status: resuelto
updated: YYYY-MM-DD
tags: [error, <categoria>, <proyecto>, <tech>]
---

# <Síntoma corto>

> Qué falló, en una línea. Título busca-able: usá el mensaje de error o el síntoma real.

## Nivel

<bug | config | build | runtime | deploy | practica | data> — en qué capa se ve el problema.

## Contexto

- Proyecto: [[Proyectos/<Nombre>/<Nombre>]]
- Stack: ...
- Versión/entorno: ...

## Síntoma

<Mensaje de error real, stack trace o comportamiento observado. Verbatim, sin inventar.>

## Causa

<Por qué ocurría. La raíz, no el error superficial.>

## Solución / Fix

<El arreglo exacto: comandos, archivos tocados, configuración. Reproducible.>

## Regla práctica

<Qué hacer SIEMPRE / NUNCA en el futuro para evitarlo o diagnosticarlo rápido.>

## Prevención

<Cómo evitar que vuelva: test, linter, check, validación, script.>

## Keywords para /buscar

`<término1>`, `<mensaje de error>`, `<stack:tecnología>`, ...

## De dónde viene

- [[Proyectos/<Nombre>/<Nombre>]] — worklog o changelog del fix.

## Relacionado

- [[Lecciones/<Nombre>]] — si además se promovió a lección curada.
- [[Conceptos/<Nombre>]] · [[Patrones/<Nombre>]].