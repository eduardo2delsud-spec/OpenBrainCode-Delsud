---
type: decision
status: aceptada
accepted: 2026-07-20
updated: 2026-08-14
supersedes:
tags: [decision, crm-front, redux, ficha, stale-data]
---
# ADR-004: Reseteo del estado Redux `fichaData` entre navegaciones de reservas

> Reconstruido en 2026-08-14 desde la implementación vigente en `crm-front` (el archivo original fue eliminado del repo junto con la documentación en el commit `4d3b90e`). Referenciado en el README del proyecto.

## Estado

Aceptada · 2026-07-20 por el equipo CRM (reconstruida).

## Contexto

La página `Ficha` (`/reserva/:id`) cargaba los datos de una reserva en el slice Redux `fichaData` (`GET_DATA_LOT`). Al navegar de una reserva a otra sin desmontar la página (o al volver), el estado quedaba con los datos de la reserva **anterior**, mostrando información stale: campos de la reserva vieja, botones y PDFs de la reserva equivocada, y al guardar se podían pisar datos con los de otra reserva.

El problema típico de estado global compartido: el slice persiste entre montajes de la misma ruta y no se limpiaba al salir.

## Opciones consideradas

1. **No limpiar y recargar siempre en el loader** — frágil: el loader dispara `GET_DATA_LOT`, pero entre el montaje y la respuesta el estado viejo se seguía mostrando, y no cubría navegaciones donde el loader no se re-ejecuta (misma ruta, distintos params).
2. **Reseteo explícito al desmontar + acción de reseteo en el reducer** — el componente limpia el estado con `useEffect` de cleanup al desmontar (`resetFichaData()`), y el reducer tiene un caso `RESET_FICHA_DATA` que devuelve `initialState`.

## Decisión

Se implementó la combinación de **cleanup al desmontar + reseteo en reducer**:

- `src/redux/actions/user/booking.js`: nueva acción constante `RESET_FICHA_DATA` y action creator `resetFichaData()`.
- `src/redux/reducers/user/ficha.js`: caso `RESET_FICHA_DATA` que retorna `initialState` (`{ data: {}, loading: false }`).
- `src/pages/Ficha.jsx` (líneas 88-93): `useEffect(() => () => dispatch(resetFichaData()), [dispatch])` — al desmontar la página se limpia el slice para que la próxima reserva arranque limpia.

## Consecuencias

- **Positivas**: al entrar a cualquier reserva el estado arranca vacío; sin datos stale entre reservas distintas.
- **Trade-offs**: se pierde el estado al salir (hay que recargar al volver); el `loading` se controla con `CHANGE_LOADER_FICHA`, que también limpia `data` y marca `loading: true`, cubriendo la transición.
- **Follow-ups**: mantener el patrón en cualquier página nueva que consuma estado global de un detalle (aplicar cleanup en el desmontaje).

## Proyectos que la aplican

- [[Proyectos/Desarrollos/crm-front]]

## Historial de status

- 2026-07-20 — aceptada (implementada en `Ficha.jsx`, `redux/actions/user/booking.js` y `redux/reducers/user/ficha.js`).
- 2026-08-14 — reconstruida como nota durable en el vault (el archivo del repo fue eliminado).

## Relacionado

- [[Proyectos/Desarrollos/crm-front]] (ver `docs/data-layer.md` → slice `fichaData`)