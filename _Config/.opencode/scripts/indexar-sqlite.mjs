import { DatabaseSync } from "node:sqlite"
import fs from "node:fs"
import path from "node:path"

const HELP = `Usage: node indexar-sqlite.mjs [--vault <path>] [--db <path>]

Espeja TODO el vault (notas + frontmatter + wikilinks) en una DB SQLite relacional.

Opciones:
  --vault <path>   ruta del vault (auto-detectada si se omite)
  --db <path>      ruta de la DB de salida (por defecto: <vault>/openbraincode.db)
  --dry            imprime conteos detallados y no deja actuators
  -h, --help       esta ayuda
`

const EXCLUDE_DIRS = new Set([
  ".git", ".obsidian", "node_modules", ".opencode", "data", ".cache",
])
const EXCLUDE_PREFIXES = ["_Config/.opencode/data", "_Inbox/.gitkeep"]

function detectVault(startDir) {
  let cur = path.resolve(startDir)
  while (true) {
    if (fs.existsSync(path.join(cur, "Proyectos"))) return cur
    const parent = path.dirname(cur)
    if (parent === cur) return null
    cur = parent
  }
}

function parseArgs(argv) {
  const args = { vault: null, db: null, dry: false }
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i]
    if (a === "--vault") args.vault = argv[++i]
    else if (a === "--db") args.db = argv[++i]
    else if (a === "--dry") args.dry = true
    else if (a === "-h" || a === "--help") args.help = true
  }
  return args
}

function walkMarkdown(root) {
  const files = []
  const stack = [root]
  while (stack.length) {
    const dir = stack.pop()
    let entries
    try {
      entries = fs.readdirSync(dir, { withFileTypes: true })
    } catch {
      continue
    }
    for (const e of entries) {
      const abs = path.join(dir, e.name)
      if (e.isDirectory()) {
        if (EXCLUDE_DIRS.has(e.name) || e.name.startsWith(".")) continue
        stack.push(abs)
      } else if (e.isFile() && e.name.endsWith(".md")) {
        files.push(abs)
      }
    }
  }
  return files.sort()
}

