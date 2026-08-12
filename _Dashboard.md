# OpenBrainCode Dashboard

> Segundo Cerebro de proyectos. Este dashboard se genera con Obsidian + Dataview.

## Inventario

```dataview
TABLE length(rows) AS "Archivos .md"
FROM ""
WHERE length(file.folder) > 0
  AND !startswith(file.name, "Template")
  AND !contains(file.path, ".obsidian")
GROUP BY split(file.folder, "/")[0] AS "Carpeta"
SORT length(rows) DESC
```

## Proyectos del grafo

```dataview
TABLE
  file.folder AS "Carpeta",
  choice(length(file.etags) > 0, join(file.etags, ", "), "-") AS "Tags"
FROM "Proyectos"
WHERE !startswith(file.name, "Template")
  AND !contains(file.path, "/Decisiones/")
  AND !contains(file.path, "/Notas/")
  AND !contains(file.path, "/Worklog/")
SORT file.name ASC
```

### Proyectos sin tags
```dataview
LIST
FROM "Proyectos"
WHERE !startswith(file.name, "Template")
  AND !contains(file.path, "/Decisiones/")
  AND !contains(file.path, "/Notas/")
  AND !contains(file.path, "/Worklog/")
  AND length(file.etags) = 0
SORT file.name ASC
```

## Conceptos acumulados

```dataview
TABLE
  length(file.outlinks) AS "Outlinks",
  length(file.inlinks) AS "Inlinks"
FROM "Conceptos"
WHERE !startswith(file.name, "Template")
SORT length(file.inlinks) DESC
```

## Patrones identificados

```dataview
LIST
FROM "Patrones"
WHERE !startswith(file.name, "Template")
SORT file.name ASC
```

## Decisiones (ADRs)

```dataview
TABLE status, date
FROM "Decisiones"
WHERE !startswith(file.name, "Template")
SORT date DESC
```

## Lecciones aprendidas

```dataview
LIST
FROM "Lecciones"
WHERE !startswith(file.name, "Template")
SORT file.name ASC
```

## Nodos huerfanos (sin enlaces entrantes)

```dataview
LIST
FROM ""
WHERE !file.inlinks AND !startswith(file.name, "Template") AND length(file.folder) > 0
LIMIT 20
```

## Ultimas notas tocadas
```dataview
TABLE file.mtime AS "Modificado"
FROM ""
WHERE !startswith(file.name, "Template") AND length(file.folder) > 0
SORT file.mtime DESC
LIMIT 10
```

## Frecuencia de uso (plugin automas)
> Registrado por `_Config/.opencode/plugins/automas.ts` → `_Config/.opencode/data/uso.json`. Se actualiza con cada lectura/escritura de notas. Si está vacío: no hay actividad registrada todavía.

```dataviewjs
const data = await dv.io.load("_Config/.opencode/data/uso.json")
if (!data) { dv.paragraph("Sin datos de uso todavía."); return }
let o = data
try { o = JSON.parse(data) } catch (e) {}
const entries = Object.entries(o).filter(([k]) => !k.startsWith("_"))
entries.sort((a, b) => ((b[1].writes||0)+(b[1].reads||0)) - ((a[1].writes||0)+(a[1].reads||0)))
const top = entries.slice(0, 15)
dv.list(top.map(([p, v]) => `${p} — ${(v.writes||0)}W / ${(v.reads||0)}R`))
const byDay = o._byDay || {}
const days = Object.entries(byDay).sort((a,b) => a[0] < b[0] ? 1 : -1).slice(0,14).reverse()
if (days.length) { dv.header(3, "Actividad por día"); dv.list(days.map(([d, n]) => `${d}: ${n}`)) }
```

## Captura pendiente (_Inbox por procesar)
```dataview
LIST
FROM "_Inbox"
WHERE length(file.name) > 0
SORT file.mtime ASC
```

## Salida (_Outbox)
```dataview
LIST
FROM "_Outbox"
WHERE !startswith(file.name, "README")
SORT file.mtime DESC
```
