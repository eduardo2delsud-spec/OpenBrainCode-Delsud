---
name: nuevo-proyecto-gestionado
description: Use when the user wants to create a NEW project but the idea is not well-defined yet and must be shaped first via an interview, then built. Triggers: "quiero un producto", "definir mi idea", "proyecto gestionado", "encuesta de proyecto", "tengo una idea", "crear proyecto gestionado". Runs an adaptive interview until the product is well-defined, persists a spec (Producto.md) + ADRs, then scaffolds the base (reuses nuevo-proyecto-base) and builds the defined modules with TDD.
---

# Nuevo Proyecto — Modo GESTIONADO (Definir + Construir)

Crea un proyecto desde **una idea todavía no definida**: se encuesta al usuario de forma adaptativa
hasta tener un **producto bien definido**, se persiste la especificación en el vault, y **se construye**.
Se apoya en `[[nuevo-proyecto-base]]` para el scaffold y en los subagentes `backend`/`frontend` con
TDD para las features.

> Para un scaffold directo sin encuesta, usá **`nuevo-proyecto-base`**. Este modo agrega la capa de
> definición de producto delante del mismo scaffold.

## Fase 1 — Encuesta adaptativa (hasta producto definido)

Preguntá **por rondas, de lo amplio a lo concreto**, adaptándote a las respuestas. No es un cuestionario
fijo: seguí las ramas que el usuario abre y saltá las que no aplican. Dimensiones a recorrer:

1. **Idea y problema** — qué hace el producto, qué problema resuelve, para quién.
2. **Alcance** — ¿MVP mínimo viable o producto completo? Prioridades (primero lo esencial).
3. **Features/módulos** — funcionalidades concretas; agrupalas en módulos/dominios.
4. **Datos** — entidades principales, relaciones, datos maestros.
5. **Auth** — ¿necesita cuentas de usuario? ¿Qué pantallas de `[[Reglas/Frontend/Autenticacion]]` aplican?
6. **Integraciones** — APIs/servicios externos (stripe, IA, webhooks, etc.).
7. **Stack y decisiones** — confirmá prefs de `[[Decisiones/ADR-002 Preferencias de stack]]`; registrá
   las desviaciones como ADR nuevas.
8. **Entregas** — qué se construye en esta primera versión vs después.

**Criterio de corte**: la encuesta termina cuando quedan **definidos MVP + módulos/features + modelo de
datos** y hay consenso de alcance. Si falta alguno, seguí preguntando. Resumí el producto en 3-5
líneas para confirmar con el usuario antes de persistir.

## Fase 2 — Persistir la especificación

En el vault, crear/actualizar **dentro de la carpeta del proyecto** `Proyectos/<Nombre>/`:

- **`Proyectos/<Nombre>/Producto.md`** — spec narrativa del producto: qué hace, a quién, problema,
  MVP vs completo, features/módulos (con prioridad), modelo de datos, auth, integraciones, alcance de
  entregas. (La ficha factual `<Nombre>.md` la genera `generar-ficha.ps1`/scrape aparte; no pisar su
  bloque `<!-- AUTO -->`.)
- **ADRs propios** — `Proyectos/<Nombre>/Decisiones/ADR-XXX <Título>.md` (plantilla
  `[[Decisiones/Template ADR]]`) para las decisiones de la encuesta que no estén ya cubiertas por
  `ADR-002` (nuevas integraciones, stack distinto, alcance especial). El registro del proyecto
  siempre vive dentro de su carpeta.
- **Ficha** `Proyectos/<Nombre>/<Nombre>.md` — registrar el proyecto y enlazar el `Producto.md`.
- **Worklog** `Proyectos/<Nombre>/Worklog/<YYYY-MM-DD>.md`.

## Fase 3 — Scaffold base

Delegá en la skill **`nuevo-proyecto-base`** para crear el base full-stack (backend + frontend SPA)
con auth y componentes UI según `[[Reglas/Frontend/Autenticacion]]` y `[[Reglas/Frontend/Componentes UI]]`.

## Fase 4 — Construir los módulos definidos (TDD)

Con el spec y el base listos, construir los **módulos/features del MVP** definidos en `Producto.md`:

1. **Contract-first** (skill `api-and-interface-design`): definí el contrato de la API por módulo antes
   de implementar.
2. **TDD** (skill `test-driven-development`): red-green-refactor por feature.
3. **Delegar rol**: módulos backend → subagente `backend`; módulos frontend → subagente `frontend`;
   `pm` orquesta el feedback y el reparto.
4. **UI según** `[[Reglas/Frontend/Componentes UI]]` (estados, toast, paginación, tokens).
5. Actualizar `CHANGELOG.md` y `README.md` (`## Endpoints`, `Stack`) a medida que se agregan features.

## Fase 5 — Verificar y registrar

1. `npm run check` + `npm run typecheck` + tests en cada servicio.
2. `npm run dev` confirmando banner backend + SPA frontend.
3. Registrar en el brain: ficha + worklog + ADRs ya creados; enlazar el producto a
   `[[Proyectos/<Nombre>/Producto]]`.

## Relacionado

- `nuevo-proyecto-base` — el scaffold base full-stack reutilizado en la Fase 3.
- `test-driven-development`, `api-and-interface-design`, `code-review-and-quality` — cómo se construye.
- `scrape-proyecto` / `generar-ficha.ps1` — ficha factual del proyecto.