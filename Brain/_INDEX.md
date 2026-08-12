---
type: index
area: Brain
updated: 2026-08-12
---

# Brain — Índice

> Memoria interna de **auto-mejora del agente**: registro crudo de errores resueltos y aciertos.
> `Brain/Errores/` = problemas con soluciones (busca-able). `Brain/Aciertos/` = qué funcionó
> y por qué conviene repetirlo. Plantillas: [[Brain/Errores/Template Error]] · [[Brain/Aciertos/Template Acierto]].
>
> **Lecciones** ([[Lecciones/_INDEX]]) es aparte: viven ahí las lecciones **curadas y presentables**
> para lectura humana. Un error/acierto de Brain se promueve a `Lecciones/` (copiando pulida y
> enlazando) cuando vale como lección general.

<!-- AUTO: cuerpo regenerado por construir-indices.ps1 (no editar) -->

## Errores

```dataview
TABLE category AS "Categoría", status AS "Estado", length(file.inlinks) AS "Refs", updated
FROM "Brain/Errores"
WHERE !startswith(file.name, "Template")
SORT updated DESC
```

## Aciertos

```dataview
TABLE category AS "Categoría", length(file.inlinks) AS "Refs", updated
FROM "Brain/Aciertos"
WHERE !startswith(file.name, "Template")
SORT updated DESC
```

<!-- /AUTO -->

## Relacionado

- [[OpenBrainCode]] — hub general.
- [[Lecciones/_INDEX]] — lecciones curadas y presentables.