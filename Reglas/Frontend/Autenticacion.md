<!-- @regla frontend-autenticacion -->
---
type: regla
category: frontend
area: autenticacion
updated: 2026-08-09
tags: [regla, frontend, auth, login, registro, sesion, oauth, react, vite]
---

# Autenticación Frontend — Regla del Vault

> Regla para **cualquier frontend con autenticación**. Complementa [[Reglas/Frontend/Arranque Frontend]].
> La contraparte de API vive en el backend: acá solo se definen las pantallas y comportamientos que el
> SPA es responsable de proveer.

## Regla de oro

> **Si hay login, hay el paquete completo.** No se entrega un login a medias: si el frontend incorpora
> autenticación, debe cubrir al menos las pantallas y flujos de abajo.

## Pantallas y flujos obligatorios

Cuando exista autenticación, el SPA debe ofrecer:

1. **Login** con email + contraseña, con **toggle mostrar/ocultar contraseña**.
2. **Registro** — si hay login, hay register (mismo formulario accesible y completo).
3. **"Recordarme"** — que distingua sesión persistente (recuerda al usuario) de sesión de navegador.
4. **Recuperación de cuenta** "¿Olvidaste tu contraseña?":
   - pantalla de **solicitud** (envía el mail de recuperación);
   - página de **restablecer contraseña** con token + vencimiento.
5. **Verificación de email** — tras el registro, flujo para confirmar la cuenta.
6. **Login con Google** (botón + callback). *Nota general:* cualquier OAuth se implementa en el backend;
   en el frontend solo botón de inicio y manejo del callback.
7. **Cerrar sesión** — logout seguro que limpia token y sesión local.
8. **Cambiar contraseña** — formulario disponible estando logueado.

## Comportamiento transversal

- **Guardas de ruta**: las rutas privadas se protegen; si no hay sesión se redirige al login.
- **Manejo de sesión/token**: el SPA maneja refresh y expiración del token (renovación transparente).
- **Estados loading/error**: en todos los formularios de auth — submit deshabilitado mientras carga,
  errores del backend mapeados a mensajes legibles y mostrados inline.

## Reglas de frontend

1. El frontend **no** contiene lógica de negocio ni de auth fuera del flujo UI: consume la API `Auth`
   del backend (`api/auth.js`), sin acceso directo a BD ni tokens de OAuth.
2. Sesión en un store de Zustand por dominio (`store/auth`).
3. Los errores de la API se traducen a mensajes claros para el usuario.

## API esperada en el backend

Contrato mínimo que el SPA consume bajo `/auth/*`:

| Endpoint | Uso |
|----------|-----|
| `POST /auth/login` | iniciar sesión |
| `POST /auth/register` | crear cuenta |
| `POST /auth/refresh` | renovar token |
| `POST /auth/forgot` | solicitar recuperación |
| `POST /auth/reset` | restablecer contraseña (token) |
| `GET/POST /auth/verify-email` | confirmar email |
| `POST /auth/logout` | cerrar sesión |
| `POST /auth/change-password` | cambiar contraseña estando logueado |
| `GET/POST /auth/google` | login con Google |

## Siguiente nivel

- [[Reglas/Backend/Convenciones Backend]] — errores uniformes y contrato de la API de auth.
- [[Reglas/Backend/Arranque Backend]] — la contraparte de servidor.

## Origen

- [[Reglas/Frontend/Arranque Frontend]] — stack y estructura SPA canónica.
- [[Reglas/Backend/Convenciones Backend]] — regla normativa del backend (config/env, errores, secretos).