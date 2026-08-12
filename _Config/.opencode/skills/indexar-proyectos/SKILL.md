---
name: indexar-proyectos
description: Use when the user wants to index ALL projects and build the knowledge graph. Triggers: "indexar todo", "indexar proyectos", "actualizar catálogo", "re-scrapear", "actualizar registros", "construir cerebro". Scans the projects folder (OPENBRAIN_PROJECTS_ROOT), scrapes each, creates interlinked concept/pattern/lesson notes.
---

# Indexar Proyectos (Brain Mode)

Recorre la carpeta de proyectos, detecta proyectos de software, ejecuta el scrape de cada uno y regenera el knowledge graph completo.

## Ruta del vault y de proyectos

- **Vault**: la raíz de este proyecto (donde vive `OpenBrainCode.md`).
- **Carpeta de proyectos**: se resuelve con la variable de entorno `OPENBRAIN_PROJECTS_ROOT` (o el parámetro `-ProjectsRoot` del script).

## Proceso

### Paso 1: Descubrir proyectos

Ejecutar `dir $OPENBRAIN_PROJECTS_ROOT` y para cada subcarpeta, verificar si es un proyecto de software:

**Es proyecto si tiene:**
- `package.json` (Node.js/TypeScript)
- `requirements.txt` o `pyproject.toml` (Python)
- `Cargo.toml` (Rust)
- `go.mod` (Go)
- `docker-compose.yml`
- `README.md` con contenido descriptivo

**NO es proyecto si:**
- Es `OpenBrainCode` (el vault mismo)
- Es `Proyectos.txt` (archivo suelto)
- No tiene archivos de proyecto conocidos

**Excepciones conocidas** (scrapear solo si se pide):
- `Guias`, `Herramientas`, `Old-Viejos`, y carpetas de utilidades

### Paso 2: Para cada proyecto detectado

Ejecutar el flujo de `scrape-proyecto`:
1. Leer las fuentes del proyecto
2. Identificar conceptos, patrones, decisiones, lecciones
3. Crear/enlazar notas de concepto/patrón/decisión/lección
4. Generar/actualizar la ficha del proyecto con conexiones
5. Mantener al día el hub `OpenBrainCode.md` y el `_Dashboard.md`

### Paso 3: Verificar el hub del grafo

No existe catálogo aparte: las conexiones `[[...]]` entre notas **son** el mapa. Verificar que el hub `OpenBrainCode.md` esté al día con los enlaces a las carpetas del grafo y que el `_Dashboard.md` de Obsidian refleje las notas nuevas.

### Paso 4: Reportar

Informar:
- Proyectos scrapeados: <N>
- Nuevos: <N>
- Actualizados: <N>
- Conceptos creados: <N>
- Patrones creados: <N>
- Lecciones creadas: <N>
- Decisiones creadas: <N>
- Conexiones nuevas: <N>

## Modos de ejecución

### Full index (default)
Scrapea todos los proyectos y regenera el knowledge graph completo.

### Delta index (`delta=true`)
Solo scrapea proyectos cuyas fuentes cambiaron desde la última actualización.

### Single project (`project=<nombre>`)
Scrapea solo un proyecto específico.

## Métricas del cerebro

El sistema tracks:
- **Conexiones por proyecto**: cuántos conceptos/patrones usa cada proyecto
- **Conceptos más usados**: qué conceptos aparecen en más proyectos
- **Patrones más comunes**: qué patrones son más populares
- **Lecciones compartidas**: qué lecciones aplican a múltiples proyectos
- **Proyectos más conectados**: cuáles tienen más conexiones en el grafo

Esto permite preguntas como:
- "¿Qué concepto uso en más proyectos?" → React (5 proyectos)
- "¿Qué proyectos siguen el patrón SPA + API?" → Proyecto A, Proyecto B, Proyecto C
- "¿Qué lecciones aplican a mi proyecto actual?" → buscar lecciones que enlacen a los conceptos del proyecto
