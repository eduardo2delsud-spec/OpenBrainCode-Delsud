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

- [[Conceptos/ajuste-por-ipc]] — Ajuste por IPC  (category: financiacion · updated: 2026-08-18)
- [[Conceptos/boleto-financiado]] — Boleto financiado  (category: legal · updated: 2026-08-18)
- [[Conceptos/diferenciacion-de-fondos]] — DiferenciaciÃ³n de fondos  (category: contable · updated: 2026-08-18)
- [[Conceptos/full-scan]] — Full-scan  (category: rendimiento · updated: 2026-08-13)
- [[Conceptos/garante-y-cogarante]] — Garante y cogarante  (category: financiacion · updated: 2026-08-18)
- [[Conceptos/pago-verificado-por-pasarela]] — Pago verificado por pasarela  (category: pagos · updated: 2026-08-18)
- [[Conceptos/rotacion-equitativa]] — RotaciÃ³n equitativa  (category: asignacion · updated: 2026-08-18)
<!-- /AUTO -->

## Relacionado

- [[OpenBrainCode]] — hub general.




