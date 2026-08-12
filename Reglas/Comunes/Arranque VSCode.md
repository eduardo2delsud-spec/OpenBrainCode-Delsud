<!-- @regla arranque-vscode -->
---
type: regla
category: tooling
area: arranque
updated: 2026-08-08
tags: [regla, vscode, tasks, dev, arranque, tooling]
---

# Arranque VSCode — Regla del Vault

> Regla para **cualquier proyecto nuevo**: cada scaffold DEBE incluir la carpeta `.vscode/` con un
> `tasks.json` que permita levantar los servicios. Responde "cómo se corren los servicios de un
> proyecto desde VSCode". Complementa [[Reglas/Backend/Arranque Backend]] y [[Reglas/Frontend/Arranque Frontend]].

## Regla

Todo proyecto nuevo (o re-alineado) debe crear `.vscode/tasks.json` con:

1. **Un task por servicio** (separado), cada uno corriendo en su **propio terminal** (`panel: dedicated`).
2. **Un task "todos juntos"** que lanza todos los servicios en simultáneo, **pero cada uno en una
   terminal dedicada** (vía `dependsOn` + `presentation.panel` por task). NO un solo terminal con `&`.

Los tasks por servicio deben marcar `isBackground: true` y `problemMatcher: []` para que VSCode los
deje corriendo en segundo plano al agruparse.

## Estructura mínima (`tasks.json`)

```json
{
  "$schema": "https://go.microsoft.com/fwlink/?LinkId=733558",
  "version": "2.0.0",
  "tasks": [
    {
      "label": "<servicio>: dev",
      "type": "shell",
      "command": "pnpm --filter <servicio> dev",
      "isBackground": true,
      "problemMatcher": [],
      "presentation": {
        "group": "<proyecto>",
        "panel": "dedicated",
        "reveal": "always"
      }
    },
    {
      "label": "<Proyecto>: todos los servicios",
      "dependsOn": ["<servicio-1>: dev", "<servicio-2>: dev", "<servicio-3>: dev"],
      "problemMatcher": []
    }
  ]
}
```

### Notas

- Cada servicio de la tabla "Servicios y puertos" del README tiene su task propio.
- El task "todos juntos" usa `dependsOn`; con `panel: dedicated` cada servicio gana su terminal.
- Los `label` usan kebab-case del package (p.ej. `api`, `admin-web`, `diario-web`).
- No inventar lógica de arranque: el task solo invoca el script `dev` del package.

## Cómo se aplica

opencode lo aplica vía la skill **`nuevo-proyecto-base`** (Paso 3 — Scaffoldear: crea `.vscode/tasks.json`
en el gesto de scaffold). Al alinear un proyecto existente, crearlo a mano siguiendo esta regla.

## Relacionado

- [[Reglas/Backend/Arranque Backend]] — scripts `dev` backend.
- [[Reglas/Frontend/Arranque Frontend]] — scripts `dev` frontend.
- [[Reglas/Comunes/Documentacion]] — qué documentación es obligatoria.