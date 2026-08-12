<!-- @config primer-inicio -->
# PRIMER INICIO — Configuración inicial de OpenBrainCode

> Checklist para poner en marcha el segundo cerebro **por primera vez**. Se hace UNA sola vez por máquina.
> Si ya configuraste la ruta y venís a usar el día a día, saltá a [[_Config/AGENTS]].

---

## 0. Requisitos

- [ ] Git instalado.
- [ ] Node.js + npm instalados (solo si vas a usar el MCP semántico).
- [ ] PowerShell (Windows) o bash (Mac/Linux) para los scripts.
- [ ] Obsidian (opcional, para ver el grafo y el dashboard).

---

## 1. Configurá opencode (global) para que apunte al vault

opencode carga la guía del vault (`_Config/AGENTS.md`), los **skills** y el **plugin de auto-sync**
desde el archivo de config **global** de tu máquina (`~/.config/opencode/opencode.json` en Windows
`C:\Users\<usuario>\.config\opencode\opencode.json`). Completá las rutas reales de tu vault:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [""<VAULT_PATH>/_Config/AGENTS.md"],
  "skills": { "paths": [""<VAULT_PATH>/_Config/.opencode/skills"] },
  "plugin": [
    "<VAULT_PATH>/_Config/.opencode/plugins/vault-sync.ts",
    "<VAULT_PATH>/_Config/.opencode/plugins/automas.ts",
    "<VAULT_PATH>/_Config/.opencode/plugins/brain-guard.ts"
  ],
  "agent": {
  "pm":       { "description": "...", "mode": "primary", "prompt": "{file:<VAULT_PATH>/_Config/.opencode/agents/pm.md}" },
  "backend":  { "description": "...", "mode": "subagent", "prompt": "{file:D:<VAULT_PATH>/_Config/.opencode/agents/backend.md}" },
  "frontend": { "description": "...", "mode": "subagent", "prompt": "{file:<VAULT_PATH>/_Config/.opencode/agents/frontend.md}" },
  "brain":    { "description": "Brain curador y consultor del Segundo Cerebro", "mode": "primary", "prompt": "{file:<VAULT_PATH>/_Config/.opencode/agents/brain.md}" }
},
  "command": {
    "indexar-sqlite": {
      "description": "Espeja el vault completo (notas + frontmatter + wikilinks) en openbraincode.db (SQLite).",
      "template": "Ejecutá el script `_Config/.opencode/scripts/indexar-sqlite.ps1` para regenerar el espejo SQLite del vault (openbraincode.db). Si hay argumentos, pasalos al script."
    },
    "ordenar-brain": {
      "description": "Dispara el flujo de curaduría del agente brain: diagnosticar, proponer y aplicar la reorganización/enlazado del vault.",
      "agent": "brain",
      "template": "Ejecutá el Rol 2 — Curador (acomodar ideas) del agente Brain en este vault. Corré el diagnóstico (validar-vault.ps1 + auditar-grafo.ps1), hacé inventario de sueltos/huérfanos, proponé el plan de clasificación/enlazado y aplicá cada lote tras mi OK. Al final reconstruí índices, reindexá proyectos y registrá el trabajo en el worklog."
    }
  }
}
```

> Si no sabés dónde está el vault en esta máquina, preguntale al usuario la ubicación real y usala
> para reemplazar `<VAULT_PATH>` en las tres rutas. El plugin `vault-sync.ts` es el que hace el
> commit + push automático del vault; los scripts se auto-detectan y no piden esta ruta.

---

## 2. Definí la carpeta de proyectos

Los scripts necesitan saber dónde están tus **proyectos de software** para indexarlos.

**Windows (permanente, nivel de usuario):**
```powershell
[Environment]::SetEnvironmentVariable("OPENBRAIN_PROJECTS_ROOT", "C:\Users\<usuario>\Proyectos", "User")
```
**Windows (solo sesión):**
```powershell
$env:OPENBRAIN_PROJECTS_ROOT = "C:\Users\<usuario>\Proyectos"
```
**Mac/Linux:**
```bash
export OPENBRAIN_PROJECTS_ROOT=~/proyectos   # agregar al ~/.bashrc o ~/.zshrc
```

---

## 3. (Opcional) Cloná el MCP knowledge-graph

Si querés **búsqueda semántica** (no solo enlaces `[[...]]`):

```bash
# Clonar como HERMANO del vault (misma carpeta que contiene a OpenBrainCode)
git clone https://github.com/obra/knowledge-graph.git <raiz>/knowledge-graph
cd <raiz>/knowledge-graph
npm install
```

Luego indexá el vault (la primera vez descarga el modelo de ~22MB):
```powershell
$env:KG_VAULT_PATH = "<VAULT_PATH>"
npx tsx src/cli/index.ts index
```

Reiniciá opencode para que cargue el MCP. Si no vas a usar búsqueda semántica, este paso es opcional.

---

## 4. Indexá el gráfo por primera vez

Ejecutá el índice completo:
```
/indexar
```
o desde PowerShell:
```powershell
# con ruta explícita
& "<VAULT_PATH>\_Config\.opencode\scripts\indexar-todo.ps1" -VaultPath "<VAULT_PATH>"
```

Deberías ver el conteo de proyectos indexados, nuevos, y conexiones.

---

## 5. Verificá

- /dashboard: abrí Obsidian sobre `<VAULT_PATH>` y mirá `_Dashboard.md` (dataview).
- /buscar: preguntá algo, ej. `¿qué proyecto usa Docker?`.
- /metricas: conteo de notas por carpeta.

```powershell
> "<VAULT_PATH>\_Config\.opencode\scripts\metricas.ps1" -VaultPath "<VAULT_PATH>"
```

---

## 6. (Opcional) Colores y plugins del grafo

```powershell
# plugins núcleo (dataview, linter, templater, metadata-menu, extended-graph)
> "<VAULT_PATH>\_Config\.opencode\scripts\instalar-plugins.ps1" -VaultPath "<VAULT_PATH>"

# reinjetar colores por tipo (tras regenerar el grafo)
> "<VAULT_PATH>\_Config\.opencode\scripts\aplicar-colores-graph.ps1" -VaultPath "<VAULT_PATH>"
```

---

## 7. Confirmar

- [ ] `opencode.json` global configura las rutas del vault (`instructions`, `skills`, `plugin`).
- [ ] `OPENBRAIN_PROJECTS_ROOT` definido.
- [ ] Índice inicial corrido y con resultados.
- [ ] `/buscar` responde consultas sobre el grafo.

> **Skill de navegador en vivo (`playwright-cli`)** ya viene en `_Config/.opencode/skills/` (autoload).
> Solo requiere tener Playwright en la máquina: `npx playwright --version` y `npx playwright cli --help`.
> Si el subcomando `cli` no existiera, instalá global: `npm i -g @playwright/cli@latest`. No hace falta
> tocarla en cada PC ni configurar MCP.

¡Listo! El segundo cerebro quedó conectado. Para el uso diario, seguí [[_Config/AGENTS]].