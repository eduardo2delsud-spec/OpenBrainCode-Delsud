// brain-guard.ts — Safety-net del Segundo Cerebro.
// Recuerda registrar en `Brain/` los errores resueltos y aciertos cuando el flujo
// produce ediciones de código sin escritura en Brain. Conservador y a prueba de fallos:
// NUNCA rompe el arranque de opencode (toda la lógica va envuelta en try/catch).
import fs from "node:fs"
import path from "node:path"

const VAULT = path.resolve(import.meta.dirname, "..", "..")
const DATA_DIR = path.join(VAULT, "_Config", ".opencode", "data")
const STATE_FILE = path.join(DATA_DIR, "brain-guard.json")
const V = VAULT.toLowerCase()

// Rutas que NO cuentan como "código" para el guard.
const IGNORE_PREFIX = [".git", "_Config/.opencode/data", "Brain/", "Meta/Update/", "_Inbox/", "_Outbox/"].map((p) =>
  p.toLowerCase(),
)
// Errores/aciertos se consideran "registrado" si tocan estas carpetas.
const BRAIN_PREFIXES = ["brain/errores", "brain/aciertos"]

const FIX_HINT_AFTER_EDITS = 1 // tras este n° de edits de código sin Brain, se arma el hint
const COOLDOWN_S = 600 // una vez por ventana con cooldown, por sesión

type State = {
  sessionKey: string
  sourceEdits: number
  brainWrites: number
  lastHint: number
  hinted: boolean
}

function loadState(key: string): State {
  try {
    if (fs.existsSync(STATE_FILE)) {
      const raw = JSON.parse(fs.readFileSync(STATE_FILE, "utf8"))
      if (raw.sessionKey === key) return raw
    }
  } catch {
    /* ignore */
  }
  const s: State = { sessionKey: key, sourceEdits: 0, brainWrites: 0, lastHint: 0, hinted: false }
  saveState(s)
  return s
}

function saveState(s: State) {
  try {
    fs.mkdirSync(DATA_DIR, { recursive: true })
    fs.writeFileSync(STATE_FILE, JSON.stringify(s, null, 2), "utf8")
  } catch {
    /* ignore */
  }
}

function inVault(p?: string) {
  return !!p && p.replace(/\\/g, "/").toLowerCase().startsWith(V)
}

function relPath(p: string) {
  const abs = path.resolve(p)
  if (!inVault(abs)) return null
  const rel = path.relative(VAULT, abs).replace(/\\/g, "/")
  return rel.startsWith("..") ? null : rel
}

function isIgnored(rel: string) {
  const l = rel.toLowerCase()
  return IGNORE_PREFIX.some((p) => l.startsWith(p) || l === p)
}

function isBrain(rel: string) {
  const l = rel.toLowerCase()
  return BRAIN_PREFIXES.some((p) => l.startsWith(p))
}

function sessionKey(): string {
  // opencode pasa el sessionID en el input de los hooks; acá lo derivamos por proceso para
  // no depender de un campo exacto: un marcador por arranque del plugin.
  return String(process.pid + "-" + Date.now().toString(36))
}

const REMINDER =
  "[brain-guard] Este turno editó código fuente en el vault sin registrar en `Brain/`. " +
  "Si resolviste un ERROR o tuviste un ACIERTO, escribilo en `Brain/Errores/<kebab>.md` o " +
  "`Brain/Aciertos/<kebab>.md` en el mismo gesto (plantillas del vault). Lo que no queda en el brain no existe."

function tryInject(fn: () => void) {
  try {
    fn()
  } catch {
    /* nunca romper opencode */
  }
}

type Args = { filePath?: string; file?: string; command?: string }

export default (() => {
  const key = sessionKey()
  const state = loadState(key)

  tryInject(() => fs.mkdirSync(DATA_DIR, { recursive: true }))

  return {
    "tool.execute.after": (ev: any) => {
      tryInject(() => {
        const tool: string | undefined = ev?.input?.tool
        const args: Args = ev?.input?.args ?? {}
        const target = args.filePath ?? args.file
        if (!target || !inVault(target)) return
        const rel = relPath(target)
        if (!rel) return

        // Registro de Brain: resetear el hint (ya está cubierto).
        if (isBrain(rel)) {
          state.brainWrites += 1
          state.hinted = false
          state.sourceEdits = 0
          state.lastHint = 0
          saveState(state)
          return
        }
        if (isIgnored(rel)) return

        // Edición/escritura de código fuente -> candidato de fix.
        if (tool === "edit" || tool === "write") state.sourceEdits += 1
        saveState(state)
      })
    },

    "experimental.chat.message.transform": (msgs: any[] | undefined) => {
      tryInject(() => {
        if (!Array.isArray(msgs)) return
        const now = Date.now()
        // Corto: señal válida solo de día/frecuencia razonable.
        if (state.hinted) return
        if (now - state.lastHint < COOLDOWN_S * 1000) return
        if (state.brainWrites > 0) return
        if (state.sourceEdits < FIX_HINT_AFTER_EDITS) return
        // Inyectar recordatorio en el último mensaje del sistema para que lo vea el modelo.
        for (let i = msgs.length - 1; i >= 0; i--) {
          const m = msgs[i]
          if (m?.role === "system" && typeof m.content === "string") {
            m.content += "\n\n" + REMINDER
            state.lastHint = now
            state.hinted = true
            saveState(state)
            break
          }
        }
      })
    },
  }
})