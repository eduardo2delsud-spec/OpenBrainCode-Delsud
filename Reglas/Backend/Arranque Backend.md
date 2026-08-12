<!-- @regla arranque-backend -->
---
type: regla
category: backend
area: arranque
updated: 2026-08-06
tags: [regla, backend, arranque, banner, stack, scaffold]
---

# Arranque Backend — Regla del Vault

> Regla para **nuevos proyectos de backend**. Establece el stack, la estructura de carpetas,
> los scripts y el arranque canónico (con banner). Responde: "cómo arranca un servidor de este
> portafolio". Debe cumplirse ESTE formato al crear o mantener un backend.

## Stack canónico

Según la preferencia de stack del vault (ADR de stack):

- **Runtime:** Node.js + TypeScript **strict**, ESM (`"type": "module"`).
- **Framework:** Express en capas (`routes → controllers → services`); replicar convenciones por dominio.
- **ORM:** Drizzle ORM — SQLite (`better-sqlite3`) en dev/prototipos, PostgreSQL en producción.
- **Calidad:** Biome (lint + format + check). **Nada de ESLint/Prettier**.
- **Autenticación:** JWT + bcrypt.
- **Config:** variables de entorno con `dotenv`; nunca secrets en el repo.

## Estructura de carpetas mínima

```
<proyecto>/
├── package.json
├── biome.json
├── .env.example
├── .gitignore
└── src/
    ├── app.ts              # construye la app Express (rutas, middleware, CORS)
    ├── server.ts           # punto de entrada: arranca el servidor CON el banner (ver abajo)
    ├── routes/             # definición de rutas por recurso
    ├── modules/<dominio>/  # cada dominio: routes.ts, controller.ts, service.ts
    ├── config/             # lectura de env (PORT, HOST, DATABASE_URL, JWT_SECRET...)
    ├── middleware/         # auth, errorHandler, etc.
    ├── utils/
    └── db/                 # conexión y migraciones (Drizzle)
```

## El arranque (banner)

`server.ts` debe ejecutar esta secuencia:

1. Cargar `dotenv`.
2. Armar `app` (desde `app.ts`).
3. **Chequear la conexión a la BD**:
   - Si está **offline** → `console.error("🚨 El servidor no puede iniciar. Base de datos offline.")` y `process.exit(1)`.
4. `app.listen(PORT, ...)` y mostrar el banner "00":

```
==================================================
🚀 SERVIDOR INICIADO EXITOSAMENTE
==================================================
📍 URL Local:       http://HOST:PORT
📅 Fecha:           <new Date().toLocaleString()>
🏭 Entorno:         <NODE_ENV || "development">
🗄️  Base de Datos:   <DATABASE_URL sanitizada>
🌐 Cliente CORS:    <CLIENT_URL || "Todos">
📦 Node Version:    <process.version>
==================================================
```

### Reglas de arranque

1. **NUNCA loguear secretos.** Si mostrás `DATABASE_URL`, sanitizala: reemplazá la password
   con `**` (ej. `/\/\/([^:]+):([^@]+)@/` → `//***:***@`).
2. **Fail fast:** si la BD está offline, cortar el arranque (`process.exit(1)`), no arrancar "a medias".
3. `HOST` y `PORT` vienen de env (`PORT` default 3000, `HOST` default `localhost`).
4. El banner va **dentro** de `app.listen()`, no antes.
5. En JS/TS se usa `console.log`/`console.error` para el arranque; el logging de requests lo hace
   middleware (Morgan/pino).

## Scripts npm base

```json
{
  "dev": "tsx watch src/server.ts",
  "start": "tsc -p tsconfig.json && node dist/server.js",
  "lint": "biome lint .",
  "format": "biome format --write .",
  "check": "biome check --write .",
  "db:generate": "drizzle-kit generate",
  "db:push": "drizzle-kit push",
  "db:studio": "drizzle-kit studio"
}
```

## .env.example base

```
PORT=3000
HOST=localhost
NODE_ENV=development
DATABASE_URL=
JWT_SECRET=change-me
CLIENT_URL=http://localhost:5173
```

## Siguiente nivel

- [[Reglas/Backend/Convenciones Backend]] — regla normativa: config/env única, errores uniformes, secretos.
- Patrones `api-http`, `autenticacion-jwt-roles`, `base-datos-pool-y-migraciones` — cómo implementar (a crear cuando emerjan del portafolio).

## Origen

- Patrón `arranque-backend-banner` — el banner como patrón del grafo.
- ADR de stack — decisiones de stack registradas en `Decisiones/`.

## Uso

opencode lo aplica vía la skill **`nuevo-proyecto-base`** (`/nuevo-proyecto-base`) para scaffoldear backends.