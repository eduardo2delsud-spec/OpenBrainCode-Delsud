---
name: web-clipper
description: Use when the user wants to save web content, articles, docs, tutorials, or references into the brain. Triggers: "guardá esto", "clippeo", "captura", "guardá la URL", "guarda este artículo", "referencia", "guardar doc", "web", "link". Saves content into _Inbox or the right folder with frontmatter and connections.
---

# Web Clipper del Cerebro

Captura contenido web útil y lo inserta en el knowledge graph sin romper su formato.

## Ruta del vault

El vault es la raíz de este proyecto (donde vive `OpenBrainCode.md`).

## Flujo

### 1. Obtener el contenido

Cuando el usuario pega una URL o texto, leer el contenido:
- Si es una **URL de página web estándar** (artículo, blog, doc online, post) → usar la **CLI `defuddle`** para
  extraer markdown limpio (quita nav/ads y ahorra tokens). Preferirlo sobre `webfetch`.
  ```bash
  defuddle parse "<url>" --md
  # si no está instalado: npm install -g defuddle
  ```
  - No usar `defuddle` para URLs que terminan en `.md` (ya son markdown → usar `webfetch` directo).
  - Si `defuddle` falla o no está disponible, degradar a `webfetch`.
- Si el usuario pegó texto directo → usar ese texto.

### 2. Decidir dónde va

| Tipo de contenido | Carpeta | Tipo de nota |
|-------------------|---------|--------------|
| Doc/tutorial de una tecnología | `Conceptos/` | `type: concepto` |
| Referencia a una técnica de arquitectura | `Patrones/` | `type: patron` |
| Guía práctica / how-to aprendido | `Lecciones/` | `type: leccion` |
| Documentación temporal / por procesar | `_Inbox/` | sin tipo todavía |
| Recurso general (blog, post, curso) | `_Inbox/` | sin tipo |

Regla general: si es una tecnología/stack → `Conceptos/`. Si es una práctica de arquitectura → `Patrones/`. Si es un consejo de rendimiento/tooling aprendido → `Lecciones/`. Si no se puede clasificar bien → `_Inbox/`.

### 3. Crear la nota con frontmatter

```markdown
---
type: <concepto|patron|leccion>
category: <tech|arquitectura|herramienta|practica|referencia>
source: <url original>
updated: <fecha>
tags: [<tags>]
---
# <Título>
> <resumen de 1 línea>

## Fuente
<link a la página o documento>

## Qué es
<explicación a partir del contenido>

## Puntos clave de la fuente
- (los 3-5 puntos más importantes extraídos del contenido)

## Relacionado
[[Conceptos/...]] o [[Patrones/...]] si aplica, o dejarlo vacío
```

### 4. Enlazar (si aplica)

Si el contenido hace una clara conexión con algo que ya existe en el grafo, agregar `[[enlace]]`. No forzar enlaces si el tema es totalmente nuevo y no tiene conexiones.

### 5. Confirmar al usuario

```
Guardado como <carpeta>/<nombre>.md
Fuente: <url>
Tags: <tags>
```

## Reglas

- **No** guardar páginas enteras verbatim — solo la info clave sintetizada + URL para referencia.
- **No** guardar contenido de pago o restringido si no se puede obtener.
- Siempre registrar la `source` (URL) para trazabilidad.
- Si el usuario solo da un nombre sin URL, preguntarle la fuente antes de guardar.

## Respuestas típicas

**"Guardá https://docs.example.com/api"**
→ webfetch → clasificar como referencia de stack → crear en `Conceptos/` con resumen + source.

**"Este tutorial de docker multi-stage" (pega texto)**
→ clasificar como patrón/lección → crear nota con frontmatter `type: leccion`.

**"Guardámelo para después"**
→ crear borrador en `_Inbox/` sin tipo, para procesar luego con `/indexar`.