<!-- @brain error -->
---
type: error
category: bug
status: resuelto
updated: 2026-08-12
tags: [error, bug, opencode, powershell, indexar-sqlite, node]
---

# indexar-sqlite.ps1: `& $invocation` falla al pasar array como comando

> El wrapper PowerShell del espejo SQLite no invocaba node: `& $invocation` con un array → "no se reconoce como nombre de cmdlet".

## Nivel

bug — script PowerShell del vault.

## Contexto

- Proyecto: OpenBrainCode (vault)
- Stack: PowerShell 5.1 + Node.js, `_Config/.opencode/scripts/indexar-sqlite.ps1`

## Síntoma

```
& : El término 'C:\Program Files\nodejs\node.exe C:\Users\...\indexar-sqlite.mjs --vault ...' no se reconoce
```

## Causa

`$invocation = @($node, $script, "--vault", $VaultPath)` y luego `& $invocation`. En PowerShell el operador de llamada `&` con un array lo trata como **un solo** argumento de comando (une todo en un string) en vez de splat: `$invocation[0]` como ejecutable y el resto como args. Eso requiere splatting (`@invocation`) separando ejecutable de argumentos.

## Solución / Fix

- `indexar-sqlite.ps1`: quitar `$node` del array y usar `& $node @invocation`:
  ```powershell
  $invocation = @($script, "--vault", $VaultPath)
  if ($Dry) { $invocation += "--dry" }
  & $node @invocation
  ```
- Resultado: `openbraincode.db` generado (57 notas, 111 enlaces).

## Regla práctica

Para ejecutar un binario con argumentos en PowerShell, NUNCA `& $arrayCompleto`: el array se vuelve un único string. Usar `& $exe @args` (splat). El splatting es lo único que separa el ejecutable de los argumentos.

## Prevención

- Prueba manual: `& "_Config/.opencode/scripts/indexar-sqlite.ps1" -Dry` antes de confiar en el espejo.

## Keywords para /buscar

`indexar-sqlite`, `& $invocation`, `splat`, `@invocation`, `node indexar-sqlite.mjs`, `CommandNotFoundException`

## De dónde viene

- Trabajo de setup del vault (2026-08-12).

## Relacionado

- [[Brain/Errores/indexar-todo-multi-raiz]] — botón hermano en `indexar-todo.ps1`