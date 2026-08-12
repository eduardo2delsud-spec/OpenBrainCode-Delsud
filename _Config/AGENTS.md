# Segundo Cerebro — Guía de uso (AGENT)

Manual operativo del knowledge graph (proyectos, conceptos, patrones, herramientas, lecciones,
decisiones) enlazado con `[[wikilinks]]`. `_Config/` es la plantilla portátil que se copia a
cualquier proyecto para conectarlo al grafo.

## Regla rectora: Estado vs Historia

- **Estado** (lo cierto ahora): notas con `updated:` al día en `Proyectos/`, `Conceptos/`,
  `Patrones/`, `Herramientas/`, `Decisiones/`, `Lecciones/`. Fuente de la verdad.
- **Brain** (auto-mejora del agente): `Brain/Errores/` y `Brain/Aciertos/`. Registro crudo, busca-able.
- **Historia** (qué pasó y por qué): worklog (append-only) + ADRs. **El registro de cada proyecto vive
  en su propia carpeta**: `Proyectos/<Nombre>/Worklog/` + `Proyectos/<Nombre>/Decisiones/`.
- **Promové durable**: el trabajo entra al worklog y, cuando cambia algo cierto, se actualiza
  la nota durable + su `updated`.
- Conflicto: manda la nota con `updated` más reciente. Si una nota contradice el código,
  manda el código: corregí la nota.

Más convenciones del vault en `[[Meta/Conventions]]`.

## Primer inicio (una sola vez)
Seguí el checklist de `[[_Config/PRIMER-INICIO]]`: apuntá el `opencode.json` global al vault
(`instructions`, `skills`, `plugin`), definí `OPENBRAIN_PROJECTS_ROOT`, indexá inicial y
verificá con `/buscar` y `/metricas`. El vault se auto-detecta; no hace falta más config.

## Navegar barato (índice-primero)
**No leas el vault entero ni grepees global.** De lo más barato a lo más caro:
1. Hub `OpenBrainCode.md` → mapa de áreas.
2. Índice del área o `_Dashboard.md`.
3. Ficha del proyecto: `Proyectos/<Nombre>/<Nombre>.md`.
4. Nota de concepto/patrón/herramienta/lección/ADR concreta.
5. Worklog y ADRs del proyecto (`Proyectos/<Nombre>/Worklog/`, `Proyectos/<Nombre>/Decisiones/`) solo si necesitás la historia.

## Flujo diario
1. Creá/abrí el worklog del proyecto (`Proyectos/<Nombre>/Worklog/YYYY-MM-DD.md`) y logueá append-only;
   ADRs propios del proyecto van en `Proyectos/<Nombre>/Decisiones/`.
2. **Promové lo durable**: actualizá la nota correspondiente + `updated`.
3. **Registrá en `Brain/`**: al terminar la tarea, chequeá si hubo un **error resuelto** o un **acierto**
   → escribilo en `Brain/Errores/` o `Brain/Aciertos/` en el MISMO gesto (aplica también dentro de tareas
   delegadas: el subagente lo registra directo y reporta el campo `Brain` en su contract de salida).
4. Conocimiento que se expresa (post, tutorial, decisión) → resumen a `_Outbox/`.

## Auto-registro de errores y aciertos (regla de oro)
**Lo que solo queda en la memoria de conversación no existe.** Ante un error o un acierto, escribe
inmediatamente a la memoria del brain (`Brain/`, central en la raíz del vault):
- **Error resuelto** → crear/actualizar `Brain/Errores/<kebab-case>.md` en el MISMO gesto en que se
  diagnostica y arregla (plantilla: `Brain/Errores/Template Error`). Incluí síndrome, causa, solución
  y keywords de búsqueda para que un futuro `/buscar` lo encuentre.
- **Acierto** (algo que funcionó bien y vale repetir) → `Brain/Aciertos/<kebab-case>.md`
  (plantilla: `Brain/Aciertos/Template Acierto`).
- **Promoción a Lecciones**: si el error/acierto vale como lección general y curada para leer humano,
  copiá una versión pulada en `Lecciones/` **y enlazála** desde la nota de Brain (no duplicar el hecho
  sin el enlace). `Brain/` es el registro crudo; `Lecciones/` lo presentable.

