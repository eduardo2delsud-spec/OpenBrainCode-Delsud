<!-- @brain error -->
---
type: error
category: practica
status: resuelto
updated: 2026-08-13
tags: [error, practica, windows, powershell, junction, node]
---

# PowerShell 5.1: `Remove-Item -Recurse` sobre una junction vacía el `node_modules` del repo

> Borrar un directorio que contiene una junction (p. ej. node_modules → repo) con `Remove-Item -Recurse` sigue la junction y borra el contenido del destino, no solo el enlace.

## Nivel

`practica` — peligro de herramientas nativas de Windows al limpiar directorios de trabajo.

## Contexto

- Proyecto: [[Proyectos/Desarrollos/gestion-desarrollos-back]]
- Stack: Windows + PowerShell 5.1 + Node/npm
- Momento: bench A/B con worktree de git (2026-08-13)

## Síntoma

1. Tras `Remove-Item -Recurse -Force` sobre un worktree temporal que contenía `node_modules` como **junction** al `node_modules` del repo, el `node_modules/.bin` del repo quedó **vacío** (0 shims) y npm scripts (`npm run typecheck`) rompieron con `"tsc" no se reconoce...`.
2. Al recrear el worktree y borrarlo de nuevo con el mismo patrón, el `.bin` volvió a vaciarse.
3. Bonus de sorpresa: en la misma limpieza desapareció un directorio `scripts/bench/` del repo (posible daño colateral de la misma operación).

## Causa

Windows PowerShell 5.1 **atraviesa junctions/symlinks** durante la enumeración recursiva de `Remove-Item -Recurse`: no trata el enlace como un solo objeto, desciende y borra el **contenido del target**. Aquí el target de la junction era el `node_modules` del repo → se vaciaron sus binarios/shim.

## Solución / Fix

1. Nunca `Remove-Item -Recurse` sobre un árbol que pueda contener junctions. Para borrar una junction puntualmente: `cmd /c rmdir <path>` (borra solo el enlace).
2. Secuencia segura de limpieza de un worktree de git con junction:
   - `cmd /c rmdir <worktree>\node_modules` (desenlazar)
   - `git worktree remove --force <worktree>`
   - `git worktree prune`
   - recién entonces, si sigue quedando la carpeta con archivos normales, `Remove-Item -Recurse` (ya sin junctions).
3. Reparación del daño: `npm install` vuelve a generar `node_modules/.bin` ("changed N packages").

## Regla práctica

- En Windows, **detectar junctions** antes de borrar recursivo: `Get-Item <dir>\node_modules | Select LinkType` (si es `SymbolicLink`/`Junction`, desenlazar aparte primero).
- Para worktrees de git, siempre `git worktree remove` (git maneja el metadato) y aplicá la precaución si hay junctions adentro.

## Prevención

- El harness de bench (`scripts/bench/bench-reservations.mjs`) documenta en su header la secuencia segura de limpieza.
- Antes de cualquier `Remove-Item -Recurse` en este repo, verificar que el árbol no incluya junctions.
- Verificación posterior: `Get-ChildItem node_modules\.bin | Measure-Object` y `npm run typecheck`.

## Keywords para /buscar

`Remove-Item -Recurse`, `junction`, `symlink`, `node_modules/.bin vacío`, `tsc no se reconoce`, `git worktree`, `PowerShell 5.1`, `LinkType`, `cmd rmdir`

## De dónde viene

- [[Proyectos/Desarrollos/gestion-desarrollos-back]] — limpieza del bench de Reservations (2026-08-13).

## Relacionado

- [[Brain/Aciertos/reservations-groupby-summary-batch-ensurelocal-limit]] — el bench que expuso el peligro.
- [[Brain/Errores/cleanup-seed-cross-db-subquery-y-ondelete-set-null]] — otra lección de limpieza de bench del mismo día.