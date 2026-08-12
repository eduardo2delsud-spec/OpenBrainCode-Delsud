---
type: index
area: Lecciones
updated: 2026-08-12
---

# Lecciones — Índice

> Lecciones aprendidas y reglas derivadas de la práctica. Plantilla: [[Lecciones/Template Lección]].

<!-- AUTO: cuerpo regenerado por construir-indices.ps1 (no editar) -->
## Catálogo (Dataview)

```dataview
TABLE category AS "Categoría", length(file.inlinks) AS "Referencias", updated
FROM "Lecciones"
WHERE !startswith(file.name, "Template")
SORT file.name ASC
```

## Registro

- (vacío — el script no encontró notas)
<!-- /AUTO -->

## Relacionado

- [[OpenBrainCode]] — hub general.
