<!-- @brain acierto -->
---
type: acierto
category: rendimiento
updated: 2026-08-18
tags: [acierto, rendimiento, chunk-splitting, manualChunks, vite, pdfmake, lazy-loading]
---

# manualChunks en forma objeto precarga librerías lazy; quitarlas del manualChunks las vuelve lazy real

> Quitar `pdfmake`, `charts` y `reactCharts` de `manualChunks` (forma objeto) en `vite.config.mjs` eliminó su precarga al arrancar: el build pasó de ~1322 kB a ~298 kB gzip de carga inicial (-77%), con `pdfmake`/`vfs_fonts`/`react-apexcharts` descargándose solo bajo demanda.

## Qué pasó

El código ya importaba `pdfmake` con `import()` dinámico, pero `build/index.html` precargaba `pdfmake` (1.83 MB), `charts` (573 kB) y `reactCharts`. El diagnóstico mostró que la **forma objeto de `manualChunks`** generaba imports estáticos del chunk en el grafo del entry (el chunk `react` y casi todos los lazy chunks tenían `import "./pdfmake..."` estático), y Vite emitía `<link rel="modulepreload">`. Se removieron esas entradas de `manualChunks` (quedaron `react`, `mui`, `html2canvas`) y se quitó el import del barrel de 23 modales en `sideNav` (import directo de `ModalExportReportsCobranza`). Resultado: `index.html` precarga solo `index` + `react` + `mui`, y los PDFs/charts cargan on-demand.

## Por qué funcionó

- La forma objeto de `manualChunks` es un footgun conocido de Rollup/Vite: enlaza estáticamente chunks compartidos aunque se importen dinámicamente. Al quitarlos, el splitting natural de Rollup produce chunks lazy compartidos reales.
- Aproximación **empírica incremental** ("mínimo + verificar"): primero se quitó solo `pdfmake`; al ver que `charts`/`reactCharts` seguían precargados se quitaron también (mismo mecanismo). No hizo falta la forma función.
- Verificación con Playwright sobre `vite preview`: los requests de `pdfmake`/`vfs_fonts` estaban ausentes al arrancar y aparecían recién al exportar un PDF (`POST /reports/cobranza/export` → 200). 0 errores de consola.

## Contexto

- Proyecto: [[Proyectos/Desarrollos/gestion-desarrollos]]
- Stack: Vite 5, React, MUI, pdfmake, apexcharts
- Momento/versión: 2026-08-18, rama `dev`

## Cómo repetirlo

1. Ante un chunk grande precargado en `index.html`, revisar `manualChunks` en `vite.config.mjs`: si está en forma objeto y el chunk solo se importa dinámicamente en el código, quitarlo de `manualChunks`.
2. Rebuild y comparar la lista de `<link rel="modulepreload">` de `build/index.html` (esperado: solo los chunks eager reales).
3. Confirmar en runtime con Playwright (`requests --static`) que el chunk no se solicita al arrancar y sí al ejecutar la acción que lo usa.
4. Subir `chunkSizeWarningLimit` solo si el chunk lazy grande es intencional (ej. `vfs_fonts` con fuentes embebidas).

## Keywords para /buscar

`chunk-splitting`, `manualChunks`, `modulepreload`, `lazy`, `pdfmake`, `vite build`, `rendimiento`, `gzip inicial`

## De dónde viene

- [[Proyectos/Desarrollos/gestion-desarrollos]] — worklog 2026-08-18.

## Relacionado

- [[Brain/Aciertos/verificacion-plan-limpieza-contra-codigo]] — verificación contra código antes de limpiar.
