import { execSync } from "node:child_process"
import fs from "node:fs"
import path from "node:path"

const VAULT = path.resolve(import.meta.dirname, "..", "..")
const BRANCH = "master"
const V = VAULT.toLowerCase()
const DEBOUNCE_MS = 5000
let t: ReturnType<typeof setTimeout> | undefined
let syncing = false

function inVault(p?: string) {
  return !!p && p.replace(/\\/g, "/").toLowerCase().startsWith(V)
}

function inGitDir(p: string) {
  return p.replace(/\\/g, "/").split("/").includes(".git")
}

function scan() {
  if (t) clearTimeout(t)
  t = undefined
  if (syncing) return
  syncing = true
  try {
    const dirty = execSync(`git -C "${VAULT}" status --porcelain`).toString().trim()
    if (!dirty) return
    try {
      execSync(`git -C "${VAULT}" checkout ${BRANCH}`, { stdio: "ignore", cwd: VAULT })
    } catch {
      // ya está en la rama o error de checkout; se continúa igual
    }
    execSync(`git -C "${VAULT}" add -A`, { cwd: VAULT })
    execSync(`git -C "${VAULT}" commit -m "vault: auto-sync de ingresos al brain" --no-verify`, {
      stdio: "ignore",
      cwd: VAULT,
    })
    execSync(`git -C "${VAULT}" push origin ${BRANCH}`, { stdio: "ignore", cwd: VAULT })
  } catch {
    // commit/push fallido (conflicto, sin red): se deja en el working tree para resolver
  } finally {
    syncing = false
  }
}

function schedule() {
  if (t) clearTimeout(t)
  t = setTimeout(scan, DEBOUNCE_MS)
}

export default () => {
  // Auto-sync también de cambios hechos FUERA de opencode (Obsidian, edición manual,
  // scripts). Se ignora .git para no generar loops; el debounce agrupa ráfagas y
  // scan() no commitea si el working tree está limpio.
  try {
    const w = fs.watch(VAULT, { recursive: true }, (_event, filename) => {
      if (inGitDir(filename || "")) return
      schedule()
    })
    w.on("error", () => {})
  } catch {
    // watcher no disponible; el hook de tools sigue funcionando
  }

  return {
    "tool.execute.after": (ev: any) => {
      const f = ev.input?.args?.filePath ?? ev.input?.args?.file
      if ((ev.input?.tool === "edit" || ev.input?.tool === "write") && inVault(f)) {
        schedule()
      }
    },
  }
}