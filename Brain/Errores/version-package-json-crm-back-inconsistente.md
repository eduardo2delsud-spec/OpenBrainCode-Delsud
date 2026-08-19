<!-- @brain error -->
---
type: error
category: config
status: pendiente
updated: 2026-08-19
tags: [error, version, package.json, changelog, crm-back]
---

# package.json de crm-back dice 2.4.2 pero el CHANGELOG dice 2.4.3

> Hallazgo de auditoría (2026-08-19): la versión del repo está inconsistente entre `package.json` y `CHANGELOG.md`.

## Nivel

`config` — versión del paquete inconsistente.

## Contexto

- Proyecto: [[Proyectos/Desarrollos/crm-back/crm-back]]
- Stack: Node 18 + Express 4 + Sequelize 6
- Archivos: `C:\Users\eduar\OneDrive\Desktop\DelSud\Desarrollos\crm-back\package.json` y `CHANGELOG.md`

## Síntoma

`package.json` declara `"version": "2.4.2"` mientras que el `CHANGELOG.md` abre con "**Versión actual:** 2.4.3". Dos fuentes de verdad distintas para la misma versión.

## Causa

El CHANGELOG se actualizó a 2.4.3 en alguno de los commits de auditoría/documentación (18–19/8: `436d7d9`, `eae02db`, etc.) pero `package.json` no se bumpió en el mismo cambio. La convención del vault ([[Reglas/Comunes/Changelog]]) exige sincronizar ambos.

## Solución / Fix

- Bumpiar `package.json` a `2.4.3` (o el número que corresponda tras el próximo cambio) en el repo, con su entrada de CHANGELOG, en el mismo commit.
- Verificar que `npm`/deploy no dependa de la versión de `package.json` para release.

## Regla práctica

- El bump de versión y la entrada del CHANGELOG van SIEMPRE en el mismo commit que el cambio que los motiva.
- Al auditar un repo: comparar `version` de `package.json` vs. la "Versión actual" del CHANGELOG.

## Prevención

- En el flujo de release: checklist que compare `package.json` ↔ CHANGELOG antes de mergear.
- En auditorías del vault: leer ambos archivos y reportar la diferencia.

## Keywords para /buscar

`version`, `package.json`, `changelog`, `2.4.2`, `2.4.3`, `crm-back`, `inconsistencia de versión`

## De dónde viene

- Auditoría de servicios de Desarrollos del vault (2026-08-19) — [[Worklog/OpenBrainCode/2026-08-19]].

## Relacionado

- [[Proyectos/Desarrollos/crm-back/crm-back]] — ficha del proyecto.