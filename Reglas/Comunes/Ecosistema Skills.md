<!-- @regla ecosistema-skills -->
---
type: regla
category: ecosistema
area: ecosistema
updated: 2026-08-09
tags: [regla, ecosistema, skills, opencode, busqueda, adopcion]
---

# Ecosistema de Skills — Cómo buscar y adoptar skills del ecosistema

> Regla para descubrir, evaluar e incorporar skills de **agentes** (opencode / Claude Code) al
> vault sin romper sus convenciones. Define cómo usar `npx skills` como herramienta de
> búsqueda, los criterios de filtrado, y el registro de qué se adoptó / descartó y por qué.
> Relacionado: `task-observer` (skill del vault) automatiza la captura de mejoras; esti busca
> activa en el ecosistema. Ver también [[OpenBrainCode]].

## Herramienta de búsqueda: `npx skills` (utilidad, no es una skill)

Usá **`vercel-labs/skills`** (`npx skills find|add`) como **herramienta de descubrimiento**,
pero no instalés la CLI dentro de `_Config/.opencode/skills/`. Su valor es **buscar y evaluar**
candidatas del ecosistema abierto de agent skills; las candidatas se integran manualmente con
los criterios de abajo.

- `npx skills find <término>` — descubre skills del ecosistema.
- Proseguí la evaluación vos (revisá el repo, el `SKILL.md`, el bundle) en vez de `add` a ciegas.
- Las skills instalables al vault viven en `_Config/.opencode/skills/<nombre>/SKILL.md`.
  Como la config global apunta a toda la carpeta (`skills.paths`), **basta con crear la carpeta
  de la skill; no hace falta tocar la config**.

## Criterios de filtrado (antes de adoptar)

Un skill del ecosistema se adopta **solo si**:

1. **Respeta el formato `SKILL.md`** — compatibilidad con el auto-load de
   `_Config/.opencode/skills/` (frontmatter `name`/`description` en inglés).
2. **No duplica skills existentes** — revisá superposición con las skills del vault
   (`frontend-ui-engineering`, `test-driven-development`, `code-review-and-quality`,
   `code-simplification`, `buscar-proyecto`, `web-clipper`, `api-and-interface-design`, etc.).
   Si ya lo cubrís, **descartala** o integrá su valor como mejora a la skill propia.
3. **Respeta la regla de oro del vault** — que lo aprendido vaya a `Brain/` y worklogs.
   Skills con su propia memoria de sesión (tipo ClaudeMem) **compten** con `Brain/` → descártalas
   o reencanalalas.
4. **Peso y portabilidad** — preferí skills autocontenidas y sin deps frágiles. Los bundles
   pesados acoplados a un runtime (nodes `PV`, `hooks`/`agents .toml` de Claude Code…) suelen no
   ser portables a opencode; extraé solo la parte de valor (ej. un detector) en vez del bundle.
5. **Licencia y atribución** — respetá la licencia del autor y dejá la atribución en el SKILL.md.

## Cómo se materializa (pragmático)

- **Adopción total:** carpeta nueva en `_Config/.opencode/skills/<kebab-case>/SKILL.md` y
  documentar en `Reglas/`.
- **Adopción parcial:** extraer el sub-componente útil (script, detector, playbook) a
  `_Config/.opencode/` e integarlo como capa de una skill existente.
- **Descartar:** NO crear notas vacías; registrá el "por qué" en una Decisión y/o Acierto.

## Registro de decisiones

Cada evaluación de ecosistema se registra como **Decisión** (`Decisiones/Adopcion de skills del
ecosistema.md`) con la tabla **adoptado / descartado / motivo**, para que un futuro `/buscar`
encuentre el criterio y evite re-evaluar lo mismo.

## Catalogo vigente del vault

| Skill | Origen | Rol |
|-------|--------|-----|
| `obsidian-markdown` | `kepano/obsidian-skills` (MIT) | Escritura canónica del vault: wikilinks, embeds, callouts, properties (ADR-004) |
| `web-clipper` + `defuddle` | `kepano/obsidian-skills` (MIT) | Extracción markdown limpio de páginas web como paso preferido del clipper (ADR-004) |
| `task-observer` | `rebelytics/one-skill-to-rule-them-all` | Observa sesiones y captura mejoras en `Brain/Skills/` (ADR-003) |
| Detector anti-diseño-genérico | `pbakaus/impeccable` (Apache-2.0) | Capa de chequeo en `frontend-ui-engineering` (ADR-003) |
| `playwright-cli` | `microsoft/playwright-cli` (MIT) | Navegador en vivo para el agente (`npx playwright cli`): verificar E2E y UI en el browser real, sin MCP ni config global |

> Descartados con motivo: `superpowers` (duplica TDD/review), `claude-mem` (compite con `Brain/`, ADR-003);
> `obsidian-bases`, `json-canvas`, `obsidian-cli` (valor bajo vs. costo/solapamiento, ADR-004).