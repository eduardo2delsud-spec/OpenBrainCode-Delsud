<!-- @meta conventions -->
---
type: meta
category: conventions
updated: 2026-08-09
tags: [meta, convenciones, guia]
---

# Conventions — Cómo está organizado el vault

> Reglas sobre **cómo se escriben** las notas, no sobre **qué** se escribe. Las leen humanos y agentes. Si algo vive acá, es normativo: ante la duda, esto manda sobre cualquier cucumber.

---

## 1. Principio rector: Estado vs. Historia

El conocimiento se divide en dos capas:

- **Estado durable** — lo que es *cierto ahora* de algo. Es una nota tipada (`status` claro, `updated` al día). Es lo que hay que leer para "dónde estoy".
- **Historia** — qué pasó y por qué. Vive en los worklogs (append-only) + ADRs de `Decisiones/`.
  **El registro de cada proyecto vive SIEMPRE dentro de su carpeta** `Proyectos/<Nombre>/`:
  `Worklog/` (historial) + `Decisiones/` (ADRs propios).
- **Brain** — memoria de auto-mejora del agente (`Brain/Errores/` y `Brain/Aciertos/`). Registro crudo, busca-able. **Regla de oro:** todo error/acierto se escribe ahí en el mismo gesto; lo que solo queda en la conversación no existe (regla exacta en `_Config/AGENTS.md`).

> **Regla de oro:** el trabajo entra por el worklog (para proyectos, `Proyectos/<Nombre>/Worklog/YYYY-MM-DD.md`)
> y se **promueve a durable** cuando cambia algo que es *cierto*. La nota durable es la fuente de la verdad;
> el worklog es el registro de lo que pasó.

**Si dos notas se contradicen:** gana la que tiene `updated:` más reciente. **Si la nota contradice el código:** manda el código; el agente corrige la nota y lo registra en el worklog.

## 2. Tipos de nota (frontmatter canónico)

Toda nota del grafo **debe** llevar frontmatter YAML con mínimo `type` + `updated`. Campos obligatorios por tipo:

| Tipo | `type:` | Campos requeridos |
|------|---------|-------------------|
| Proyecto | `proyecto` | `project`, `arch`, `dominio`, `updated` |
| Concepto | `concepto` | `category`, `updated` |
| Patrón | `patron` | `category`, `updated` |
| Decisión | `decision` | `status`, `accepted`\|`date`, `updated` |
| Lección | `leccion` | `category`, `updated` |
| Herramienta | `herramienta` | `category`, `updated` |
| Acierto | `acierto` | `category`, `updated` |
| Error (brain) | `error` | `category`, `status`, `updated` |
| Worklog | `worklog` | `project`, `date` |
| Hub/índice/meta | `hub` / `index` / `meta` | `updated` |

**`created`** (opcional pero recomendado) en notas durables para saber cuándo nació la idea.

**`updated`** se actualiza con **cada** cambio significativo. Es el mecanismo de resolución de conflictos.

## 3. Nombres de archivo

- **Conceptos/patrones/lecciones/herramientas:** `kebab-case` en minúsculas (`Conceptos/auth-jwt.md`, `Patrones/api-http.md`). Proyectos `Title Case` en `Proyectos/<Nombre>/` (`Proyectos/Auth JWT.md`).
- **Brain:** `Brain/Errores/<kebab-case>.md` y `Brain/Aciertos/<kebab-case>.md` (memoria cruda de auto-mejora del agente; ver §2 y la regla de oro de auto-registro).
- **Decisiones (ADR):** `ADR-XXX <Título>.md` con número de 3 dígitos secuencial (`ADR-001 Elegir Postgres.md`).
- **Worklogs de proyecto:** `Proyectos/<Nombre>/Worklog/YYYY-MM-DD.md` (ISO), un archivo por proyecto
  por día, **dentro de la carpeta del proyecto**. (El vault mismo usa `Worklog/OpenBrainCode/`.)
- **Carpeta por proyecto (registro siempre dentro):** cada proyecto vive en `Proyectos/<Nombre>/` con su
  ficha `<Nombre>.md` en la raíz de esa carpeta. El agente **SIEMPRE lleva el registro del proyecto dentro
  de su carpeta**: `Worklog/` (historial append-only, se crea con el primer registro) y `Decisiones/`
  (ADRs propios del proyecto); `Notas/` opcional (runbook/setup/endpoints). Conceptos/Patrones/Reglas/
  Decisiones **generales compartidos** se enlazan desde la raíz del vault, no se duplican en la carpeta.
