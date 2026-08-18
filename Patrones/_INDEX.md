---
type: index
area: Patrones
updated: 2026-08-18
---

# Patrones — Índice

> Patrones de diseño e integración, tipados. Plantilla: [[Patrones/Template Patrón]].

<!-- AUTO: cuerpo regenerado por construir-indices.ps1 (no editar) -->
## Catálogo (Dataview)

```dataview
TABLE category AS "Categoría", length(file.inlinks) AS "Referencias", updated
FROM "Patrones"
WHERE !startswith(file.name, "Template")
SORT file.name ASC
```

## Registro

- [[Patrones/bench-a-b-con-git-worktree]] — Bench A-B con git worktree  (category: rendimiento · updated: 2026-08-13)
- [[Patrones/Convencion variables de entorno]] — ConvenciÃ³n variables de entorno  (category: arquitectura · updated: 2026-08-18)
<!-- /AUTO -->

## Relacionado

- [[OpenBrainCode]] — hub general.



