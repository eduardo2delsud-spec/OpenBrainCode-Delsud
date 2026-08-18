---
type: index
area: Proyectos
updated: 2026-08-12
---

# Proyectos — Índice

> Catálogo de proyectos de software registrados en el grafo. Ficha canónica: [[Proyectos/Template Proyecto]]. Índice mantenido por `construir-indices.ps1` no cubre esta área (se genera con el indexador + curaduría); actualizado a mano.

## Catálogo (Dataview)

```dataview
TABLE project AS "Proyecto", status, stack, updated AS "Actualizado"
FROM "Proyectos"
WHERE !startswith(file.name, "Template") AND !file.folder = "Proyectos"
SORT project ASC
```

## Registro

### APIA

- [[Proyectos/APIA/apia-social-ads-microservice/apia-social-ads-microservice]]
- [[Proyectos/APIA/apia-social-back/apia-social-back]]
- [[Proyectos/APIA/apia-social-chat-and-notification-microservice/apia-social-chat-and-notification-microservice]]
- [[Proyectos/APIA/apia-social-dashboard/apia-social-dashboard]]
- [[Proyectos/APIA/apia-social-front/apia-social-front]]

### Desarrollos

- [[Proyectos/Desarrollos/crm-back/crm-back]]
- [[Proyectos/Desarrollos/crm-front/crm-front]]
- [[Proyectos/Desarrollos/gestion-desarrollos/gestion-desarrollos]]
- [[Proyectos/Desarrollos/gestion-desarrollos-back/gestion-desarrollos-back]]
- [[Proyectos/Desarrollos/TestPerformance/TestPerformance]]

### Flexy

- [[Proyectos/Flexy/flexy-back/flexy-back]]
- [[Proyectos/Flexy/flexy-back-2026/flexy-back-2026]]
- [[Proyectos/Flexy/flexy-back-notification-2026/flexy-back-notification-2026]]
- [[Proyectos/Flexy/flexy-panel-2026/flexy-panel-2026]]
- [[Proyectos/Flexy/flexy-web-2026/flexy-web-2026]]

### Cero/raíz

- [[Proyectos/knowledge-graph/knowledge-graph]]
- [[Proyectos/Zentinel/Zentinel]]
- [[Proyectos/Zimula/Zimula]]

### VIZTA

- [[Proyectos/VIZTA/VIZTA]] — plataforma comercial de terrenos y lotes (PBL + flujos + ADRs; en definición)

## Relacionado

- [[OpenBrainCode]] — hub general.
- [[_Dashboard]] — panel con métricas del grafo.