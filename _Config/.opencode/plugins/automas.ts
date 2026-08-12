import fs from "node:fs"
import path from "node:path"

const VAULT = path.resolve(import.meta.dirname, "..", "..")
const DATA_DIR = path.join(VAULT, "_Config", ".opencode", "data")
const USO_FILE = path.join(DATA_DIR, "uso.json")
const STATE_FILE = path.join(DATA_DIR, "automas.json")
const ERRORES_DIR = path.join(VAULT, "Brain", "Errores")
const UPDATE_DIR = path.join(VAULT, "Meta", "Update")
const V = VAULT.toLowerCase()

const WRITE_TOOLS = ["edit", "write"]
const READ_TOOLS = ["read", "grep", "glob", "list"]
const WATCH_TOOLS = new Set([...WRITE_TOOLS, ...READ_TOOLS])
const REPETICION_UMBRAL = 3
const DAY_MS = 24 * 60 * 60 * 1000
let t: ReturnType<typeof setTimeout> | undefined

function inVault(p?: string) {
  return !!p && p.replace(/\\/g, "/").toLowerCase().startsWith(V)
}

function relPath(p: string) {
  const abs = path.resolve(p)
  if (!inVault(abs)) return null
  return path
    .relative(VAULT, abs)
    .replace(/\\/g, "/")
    .replace(/^\//, "")
}

function ensureData() {
  fs.mkdirSync(DATA_DIR, { recursive: true })
  fs.mkdirSync(UPDATE_DIR, { recursive: true })
  if (!fs.existsSync(USO_FILE)) fs.writeFileSync(USO_FILE, "{}", "utf8")
  if (!fs.existsSync(STATE_FILE)) {
    fs.writeFileSync(STATE_FILE, JSON.stringify({ lastDaily: 0 }, null, 2), "utf8")
  }
}

function today() {
  return new Date().toISOString().slice(0, 10)
}

// ---------- Uso ----------

function loadUso(): Record<string, { reads?: number; writes?: number; last?: string }> {
  try {
    return JSON.parse(fs.readFileSync(USO_FILE, "utf8"))
  } catch {
    return {}
  }
}

function saveUso(uso: Record<string, any>) {
  ensureData()
  fs.writeFileSync(USO_FILE, JSON.stringify(uso, null, 2), "utf8")
}

function recordUso(filePath?: string, tool?: string) {
  if (!filePath) return
  const rel = relPath(filePath)
  if (!rel || rel === ".git" || rel.startsWith(".git/") || rel.startsWith("_Config/.opencode/data/")) return
  const uso = loadUso()
  const day = today()
  const entry = uso[rel] || (uso[rel] = {})
  if (WRITE_TOOLS.includes(tool || "")) entry.writes = (entry.writes || 0) + 1
  else entry.reads = (entry.reads || 0) + 1
  entry.last = day
  const byDay = (uso["_byDay"] ||= {})
  byDay[day] = (byDay[day] || 0) + 1
  saveUso(uso)
}

// ---------- Auto-mejora (diaria) ----------

function parseFm(src: string): Record<string, string> {
  const m = src.match(/^---\n([\s\S]*?)\n---/)
  if (!m) return {}
  const fm: Record<string, string> = {}
  for (const line of m[1].split("\n")) {
    const match = line.match(/^\s*([a-zA-Z_]+)\s*:\s*(.*)$/)
    if (match) fm[match[1].trim()] = match[2].trim()
  }
  return fm
}

function tagsOf(fmTags: string): string[] {
  return fmTags
    .replace(/^\[|\]$/g, "")
    .split(",")
    .map((s) => s.trim().replace(/^["']|["']$/g, ""))
    .filter(Boolean)
}

function slug(s: string) {
  return s.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "")
}

function generarUpdate() {
  ensureData()
  const state = JSON.parse(fs.readFileSync(STATE_FILE, "utf8"))
  const last = state.lastDaily || 0
  const now = Date.now()
  if (now - last < DAY_MS) return
  state.lastDaily = now

  if (!fs.existsSync(ERRORES_DIR)) return saveState(state)

  const files = fs.readdirSync(ERRORES_DIR).filter((f) => f.endsWith(".md") && !f.startsWith("Template"))
  const patrones = new Map<string, string[]>() // key category|tag -> [fuentes]
  const erroresPorFile: Array<{ file: string; fm: Record<string, string> }> = []

  for (const f of files) {
    const abs = path.join(ERRORES_DIR, f)
    let src = ""
    try {
      src = fs.readFileSync(abs, "utf8")
    } catch {
      continue
    }
    const fm = parseFm(src)
    if (fm.type !== "error" || fm.status === "en curso") continue
    const category = fm.category || ""
    const tags = tagsOf(fm.tags || "")
    erroresPorFile.push({ file: f, fm })
    const techTags = tags.filter((t) => t !== "error" && t !== category)
    for (const tg of techTags) {
      const key = `${category}|${tg}`
      if (!patrones.has(key)) patrones.set(key, [])
      const arr = patrones.get(key)!
      if (!arr.includes(f)) arr.push(f)
    }
  }

  for (const [key, fuentes] of patrones) {
    if (fuentes.length < REPETICION_UMBRAL) continue
    const [category, tag] = key.split("|")
    const metaName = `Meta/Update/${slug(category)}-${slug(tag)}.md`
    const abs = path.join(VAULT, metaName)
    const links = fuentes.map((f) => `- [[Brain/Errores/${f.replace(/\.md$/, "")}]]`).join("\n")
    const body = `---
type: meta
category: update
project: OpenBrainCode
status: propuesta
updated: ${today()}
tags: [meta, update, auto-mejora, ${slug(category)}, ${slug(tag)}]
---

# Propuesta de mejora: ${category} · ${tag}

> Generada automáticamente (plugin \`automas.ts\`). Revisar y decidir si se aplica. Heurística determinista por repetición.

## Qué se repite

El mismo patrón de error en categoría \`${category}\` con la tecnología/tema \`${tag}\` aparece en **${fuentes.length}** errores resueltos.

## Fuentes (no duplicar: enlazar)

${links}

## Regla práctica propuesta

\`${tag}\`: ante ${category}, verificar SIEMPRE este patrón. \`NUNCA\` asumir que se resuelve en caliente; documentar el fix en \`Brain/Errores/\` y promover a \`Lecciones/\` si aplica.

## Acción sugerida

- [ ] Validar que la repetición es real (revisar las fuentes).
- [ ] Promover a \`Lecciones/\` una regla curada general.
- [ ] Si aplica, crear una skill o check que prevenga este error.
`
    fs.writeFileSync(abs, body, "utf8")
  }

  saveState(state)
}

function saveState(state: any) {
  ensureData()
  fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2), "utf8")
}

function scheduleWrite() {
  if (t) clearTimeout(t)
  t = setTimeout(() => generarUpdate(), 1500)
}

export default () => {
  ensureData()
  generarUpdate()

  try {
    const w = fs.watch(ERRORES_DIR, { recursive: true }, () => {
      scheduleWrite()
    })
    w.on("error", () => {})
  } catch {
    // watcher no disponible
  }

  return {
    "tool.execute.after": (ev: any) => {
      const tool = ev.input?.tool
      const f = ev.input?.args?.filePath ?? ev.input?.args?.file
      if (tool && WATCH_TOOLS.has(tool) && inVault(f)) {
        recordUso(f, tool)
      }
    },
  }
}
