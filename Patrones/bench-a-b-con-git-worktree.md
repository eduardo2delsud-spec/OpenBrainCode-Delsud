---
type: patron
category: rendimiento
updated: 2026-08-13
tags: [patron, rendimiento, testing, git, worktree]
---

# Bench A-B con git worktree

> Patrón para comparar rendimiento entre la versión actual del código y una versión anterior usando git worktree y dos servidores.

## Qué es

Técnica que permite ejecutar dos versiones del mismo código simultáneamente para comparar rendimiento. Se crea un git worktree con el commit anterior (HEAD) y se levanta un segundo servidor en un puerto diferente. Un harness de bench ejecuta los mismos escenarios contra ambos servidores y compara resultados.

## Proyectos que lo usan

- [[Proyectos/Desarrollos/gestion-desarrollos-back]] — se usó para validar la optimización de Reservations: OLD(4102, git worktree HEAD) vs NEW(4101, working tree).

## Conceptos relacionados

- [[Conceptos/Full-scan]] — el patrón se aplica para medir impacto de eliminar full-scans.

## Lecciones

- [[Lecciones/Bench A-B con seed idempotente y marker]] — el seed debe ser idempotente y usar markers para cleanup.