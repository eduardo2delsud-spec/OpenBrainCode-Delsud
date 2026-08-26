<!-- @brain error -->
---
type: error
category: practica
status: resuelto
updated: 2026-08-26
tags: [error, practica, vault, powershell, encoding, utf8]
---

# Set-Content de PS 5.1 corrompe UTF-8 (acentos → '?')

> Reemplazos masivos con `Get-Content -Raw` + `Set-Content` sin `-Encoding UTF8` re-escriben el archivo en ANSI y los caracteres no-ASCII quedan como `?` irreversibles.

## Nivel

practica — herramienta del agente, no del código del proyecto.

## Contexto

- Proyecto: [[Proyectos/VIZTA/VIZTA]] — curaduría del vault (renombrado kebab-case de patrón con 4 backlinks)
- Stack: Windows PowerShell 5.1, vault Obsidian (UTF-8), git auto-sync
- Entorno: OneDrive, archivos .md con texto español acentuado

## Síntoma

Tras el reemplazo mecánico `[[Patrones/Convencion variables de entorno]]` → nuevo nombre en 4 archivos, `validar-vault.ps1` empezó a reportar errores que antes no existían:

```
[ERROR] Proyectos\Desarrollos\gestion-desarrollos-back\gestion-desarrollos-back.md :: falta seccion '## Qu? hace' (tipo proyecto)
[ERROR] ... :: falta seccion '## D?nde buscar m?s' (tipo proyecto)
```

Inspección: los encabezados en disco tenían literalmente `## Qu? hace` — el carácter acentuado fue sobreescrito por `?`.

## Causa

En PowerShell 5.1, `Set-Content` **sin** `-Encoding` usa ANSI (Default). Además, si el archivo original era UTF-8 *sin BOM*, `Get-Content -Raw` lo lee como ANSI: doble corrupción (lectura + escritura). El contenido ASCII del reemplazo quedó bien; todo lo demás se dañó.

## Solución / Fix

1. Identificar los archivos tocados por el comando masivo.
2. Restaurar desde git (el plugin vault-sync había commiteado): `git checkout <commit_anterior> -- <archivos>`.
3. Re-aplicar el reemplazo con herramientas que respetan UTF-8 (Edit tool) — o, si es PowerShell, con `-Encoding UTF8` explícito en ambos cmdlets.

## Regla práctica

- **NUNCA** usar `Set-Content`/`Add-Content` en el vault sin `-Encoding UTF8`.
- Para reemplazos en notas del vault, preferir la tool de edición del agente o `[System.IO.File]::ReadAllText/WriteAllText($p, $txt, [System.Text.UTF8Encoding]::new($false))`.
- Si un cambio masivo toca archivos con acentos, correr `validar-vault.ps1` inmediatamente después y comparar errores nuevos vs previos.

## Prevención

- El validador (`validar-vault.ps1`) detecta headings corruptos como "falta sección" — correrlo tras cualquier edición masiva.
- Sospechar siempre cuando aparecen errores **nuevos** en archivos que no eran el objetivo del cambio.

## Keywords para /buscar

`Set-Content`, `encoding`, `utf8`, `ansi`, `mojibake`, `Qu? hace`, `validar-vault`, `powershell 5.1`, `backlinks renombrar`

## De dónde viene

- [[Proyectos/VIZTA/Worklog/2026-08-26]] — sesión de curaduría donde ocurrió y se resolvió.

## Relacionado

- [[Patrones/convencion-variables-de-entorno]] — el renombrado que disparó el reemplazo masivo.
