---
name: nuevo-proyecto-base
description: Use when the user wants to create a new BASE project / scaffold a backend and frontend service with all the basic rules baked in, no interview. Triggers: "crear proyecto", "nuevo proyecto base", "nuevo backend", "nuevo frontend", "scaffold", "armar backend", "empezar un proyecto", "proyecto base". Scaffolds a full-stack base (backend + frontend SPA) following the vault rules (Arranque Backend, Convenciones Backend, Arranque Frontend, Autenticacion, Componentes UI, Documentacion, Changelog, Repositorio) with auth and UI building blocks from the start.
---

# Nuevo Proyecto — Modo BASE (Scaffold full-stack)

Crea un proyecto **base** nuevo: servicio de backend + frontend SPA, con **todo lo básico que dictan
las reglas** del portafolio ya incluido. No inventar estructura: leer y aplicar las reglas canónicas.

> Para proyectos donde hay que **definir el producto primero** (encuesta, spec), usá la skill
> **`nuevo-proyecto-gestionado`**. Esta skill es el *scaffold base sin encuesta* (default).

## Paso 0 — Elegir modo

Si el usuario quiere que su **idea quede definida antes de construir** (encuesta + spec + ADRs),
delegá en `nuevo-proyecto-gestionado`. Si solo quiere el base listo para construir, seguí acá.

## Paso 1 — Cargar las reglas (fuente de la verdad)

Leé estas notas del brain antes de escribir código:

- `Reglas/Backend/Arranque Backend.md` — stack, estructura, scripts, banner y arranque.
- `Reglas/Backend/Convenciones Backend.md` — config/env única + validación, errores uniformes, secretos.
- `Reglas/Frontend/Arranque Frontend.md` — stack/estructura SPA.
- `Reglas/Frontend/Autenticacion.md` — paquete de auth completo obligatorio.
- `Reglas/Frontend/Componentes UI.md` — bloques UI transversales obligatorios.
- `Reglas/Comunes/Documentacion.md`, `Repositorio.md`, `README Proyecto.md`, `Changelog.md`.
- `Decisiones/ADR-002 Preferencias de stack.md`.

## Paso 2 — Confirmar con el usuario

Antes de scaffoldear, confirmá:
- Nombre del proyecto y dominio (qué hace).
- ¿Stack por defecto (Express + Drizzle + Biome + Vite React + Zustand) u otro?
- ¿SQLite (prototipo/dev) o PostgreSQL (producción)?
- ¿Auth **incluida**? (Por defecto el base trae auth completa de `[[Reglas/Frontend/Autenticacion]]`.)
- ¿Frontend SPA **incluido**? (Por defecto el base es full-stack. Solo-backend es excepción.)
- ¿Monorepo o repos separados? (default: **repos separados**, ver `[[Reglas/Comunes/Repositorio]]`.)

## Paso 3 — Scaffold: Backend

Estructura base del servicio backend (`<proyecto>-api/`):

```
<proyecto>-api/
├── package.json          # scripts: dev (tsx watch), start, lint/format/check (Biome), db:*
├── biome.json            # linter + formatter (NUNCA ESLint/Prettier)
├── tsconfig.json         # strict, ESM, moduleResolution bundler
├── .env.example          # PORT, HOST, NODE_ENV, DATABASE_URL, JWT_SECRET, CLIENT_URL
├── .gitignore
└── src/
    ├── app.ts            # Express: cors, json, rutas, errorHandler central
    ├── server.ts         # arranque CON el banner canónico (sanitizado)
    ├── routes/           # definición de rutas
    ├── modules/
    │   ├── auth/{routes,controller,service}.ts   # JWT + bcrypt
    │   └── health/{routes,controller,service}.ts # GET /health (liveness) + /healthz (readiness)
    ├── config/           # config única + validación fail-fast (Zod)
    ├── middleware/       # auth (JWT), errorHandler
    ├── utils/
    └── db/               # conexión Drizzle + migraciones
```

Cumplir el backend:
- **Auth completa**: `POST /auth/login`, `POST /auth/register`, `POST /auth/refresh`,
  `POST /auth/forgot`, `POST /auth/reset`, `GET/POST /auth/verify-email`, `POST /auth/logout`,
  `POST /auth/change-password`, `GET/POST /auth/google` (contrato de `[[Reglas/Frontend/Autenticacion]]`).
- **Health**: `GET /health` (liveness) + `GET /healthz` (readiness: ping a la BD). Los consume el deploy.
- **Config única** en `config/` con validación al arranque (fail-fast); prohibido `process.env` disperso.
- **Errores uniformes**: `{ error: "<mensaje>" }` con status correcto; error handler central, sin
  `try/catch` respondiendo en el controller.
