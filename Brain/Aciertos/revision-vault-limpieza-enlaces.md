---
type: acierto
category: mantenimiento
updated: 2026-08-13
tags: [acierto, mantenimiento, vault, enlaces, validacion]
---

# Revisión del vault: limpieza de enlaces y creación de notas faltantes

> La revisión periódica del vault detecta y corrige enlaces rotos, crea notas faltantes y mantiene la consistencia del grafo.

## Qué pasó

En una revisión rutinaria del vault OpenBrainCode, ejecuté `validar-vault.ps1` y `auditar-grafo.ps1`. Encontré 2 notas en `Brain/` con enlaces rotos que referenciaban conceptos, patrones y lecciones que no existían. Creé las 4 notas faltantes, corregí los wikilinks para usar `kebab-case` (consistente con los nombres de archivo), y refresqué los índices. Al final, la auditoría reportó 0 enlaces rotos, 0 huérfanos y 0 stale.

## Por qué funcionó

- Seguí el flujo de diagnóstico: primero `validar-vault.ps1` para estructura, luego `auditar-grafo.ps1` para enlaces.
- Usé el script de depuración para identificar exactamente qué enlaces estaban rotos.
- Creé las notas faltantes con contenido sustancial (no vacías) y las enlazé correctamente.
- Actualicé los wikilinks para usar `kebab-case` (consistente con las convenciones del vault).
- Refresqué los índices con `construir-indices.ps1`.
- Registré el trabajo en el worklog (append-only) y actualicé `updated` en las notas modificadas.

## Contexto

- Vault: OpenBrainCode (Segundo Cerebro)
- Scripts: `validar-vault.ps1`, `auditar-grafo.ps1`, `construir-indices.ps1`
- Notas creadas: `Conceptos/full-scan.md`, `Patrones/bench-a-b-con-git-worktree.md`, `Lecciones/conteo-por-estado-group-by-en-vez-de-fetch-all.md`, `Lecciones/bench-a-b-con-seed-idempotente-y-marker.md`

## Cómo repetirlo

1. Ejecutá `validar-vault.ps1` para verificar estructura.
2. Ejecutá `auditar-grafo.ps1` para detectar enlaces rotos, huérfanos y stale.
3. Si hay enlaces rotos, identificá qué notas faltan y crealas con contenido sustancial.
4. Corregí los wikilinks para que apunten a los nombres de archivo correctos (kebab-case).
5. Refrescá los índices con `construir-indices.ps1`.
6. Verificá con `auditar-grafo.ps1` que todo esté limpio.
7. Registrá el trabajo en el worklog (append-only) y actualizá `updated` en las notas modificadas.

## Keywords para /buscar

`revisión vault`, `enlaces rotos`, `creación de notas`, `kebab-case`, `validar-vault`, `auditar-grafo`, `construir-indices`, `mantenimiento`

## Relacionado

- [[Meta/Conventions]] — convenciones del vault.
- [[Brain/Errores/cleanup-seed-cross-db-subquery-y-ondelete-set-null]] — error relacionado que motivó la revisión.