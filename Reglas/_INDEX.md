---
type: index
area: Reglas
updated: 2026-08-09
---

# Reglas — Índice

> Reglas operativas del vault (arranques, convenciones, documentación), agrupadas por rol de agente:
> `Backend/` (backend), `Frontend/` (frontend), `Comunes/` (todo proyecto). Cada subagente lee las reglas de su carpeta.

<!-- AUTO: cuerpo regenerado por construir-indices.ps1 (no editar) -->
## Catálogo (Dataview)

```dataview
TABLE category AS "Categoría", length(file.inlinks) AS "Referencias", updated
FROM "Reglas"
WHERE !startswith(file.name, "Template")
SORT file.name ASC
```

## Registro

- (vacío — el script no encontró notas)
<!-- /AUTO -->

## Relacionado

- [[OpenBrainCode]] — hub general.