- **Banner** canónico dentro de `app.listen()`, con `DATABASE_URL` **sanitizada** y `process.exit(1)`
  si la BD está offline.

## Paso 3b — Scaffold: Frontend

Estructura base del SPA (`<proyecto>-web/`):

```
<proyecto>-web/
├── package.json
├── biome.json
├── tsconfig.json
├── index.html
├── vite.config.ts
├── .env.example          # VITE_API_URL=http://localhost:3000/api
├── .gitignore
└── src/
    ├── main.tsx          # punto de entrada React
    ├── App.tsx           # rutas con guardas (private/public)
    ├── pages/
    │   ├── login/        # login con toggle mostrar/ocultar pass
    │   ├── register/
    │   ├── recover/      # solicitar + reset con token
    │   ├── verify-email/
    │   ├── change-password/
    │   └── <dominio>/
    ├── components/       # by feature/subcarpeta (+ blocos de UI transversales)
    ├── hooks/
    ├── api/
    │   └── auth.js       # cliente HTTP de auth centralizado
    ├── store/
    │   └── auth.js       # store de sesión (Zustand)
    └── styles/           # design tokens + tema claro/oscuro
```

Cumplir el frontend:
- **Auth completa** de `[[Reglas/Frontend/Autenticacion]]`: login con toggle de contraseña, registro,
  recordarme, recuperación (solicitar + reset con token), verificación de email, login con Google,
  logout, cambio de contraseña. **Guardas de ruta** en `App.tsx`.
- **Componentes UI** de `[[Reglas/Frontend/Componentes UI]]`: toast global, estados de vista
  (loading/empty/error+retry), paginación o scroll infinito con estado en URL, design tokens + tema
  claro/oscuro, formateo de locales con `Intl`.
- Sin lógica de negocio: consume la API (`api/auth.js`), no acceso directo a BD ni tokens de OAuth.

## Paso 4 — .vscode/tasks.json

Siempre crear `.vscode/tasks.json` con un task por servicio (separado, en su propio terminal,
`isBackground: true`) y un task "todos juntos" que lance todos los servicios cada uno en su terminal
(`dependsOn` + `presentation.panel: dedicated`). Seguir `[[Reglas/Comunes/Arranque VSCode]]`.

## Paso 5 — Repo por servicio

Cada **servicio** scaffolded se crea en **su propio repo git** con su `.gitignore`, salvo monorepo
(entonces un solo repo raíz y cada servicio conserva su `CHANGELOG.md` + `README.md` individual).
Default: **repos separados**. Seguir `[[Reglas/Comunes/Repositorio]]`.

## Paso 6 — Verificar

1. `npm install` en cada servicio.
2. `npm run check` (Biome) sin errores.
3. `npm run dev` en backend y confirmar el banner en consola; frontend levanta la SPA.

## Paso 7 — Documentación desde el arranque

Según `[[Reglas/Comunes/Documentacion]]`, en el proyecto:
- `CHANGELOG.md` — sección `## [0.1.0]` con entradas `Added` (setup backend / frontend / auth / UI),
  formato exacto de `[[Reglas/Comunes/Changelog]]`.
- `README.md` — plantilla de `[[Reglas/Comunes/README Proyecto]]` (`Qué hace`, `Stack`, `Arquitectura`,
  `Requisitos`, `Setup`, `Scripts`, `Servicios y puertos`, `Endpoints`, `Documentación`, `Licencia`).
  Sin emojis en títulos.
- `AGENTS.md` — estructura y convenciones para futuros agentes.

## Paso 8 — Registrar en el brain

Crear la ficha y el registro del proyecto **dentro de su carpeta** `Proyectos/<Nombre>/`:
- Ficha `Proyectos/<Nombre>/<Nombre>.md` (vía `generar-ficha.ps1`/scrape) + enlaces al grafo.
- `Proyectos/<Nombre>/Worklog/YYYY-MM-DD.md` — historial del día (append-only).
- `Proyectos/<Nombre>/Decisiones/` — ADRs propios del proyecto cuando haya decisiones.
- Enlazar las reglas `[[Reglas/Backend/Arranque Backend]]`, `[[Reglas/Backend/Convenciones Backend]]`,
  `[[Reglas/Frontend/Arranque Frontend]]`, `[[Reglas/Frontend/Autenticacion]]`,
  `[[Reglas/Frontend/Componentes UI]]`, `[[Reglas/Comunes/Documentacion]]` y el patrón
  `[[Patrones/arranque-backend-banner]]`.

## Relacionado

- `nuevo-proyecto-gestionado` — la variante con encuesta + spec + ADRs + construcción de features.
- `scrape-proyecto` — genera/actualiza la ficha con conexiones al grafo.