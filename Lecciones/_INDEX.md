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

- [[Lecciones/atomicidad-dual-db-saga-crm-first]] — Atomicidad entre dos bases de datos con saga CRM-first  (category: practica · updated: 2026-08-20)
- [[Lecciones/bench-a-b-con-seed-idempotente-y-marker]] — Bench A-B con seed idempotente y marker  (category: testing · updated: 2026-08-13)
- [[Lecciones/conteo-por-estado-group-by-en-vez-de-fetch-all]] — Conteo por estado: GROUP BY en vez de fetch-all  (category: rendimiento · updated: 2026-08-13)
<!-- /AUTO -->

## Relacionado

- [[OpenBrainCode]] — hub general.



