---
type: index
area: Conceptos
updated: 2026-08-12
---

# Conceptos — Índice

> Conceptos técnicos y del dominio, tipados con su category. Plantilla: [[Conceptos/Template Concepto]].

<!-- AUTO: cuerpo regenerado por construir-indices.ps1 (no editar) -->
## Catálogo (Dataview)

```dataview
TABLE category AS "Categoría", length(file.inlinks) AS "Referencias", updated
FROM "Conceptos"
WHERE !startswith(file.name, "Template")
SORT file.name ASC
```

## Registro

- (vacío — el script no encontró notas)
<!-- /AUTO -->

## Relacionado

- [[OpenBrainCode]] — hub general.

