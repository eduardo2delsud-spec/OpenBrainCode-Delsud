<!-- @regla arranque-frontend -->
---
type: regla
category: frontend
area: arranque
updated: 2026-08-06
tags: [regla, frontend, react, vite, arranque, stack, scaffold]
---

# Arranque Frontend — Regla del Vault

> Regla para **nuevas SPAs de frontend**. Espejo de [[Reglas/Backend/Arranque Backend]]. Establece el stack,
> la estructura de carpetas y las reglas de un frontend del portafolio.

## Stack canónico

- **Runtime:** Node.js + TypeScript **strict** (ESM).
- **Build:** Vite (React SPA).
- **Estado:** Zustand.
- **Data fetching:** TanStack Query (a criterio del proyecto).
- **Estilos:** CSS Modules o Tailwind (a criterio del proyecto; consistencia dentro del repo).
- **Calidad:** Biome (lint + format + check). **Nada de ESLint/Prettier**.

## Estructura SPA canónica

```
<proyecto>-web/
├── package.json
├── biome.json
├── tsconfig.json
├── index.html
├── vite.config.ts
├── .env.example
├── .gitignore
└── src/
    ├── main.tsx            # punto de entrada React (monta <App />)
    ├── App.tsx             # raíz con rutas
    ├── pages/              # una carpeta/archivo por página/ruta
    ├── components/         # componentes reutilizables (por feature/subcarpeta)
    ├── hooks/              # hooks por feature
    ├── api/                # cliente HTTP por feature
    ├── store/              # stores de Zustand (por dominio)
    └── styles/             # estilos globales/CSS Modules
```

## Reglas del frontend

1. El frontend **consume una API REST**; NUNCA contiene lógica de negocio ni acceso directo a la BD.
2. Variables de entorno públicas con prefijo `VITE_`.
3. `.env.example` documenta las variables; `.env` real no se commitea.
4. Cliente HTTP por feature (`api/<feature>.js`) que centraliza las llamadas; los hooks consumen eso.
5. `CLIENT_URL` en el backend debe permitir el origen del SPA para CORS.

## Scripts npm base

```json
{
  "dev": "vite",
  "build": "vite build",
  "preview": "vite preview",
  "lint": "biome lint .",
  "format": "biome format --write .",
  "check": "biome check --write .",
  "typecheck": "tsc --noEmit"
}
```

## .env.example base

```
VITE_API_URL=http://localhost:3000/api
```

## Siguiente nivel

- Patrón `frontend-por-feature` — `lib/api-client` + features/services/hooks/barrels (a crear cuando emerja del portafolio).
- [[Reglas/Frontend/Autenticacion]] — paquete de auth completo.
- [[Reglas/Frontend/Componentes UI]] — bloques UI transversales (toast, estados, paginación, tokens, locales).

## Origen

- [[Reglas/Backend/Arranque Backend]] — la contraparte de servidor.
- [[Reglas/Comunes/Documentacion]] — documentación obligatoria del proyecto.
- ADR de stack — decisiones de stack registradas en `Decisiones/`.

## Uso

opencode lo aplica vía la skill **`nuevo-proyecto-base`** para scaffoldear frontends (full-stack).