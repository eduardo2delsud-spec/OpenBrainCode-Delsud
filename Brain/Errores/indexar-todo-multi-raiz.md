<!-- @brain error -->
---
type: error
category: bug
status: resuelto
updated: 2026-08-12
tags: [error, bug, opencode, powershell, indexar-todo]
---

# indexar-todo.ps1: Substring out of range con OPENBRAIN_PROJECTS_EXTRA (multi-raíz)

> Con más de una raíz de proyectos, `Get-ProjectNotePath` tiraba `startIndex no puede ser mayor que la longitud de la cadena` y fichas caían a `Proyectos/<Parent>/` incorrecto.

## Nivel

bug — script PowerShell del vault.

## Contexto

- Proyecto: OpenBrainCode (vault)
- Stack: PowerShell 5.1, `_Config/.opencode/scripts/indexar-todo.ps1`
- Entorno: `OPENBRAIN_PROJECTS_ROOT=C:\Users\edu\Desktop\DelSud` + `OPENBRAIN_PROJECTS_EXTRA=C:\Users\edu\Desktop\APIA` (seteadas a nivel User).

## Síntoma

```
Excepción al llamar a "Substring": startIndex no puede ser mayor que la longitud de la cadena
En ...indexar-todo.ps1: 52  →  $relTop = $ProjPath.Substring($r.Length)
```
Fichas de proyectos con path corto (`knowledge-graph`, `Zentinel`) se generaban en `Proyectos\DelSud\<nombre>\` (parent = carpeta contenedora, no ruta top-level).

## Causa

`Get-ProjectNotePath` declaraba `param([string]$Vault, [string]$Root, ...)`. Con 2 raíces, PowerShell coacciona el array `$roots` a un único string unido con espacio (`"...DelSud ...APIA"`, ~53 chars). `Substring(53)` revienta para paths < 53 chars; para paths largos devolvía substrings basura (`e`, `oservice`), haciendo impredecible si la ficha quedaba top-level o anidada.

## Solución / Fix

- `indexar-todo.ps1` línea 49: `[string]$Root` → `[string[]]$Root`, para que el foreach recorra cada raíz real y el parsing sea determinista.
- Borré las fichas mal ubicadas y regeneré todo (`indexar-todo.ps1 -GenerateNotes -RunValidators`): 17 fichas nuevas en rutas correctas (`Proyectos/APIA/*`, `Desarrollos/*`, `Flexy/*`, `knowledge-graph`, `Zentinel`).

## Regla práctica

NUNCA tipar como `[string]` un parámetro que recibe una colección de rutas: si puede venir un array (raíces múltiples), usar `[string[]]`. Antes de correr el indexador con varias raíces, revisar `$env:OPENBRAIN_PROJECTS_EXTRA`.

## Prevención

- Validar con `indexar-todo.ps1 -List` + `auditar-grafo.ps1` (exit 0) tras cada indexado.
- Verificar que ninguna ficha quede en `Proyectos/<Parent>` espurio.

## Keywords para /buscar

`indexar-todo`, `Substring`, `OPENBRAIN_PROJECTS_EXTRA`, `multi-raíz`, `Get-ProjectNotePath`, `startIndex`

## De dónde viene

- Trabajo de setup del vault (2026-08-12), commit de configuración inicial.

## Relacionado

- [[Brain/Errores/sqlite-invocation-array]] — botón hermano en `indexar-sqlite.ps1`