## Skills de opencode (se cargan bajo demanda)
| Skill | Uso |
|-------|-----|
| `scrape-proyecto` | Genera/actualiza ficha de un proyecto con conexiones |
| `indexar-proyectos` | Regenera el knowledge graph completo |
| `buscar-proyecto` | Busca en el grafo siguiendo las conexiones `[[...]]` |
| `nuevo-proyecto-base` | Scaffoldea base full-stack (backend + SPA) con auth y componentes UI según las reglas |
| `nuevo-proyecto-gestionado` | Encuesta la idea hasta definir el producto (spec + ADRs) y construye con TDD |
| `web-clipper` | Captura contenido web al vault (usa `defuddle` para extracción limpia; degrada a `webfetch`) |
| `obsidian-markdown` | Escritura canónica del grafo: wikilinks/heading, embeds, callouts, properties (de `kepano/obsidian-skills`, MIT) |
| `api-and-interface-design` | Contract-first para APIs y fronteras de módulos |
| `test-driven-development` | Desarrollo guiado por tests (red-green-refactor) |
| `code-simplification` | Simplificar código preservando comportamiento |
| `code-review-and-quality` | Revisión de código en cinco ejes |
| `frontend-ui-engineering` | Arquitectura de componentes, design systems y a11y |
| `task-observer` | Observa sesiones y captura mejoras de skills en `Brain/Skills/` (automatiza la regla de oro) |
| Detector anti-diseño-genérico | Script `impeccable-detector/run.mjs` (integrado en `frontend-ui-engineering`) — detecta señales de "aesthetic AI" |

## Ecosistema de skills (búsqueda/adopción)
Buscá y evaluá skills del ecosistema según **[[Reglas/Comunes/Ecosistema Skills]]**: `npx skills find`
como utilidad, criterios de filtrado (respetar `SKILL.md`, no duplicar skills propias, no competir con
`Brain/`, portabilidad), y registro de adoptado/descartado en `Decisiones/`. Las skills nuevas se crean
en `_Config/.opencode/skills/<kebab-case>/SKILL.md` (auto-load por `skills.paths`).

## Agentes (subagentes por rol, `_Config/.opencode/agents/`)
Cada subagente lee **las reglas de su carpeta** en `Reglas/<Carpeta>/` + `Reglas/Comunes/` antes de trabajar. Registro en la config global vía `agent: { <rol>: { prompt: "{file:<vault>/_Config/.opencode/agents/<rol>.md}" } }`.

| Agente | mode | Lee reglas | Rol |
|--------|------|-----------|-----|
| `brain` | primary | `Meta/Conventions` + documentos del hub | Curador y consultor del knowledge graph: consultas, ordenar/enlazar el vault, reconstruir índices |
| `pm` | primary | `Reglas/Comunes/` | Orquesta: parte feedback en tareas y delega a los subagentes |
| `backend` | subagent | `Reglas/Backend/` + `Comunes/` | Backend Express+Drizzle+Biome, contract-first + TDD |
| `frontend` | subagent | `Reglas/Frontend/` + `Comunes/` | SPA React+Vite+TanStack, a11y + Core Web Vitals |

Scripts PowerShell en `_Config/.opencode/scripts/` (auto-detectan el vault; `-VaultPath` opcional).

## Qué NO hacer
- No crear notas vacías ni huérfanas. No duplicar: enlazalo si ya existe.
- No volcar transcripts: sintetizar y promover a durable.
- No incluir secretos. No reescribir el worklog (es append-only).
- No crear carpetas top-level nuevas sin registrarlo en convenciones.

## Git sync (automático — no intervenir)
El vault se sincroniza solo a `master` en `origin` (el remote del repo donde viva este template).
`_Config/.opencode/plugins/vault-sync.ts` (vía config global) commitea + pushea los cambios
(debounce ~5s, solo si hay diferencias, `--no-verify`). El plugin viaja en el repo y se
auto-carga en cualquier PC con opencode; no requiere instalación. Si el push falla, los
cambios quedan en el working tree para resolver manualmente (`git status` en la raíz del vault).