function parseFrontmatter(src) {
  const m = src.match(/^\uFEFF?---\r?\n([\s\S]*?)\r?\n---/)
  if (!m) return { fields: {}, bodyStart: 0 }
  const fields = {}
  const raw = m[1]
  const lines = raw.split(/\r?\n/)
  let key = null
  let inList = null
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]
    const kv = line.match(/^\s*([A-Za-z_][A-Za-z0-9_-]*)\s*:\s*(.*)$/)
    if (kv && !line.startsWith(" ") && !line.startsWith("\t") && !inList) {
      key = kv[1]
      inList = null
      let val = kv[2].trim()
      if (/^\[(.*)\]$/.test(val)) {
        val = val.slice(1, -1).split(",").map((s) => s.trim().replace(/^["']|["']$/g, "")).filter(Boolean)
      } else {
        val = val.replace(/^["']|["']$/g, "")
      }
      fields[key] = val
    } else if (key && /^\s*(-|\[|\])/.test(line)) {
      const item = line.trim().replace(/^-|\]$/g, "").trim().replace(/^["']|["']$/g, "")
      if (item && Array.isArray(fields[key])) {
        if (!Array.isArray(fields[key])) fields[key] = [fields[key]]
        fields[key].push(item)
      }
    } else if (key && !/^\s*-/.test(line) && line !== "") {
      key = null
    }
  }
  let bodyStart = src.indexOf("\n---", m[0].length)
  if (bodyStart < 0) bodyStart = m[0].length + 1
  else bodyStart += "\n---".length - 1
  return { fields, bodyStart }
}

function extractLinks(src, area) {
  const links = new Set()
  const re = /\[\[([^\]|#]+)(?:\|([^\]]+))?\]\]/g
  let m
  while ((m = re.exec(src))) {
    let target = m[1].trim()
    if (target.startsWith(".")) continue
    target = target.replace(/\//g, "/")
    if (target.startsWith("_Config") || target.startsWith("http")) continue
    const base = target.split("/").pop()
    links.add(JSON.stringify([target, base, (m[2] || "").trim()]))
  }
  return [...links].map((l) => JSON.parse(l))
}

function titleOf(src, fallback) {
  const h1 = src.match(/^#\s+(.+)$/m)
  return h1 ? h1[1].trim() : fallback
}

function relPath(root, abs) {
  const rel = path.relative(root, abs).split("\\").join("/")
  return rel
}

function areaOf(rel) {
  return rel.split("/")[0]
}

async function main() {
  const args = parseArgs(process.argv.slice(2))
  if (args.help) {
    console.log(HELP)
    return
  }
  if (!args.vault) {
    args.vault = detectVault(import.meta.dirname)
    if (!args.vault) {
      console.error("[error] No se pudo auto-detectar el vault. Usa --vault <path>")
      process.exit(1)
    }
  }
  args.vault = path.resolve(args.vault)
  if (!args.db) args.db = path.join(args.vault, "openbraincode.db")
  args.db = path.resolve(args.db)

  const started = Date.now()
  const files = walkMarkdown(args.vault).filter((f) => !f.replace(/\\/g, "/").includes("_Config/.opencode/data"))
  console.log(`Vault: ${args.vault}`)
  console.log(`DB   : ${args.db}`)
  console.log(`Notas encontradas: ${files.length}`)

  const notes = []
  for (const abs of files) {
    const rel = relPath(args.vault, abs)
    let src
    try {
      src = fs.readFileSync(abs, "utf8")
    } catch {
      continue
    }
    const { fields, bodyStart } = parseFrontmatter(src)
    const body = src.slice(bodyStart)
    const stat = fs.statSync(abs)
    notes.push({
      path: rel,
      area: areaOf(rel),
      title: titleOf(src, path.basename(rel, ".md")),
      type: typeof fields.type === "string" ? fields.type : (Array.isArray(fields.type) ? fields.type[0] : null),
      category: typeof fields.category === "string" ? fields.category : (Array.isArray(fields.category) ? fields.category[0] : null),
      tags: Array.isArray(fields.tags) ? fields.tags : (fields.tags ? [fields.tags] : []),
      project: typeof fields.project === "string" ? fields.project : null,
      updated: typeof fields.updated === "string" ? fields.updated : null,
      status: typeof fields.status === "string" ? fields.status : null,
      body,
      frontmatter: JSON.stringify(fields),
      mtime: stat.mtimeMs,
    })
  }

  if (args.dry) {
    const byArea = {}
    const byType = {}
    for (const n of notes) {
      byArea[n.area] = (byArea[n.area] || 0) + 1
      byType[n.type || "(sin type)"] = (byType[n.type || "(sin type)"] || 0) + 1
    }
    console.log("\n[DRY] Por área:")
    for (const [k, v] of Object.entries(byArea).sort((a, b) => b[1] - a[1])) console.log(`  ${k}: ${v}`)
    console.log("\n[DRY] Por type:")
    for (const [k, v] of Object.entries(byType).sort((a, b) => b[1] - a[1])) console.log(`  ${k}: ${v}`)
    console.log("\n[DRY] No se escribió la DB.")
    return
  }

  const db = new DatabaseSync(args.db)
  db.exec("PRAGMA journal_mode = WAL")
  db.exec(`CREATE TABLE IF NOT EXISTS notes (
    id INTEGER PRIMARY KEY,
    path TEXT UNIQUE NOT NULL,
    area TEXT,
    title TEXT,
    type TEXT,
    category TEXT,
    tags TEXT,
    body TEXT,
    frontmatter TEXT,
    updated TEXT,
    mtime REAL
  )`)
  db.exec(`CREATE TABLE IF NOT EXISTS links (
    source INTEGER NOT NULL REFERENCES notes(id),
    target INTEGER NOT NULL REFERENCES notes(id),
    alias TEXT,
    UNIQUE(source, target)
  )`)
  db.exec(`CREATE TABLE IF NOT EXISTS tags (
    area TEXT,
    tag TEXT,
    count INTEGER,
    PRIMARY KEY(area, tag)
  )`)
  db.exec("CREATE INDEX IF NOT EXISTS idx_notes_area ON notes(area)")
  db.exec("CREATE INDEX IF NOT EXISTS idx_notes_type ON notes(type)")
  db.exec("CREATE INDEX IF NOT EXISTS idx_notes_updated ON notes(updated)")
  db.exec("CREATE INDEX IF NOT EXISTS idx_links_target ON links(target)")

  const upsertNote = db.prepare(
    `INSERT INTO notes (path, area, title, type, category, tags, body, frontmatter, updated, mtime)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
     ON CONFLICT(path) DO UPDATE SET
       area=excluded.area, title=excluded.title, type=excluded.type, category=excluded.category,
       tags=excluded.tags, body=excluded.body, frontmatter=excluded.frontmatter,
       updated=excluded.updated, mtime=excluded.mtime`,
  )
  const insertLink = db.prepare(
    `INSERT OR IGNORE INTO links (source, target, alias) VALUES (?, ?, ?)`,
  )
  const getByPath = db.prepare("SELECT id, path FROM notes")
  const deleteLinks = db.prepare("DELETE FROM links")
  const upsertTag = db.prepare(
    `INSERT INTO tags (area, tag, count) VALUES (?, ?, 1)
     ON CONFLICT(area, tag) DO UPDATE SET count = tags.count + 1`,
  )

  const tx = db.exec("BEGIN")
  deleteLinks.run()
  db.exec("DELETE FROM notes")
  db.exec("DELETE FROM tags")

  const pathToId = {}
  for (const n of notes) {
    const info = upsertNote.run(
      n.path, n.area, n.title, n.type, n.category,
      JSON.stringify(n.tags), n.body, n.frontmatter, n.updated, n.mtime,
    )
    pathToId[n.path] = Number(info.lastInsertRowid)
    for (const tag of n.tags) {
      if (tag) upsertTag.run(n.area, tag)
    }
  }

  let linkCount = 0
  for (const n of notes) {
    const srcId = pathToId[n.path]
    const srcRel = n.path.replace(/\//g, "/")
    const links = extractLinks(n.body + n.frontmatter, n.area)
    for (const [rawTarget, base, alias] of links) {
      // resolver: intentar por path exacto relativo al área, o por nombre de base
      let targetId = null
      const candidates = [
        `${n.area}/${rawTarget}.md`,
        rawTarget + ".md",
      ]
      // búsqueda aproximada por nombre de base (cualquier ruta que termine en /base.md)
      if (!targetId) {
        const byPath = Object.keys(pathToId).find((p) => p === candidates[0] || p === candidates[1])
        if (byPath) targetId = pathToId[byPath]
      }
      if (!targetId) {
        const byBase = Object.keys(pathToId).find(
          (p) => p.endsWith(`/${base}.md`) || p === `${base}.md`,
        )
        if (byBase) targetId = pathToId[byBase]
      }
      if (targetId && targetId !== srcId) {
        insertLink.run(srcId, targetId, alias || base)
        linkCount++
      }
    }
  }

  db.exec("COMMIT")
  db.close()

  console.log(`\nNotas : ${notes.length}`)
  console.log(`Enlaces: ${linkCount}`)
  console.log(`OK · ${Date.now() - started}ms`)
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})