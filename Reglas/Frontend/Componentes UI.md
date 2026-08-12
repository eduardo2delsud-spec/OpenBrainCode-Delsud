<!-- @regla frontend-componentes-ui -->
---
type: regla
category: frontend
area: componentes-ui
updated: 2026-08-10
tags: [regla, frontend, ui, componentes, toast, paginacion, design-tokens, tema, formateo, info, changelog, manual, react, vite]
---

# Componentes UI Transversales — Regla del Vault

> Regla para **todo frontend** del portafolio. Define los bloques de UI que un SPA trae **siempre**,
> sin implementarlos ad-hoc por página. Complementa [[Reglas/Frontend/Arranque Frontend]] y
> [[Reglas/Frontend/Autenticacion]].

## Regla de oro

> **Todo SPA incluye estos bloques UI transversales.** No se reinventan ni se deja una página sin ellos:
> vienen en cada scaffold y se reutilizan.

## 1. Toast / notificaciones

- Sistema de notificaciones **global** (stack gestionado desde el store/contexto de UI).
- Variantes: `success`, `error`, `info`, `warning`.
- Auto-dismiss con duración configurable; **transition de salida** (no desaparecer a lo brusco).
- **Accesible**: roles `status`/`alert` y `aria-live`; focus no bloqueado.
- Errores de la API disparan toast por defecto (ver regla de [[Reglas/Frontend/Autenticacion]]).

## 2. Estados de vista

Toda página que carga datos cubre los cuatro estados:

1. **Loading** — skeleton/esqueletos (no spinners genéricos cuando la forma del contenido es conocida).
2. **Contenido** — la vista real.
3. **Empty state** — mensaje + acción orientativa cuando no hay datos.
4. **Error con retry** — mensaje claro y botón de reintentar (no dejar la vista en blanco).

## 3. Paginación / scroll

- Listados multi-página: **paginación** (`< 1 2 3 >`) o **scroll infinito** consistente.
- Scroll infinito solo cuando el backend soporte offset/contador; si no, paginación.
- El estado de la página se **sincroniza a la URL** (query param), para que sea compartible/recargable.

## 4. Design tokens + tema

- **Tokens base** (color, spacing, typography, radius, shadow) como única fuente de verdad del diseño.
- **Tema claro/oscuro** soportado (por token, no por hardcodeo).
- **Prohibido** colores/valores hardcodeados fuera de los tokens.

## 5. Formateo de locales

- Helper/context central para **fechas, moneda y números** usando la API `Intl` del navegador.
- Nada de formato manual repetido entre componentes.

## 6. Icono de información "i" — changelog + manual de uso

**Todo sistema tiene que tener un icono de información ("i")** accesible desde la barra superior que
contenga:
1. **Changelog** — historial de versiones con fechas y qué cambió en cada una.
2. **Manual de uso** — qué hace el sistema y cómo se usa (pantallas, acciones, casos de uso).

Reglas del bloque:
- El icono "i" vive en la **barra superior** (topbar), junto a los controles globales.
- Al abrirlo muestra un **modal** accesible: cierre con `Escape`, clic en ×/backdrop, focus manejado.
- Contenido estático vive en un módulo de datos (ej. `info.ts`: `APP_VERSION`, `CHANGELOG`, `MANUAL`),
  no hardcodeado en el componente; el modal solo presenta.
- Referencia de implementación: un SPA con `InfoModal` / página Ayuda — separa *datos* de *presentación*.
- El changelog se mantiene en línea con [[Reglas/Comunes/Changelog]].

## Reglas de frontend

1. Los bloques se implementan **una vez** (componente + store/contexto) y se reutilizan.
2. El sistema de toast puede consumir el resultado de las llamadas de la API (`api/*.js`).
3. Consistencia con los design tokens; la skill base de UI cubre a11y y diseño.

## Siguiente nivel

- La skill **`frontend-ui-engineering`** es el respaldo de implementación (a11y, design systems, Core Web Vitals).
- [[Reglas/Frontend/Autenticacion]] — estados de carga/error ya obligatorios, ahora respaldados acá.

## Origen

- [[Reglas/Frontend/Arranque Frontend]] — stack y estructura SPA canónica.
- [[Reglas/Comunes/Documentacion]] — documentación obligatoria del proyecto.