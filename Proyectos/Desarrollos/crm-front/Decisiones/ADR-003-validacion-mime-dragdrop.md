---
type: decision
status: aceptada
accepted: 2026-07-27
updated: 2026-08-14
supersedes:
tags: [decision, crm-front, dragdrop, upload, validacion]
---
# ADR-003: Validación de tipo MIME en componentes DragDrop

> Reconstruido en 2026-08-14 desde la implementación vigente en `crm-front/src/components/DragDrop/` (el archivo original fue eliminado del repo junto con la documentación en el commit `4d3b90e`). Referenciado en el README del proyecto.

## Estado

Aceptada · 2026-07-27 por el equipo CRM (reconstruida).

## Contexto

Los componentes de subida de archivos (`DragDrop`) permitían seleccionar cualquier archivo mediante drag & drop o el `<input type="file">`, sin verificar el tipo real del archivo más allá del atributo `accept` del input (que solo actúa como sugerencia de diálogo y no bloquea la subida). Esto permitía adjuntar archivos no soportados (ejecutables, archivos de texto, etc.) que luego el backend rechazaba o que rompían la preview y la subida a S3.

Se necesitaba una **validación programática del tipo MIME** en el cliente, ejecutada para archivos sueltos y para archivos arrastrados.

## Opciones consideradas

1. **Validar solo el `accept` del input** — simple pero no bloquea el drag & drop y no cubre la selección manual forzada (cambiar el filtro del diálogo).
2. **Validación programática de `file.type` contra una lista de MIME permitidos** — se valida en `handleFiles` (punto común para drop y selección), mostrando un `toast` de error y descartando el archivo.

## Decisión

Se implementó la **validación programática de MIME** en el punto común de entrada de archivos:

- `src/components/DragDrop/DragDrop.jsx` (líneas 90-97): constante `allowedMimes = ['image/jpeg', 'image/png', 'application/pdf', 'image/svg+xml', 'image/webp']` y por cada archivo se verifica `allowedMimes.includes(file.type)`; si no, `toast.error('Tipo de archivo no permitido...')` y se aborta.
- `src/components/DragDrop/DragDropAlternative.jsx` (línea 27): la misma verificación en su flujo de subida.
- Se mantiene el `accept` del input como mejora de UX y la validación previa de dimensiones de imagen (`validateImageDimensions`) cuando `validateDimension` está activo.

## Consecuencias

- **Positivas**: los archivos no permitidos se descartan antes de llegar al backend; mensaje claro al usuario.
- **Trade-offs**: la validación se basa en el MIME reportado por el navegador (`file.type`), que puede ser vacío para algunas extensiones; no es una validación de contenido (magic bytes) — para eso el backend valida el `mimetype` con `multer` (misma lista en `crm-back/src/routes/admin.routes.js` y `client.routes.js`).
- **Follow-ups**: si aparecen extensiones nuevas, hay que mantener sincronizada la lista de `DragDrop` con la de `multer` del backend.

## Proyectos que la aplican

- [[Proyectos/Desarrollos/crm-front]]

## Historial de status

- 2026-07-27 — aceptada (implementada en `DragDrop.jsx` y `DragDropAlternative.jsx`).
- 2026-08-14 — reconstruida como nota durable en el vault (el archivo del repo fue eliminado).

## Relacionado

- [[Proyectos/Desarrollos/crm-back]] (validación MIME equivalente en `multer`)