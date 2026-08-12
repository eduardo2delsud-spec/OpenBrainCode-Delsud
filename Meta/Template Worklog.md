<!-- @meta worklog -->
---
type: worklog
project: <Nombre del proyecto>
date: YYYY-MM-DD
tags: [worklog, changelog]
---

# Worklog — <Proyecto> — YYYY-MM-DD

> Registro **append-only** de lo que pasó. Un archivo por proyecto por día. No se reescribe: se agrega. Al final de la sesión, si algo cambió que sea *cierto*, **promovelo** a la nota durable y actualizá su `updated`.

## Sesiones

### HH:MM — <quién> — inicio
- **Objetivo:**
- **Archivos que pienso tocar:**

### HH:MM — <quién> — fin
- **Hecho:**
- **Bloqueos / decisiones pendientes:**

## Changelog (qué cambió de verdad)

- `HH:MM` — <cambio> — archivos: `ruta/a`, `ruta/b`

## Durable a promover

| Qué cambió | Nota a actualizar |
|------------|-------------------|
| (ej: se migró auth a JWT rotado) | `Proyectos/<X>.md` |

## Bloqueadores / trabas

- (si el bloqueo se resolvió, escribirlo en `Brain/Errores/<kebab-case>.md` y enlazarlo acá)