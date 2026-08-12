	<!-- @outbox -->
---
type: index
folder: _outbox
updated: YYYY-MM-DD
tags: [meta, outbox, salida]
---

# _Outbox — La memoria se exprime

> Un segundo cerebro que solo **almacena** no es un segundo cerebro. Esta carpeta existe para cuando el conocimiento **produce algo**: un post, un tutorial, una decisión aplicada, un resumen, un artefacto.

No es una carpeta del grafo de conceptos: es la **zona de salida / output**. Nace del método **CODE** (Captura · Organiza · **Destila** · **Expresa**): lo que acá vive ya está destilado y listo para usarse.

## Cuándo crear una nota acá

- Escribiste un post / tweet / thread basado en tu conocimiento → guardá el borrador o el link.
- Aplicaste una decisión en un proyecto y querés el registro de "cómo se materializó".
- Hiciste un tutorial / guía que resume varias lecciones → referencia enlazad al grafo.

## Formato

```markdown
---
type: output
tema: <tema>
source: <url o nota base>
updated: YYYY-MM-DD
tags: [output, <tema>]
---
# <Título del output>
## Qué produce
## Clave del grafo a la que responde
[[Conceptos/...]] [[Lecciones/...]] [[Proyectos/.../...]]
## Resultado / enlace
```

## Reglas

- **No** volcar acá capturas sin procesar (eso va a `_Inbox`).
- **Sí** enlazar hacia el grafo: un output sin raíces es una nota flotante más.
- El propósito es tu **salida** como desarrollador, no un segundo almacén de notas.