- **Workspaces:** si un proyecto agrupa sub-proyectos (monorepo/workspace real o mismo cliente/ecosistema), se anidan bajo la carpeta del workspace: `Proyectos/<Workspace>/<Proyecto>/<Proyecto>.md` (ej. `Proyectos/<Workspace>/<Proyecto>/<Proyecto>.md`). La ficha del workspace es `Proyectos/<Workspace>/<Workspace>.md` y enlaza a sus sub-proyectos.
- **Auto-mejora (generadas por plugin):** `Meta/Update/<kebab-case>.md` son **propuestas generadas automáticamente** (por `_Config/.opencode/plugins/automas.ts`) cuando un patrón de error se repite. `status: propuesta` — **no se aplican solas**; un humano las revisa y decide. `_Config/.opencode/data/` guarda estado interno generado (`.json`), fuera del grafo: no es contenido durable y no se indexa.
- **Archivos núcleo de proyecto:** prefijo numérico para orden de lectura (`00`, `01`, `02`…) si varias notas.
- **Plantillas:** `Template <Tipo>.md` por carpeta; se **excluyen** de métricas/dashboard (filtro por prefijo `Template`).

## 4. Enlaces

- Usar **`[[wikilink]]` liberales**. Un hecho vive en **un solo lugar**; el resto lo **enlaza**. Enlazar en vez de duplicar es ley.
- **Un enlace a una nota que no existe es un TODO**, no un error. Anuncia idea futura.
- Preferir `[[Conceptos/autenticacion-jwt]]` (con ruta) cuando el nombre pueda ser ambiguo.
- No hay breadcrumb `↑ ...`: se vuelve por "Relacionado" o el hub de la carpeta.

## 5. Tags transversales (+ además del `#tipo` del frontmatter)

`#tags` son para temas transversales y estados, no para reemplazar el `type`:

| Tag | Uso |
|-----|-----|
| `#estado/activo` · `#estado/completado` · `#estado/pausado` · `#estado/legacy` | Estado de un proyecto |
| `#dominio/<libre>` | Temas (fulltext, auth, iot, …) |
| `#stack/<tech>` | Tecnologías transversales |
| `#prioridad_actual/alta` · `#media` · `#baja` | Cosas a decidir/enlazar |

> Regla de mantenimiento: **evitar inflar**. Empezar con pocas carpetas y pocos tags; crecer solo cuando hay dolor real por una categoría que falta.

## 6. Cómo se llena la memoria (inbox → procesado → salida)

1. **Captura rápida** → `_Inbox/` (sin frontmatter algunas, rápido). No organizar al capturar.
2. **Procesar** (rutina, idealmente diario): clasificar en la carpeta correcta con su plantilla, dar `type` + `updated` + `[[enlace]]`.
3. **Herramientas**: al usar una herramienta nueva en un proyecto, crear/actualizar su ficha en `Herramientas/<Nombre>.md` con el conocimiento (comandos, config, alternativas) y enlazar los proyectos/patrones que la usan.
4. **Salida** → `_Outbox/` cuando el conocimiento se *exprime* en algo: post, decisión aplicada, tutorial, resumen lista.

> **La memoria vale por su liga, no su look.** Un 2do cerebro sin salida es un almacén. `_Outbox/` existe para evitar eso.

## 7. Mantenimiento / lint (cada vez que se toca el vault)

1. No dejar notas huérfanas (sin inlinks ni outlinks) más de lo necesario.
2. No duplicar: si un concepto ya existe, **enlazarlo**, no clonarlo.
3. Al terminar de tocar el vault, correr `auditar-grafo.ps1` (0 enlaces rotos, 0 huérfanos, 0 stale; exit code 0 = OK).
4. Al agregar/renombrar/borrar notas, correr `construir-indices.ps1` para refrescar los `_INDEX.md` de cada área (regenera Dataview + lista plana; respeta la prosa curada entre los marcadores `<!-- AUTO -->`). Idempotente: `-DryRun` para ver el diff.
5. Reindexar `knowledge-graph` cuando cambie el grafo.

## 8. Lo que NO hacer

- No editar entradas del graph "a mano rápido" sin `type`/`updated`.
- No crear carpetas top-level nuevas sin registrar acá.
- No guardar secretos/contraseñas/API keys (ni siquiera en `_Inbox`).
- No volcar transcripts o dumps de sesiones; sintetizar.
- No crear notas durables vacías — solo si hay contenido real.