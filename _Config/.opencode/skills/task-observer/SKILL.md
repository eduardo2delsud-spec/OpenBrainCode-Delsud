---
name: task-observer
description: >
  Observa la ejecuciÃ³n de sesiones de trabajo para detectar oportunidades de mejora
  de skills y metodologÃ­as del vault OpenBrainCode. Se activa durante CUALQUIER tarea
  multi-paso, flujo agÃ©ntico o sesiÃ³n sustancial con herramientas y entregables, y ante
  correcciones del usuario, insights de flujo o discusiÃ³n de metodologÃ­a. Registra los
  hallazgos en Brain/ (la memoria del Segundo Cerebro) bajo el nombre "One Skill to Rule
  Them All".
---

# Task Observer â€” Descubrimiento y mejora continua de skills

AdaptaciÃ³n para el vault **OpenBrainCode** del skill de Eoghan Henn / rebelytics
*"One Skill to Rule Them All"* (CC BY 4.0, [github.com/rebelytics/one-skill-to-rule-them-all](https://github.com/rebelytics/one-skill-to-rule-them-all)).
Los enlaces son referencias para el lector humano; ejecutar este skill nunca requiere
fetch externo. Los registros no dependen de una URL.

**AlineaciÃ³n con el vault:** este skill **automatiza la "regla de oro" del vault** â€” que un
error resuelto / acierto quede **en el MISMO gesto** escrito en `Brain/`. La observaciÃ³n
cruda va al log de `Brain/`, no a la memoria de la conversaciÃ³n.

## Almacenamiento (reconfigurado para el vault)

- **Log de observaciones:** `Brain/Skills/observaciones.md` â€” donde termina la observaciÃ³n
  cruda de cada sesiÃ³n (append-only, al final del archivo).
- **Backlog no revisado / Ãºltima revisiÃ³n:** `Brain/Skills/_meta.md` (contiene
  `lastReview: YYYY-MM-DD` o `never`).
- **Registro durable (promociÃ³n):** cuando una observaciÃ³n es confirmada, el curador lo
  promueve a **`Brain/Errores/<kebab-case>.md`** o **`Brain/Aciertos/<kebab-case>.md`** segÃºn
  corresponda, y si vale como lecciÃ³n general, a **`Lecciones/`** con backlink (no duplicar).
- Las rutas relativas resuelven desde la raÃ­z del vault
  (`<ruta del vault>`); si el cwd es efÃ­mero, anclar sobre la raÃ­z del vault.

## Protocolo de inicio de sesiÃ³n

1. Si `Brain/Skills/observaciones.md` o `Brain/Skills/_meta.md` no existen, crealos
   (`_meta.md` con `lastReview: never` â€” nunca escribas una fecha que no corresponde a una
   revisiÃ³n real). Si el cwd es efÃ­mero, advertÃ­ y re-anclÃ¡ en la raÃ­z del vault.
2. EscaneÃ¡ observaciones OPEN y principios activos; mantenelos en contexto, no los muestres
   espontÃ¡neamente.
3. LeÃ© `lastReview`. Si es `never` o tiene mÃ¡s de 7 dÃ­as Y hay observaciones OPEN: ofrecÃ©
   (una lÃ­nea) correr la revisiÃ³n o seguir con la tarea; **nunca bloquees la tarea del usuario**.
4. Una vez por sesiÃ³n: verificÃ¡ que la regla que activa este skill exista (en `Reglas/Comunes/Ecosistema Skills.md`);
   si no, suggest agregarla.
5. AnotÃ¡ la hora de modificaciÃ³n del log; si cambiÃ³ hace poco, otra sesiÃ³n pudo estar
   escribiendo â€” **re-leÃ© justo antes de cada append**, nunca confÃ­es en un nÃºmero recordado.

## CuÃ¡ndo observar

Activo toda la sesiÃ³n con herramientas: ejecuciÃ³n, feedback post-tarea, revisiÃ³n y discusiÃ³n
de metodologÃ­a. Inactivo solo para conversaciÃ³n casual y preguntas factuales rÃ¡pidas.

## QuÃ© vigilar

- **NUEVA skill:** workflow multi-paso reutilizable; una metodologÃ­a que explica el usuario y
  no captura ninguna skill; tipo de tarea recurrente con estructura similar.
- **MEJORAR skill existente:** el agente viola una regla documentada (necesita enforcement,
  no reglas mÃ¡s fuertes); una correcciÃ³n del usuario revela una regla/edge case faltante;
  surge un mejor workflow que el recomendado; una tÃ©cnica funciona bien y merece promoverse;
  un supuesto errado; tooling nuevo vuelve obsoleto un paso; feedback que generaliza.
- **SIMPLIFICAR skill:** secciÃ³n nunca relevante en muchas sesiones; regla de una sola
  observaciÃ³n no validada; workflows que los usuarios evitan siempre; complejidad "por si
  acaso" que nunca disparÃ³.

**NO loguear:** correcciones de una sola vez que no generalizan; preferencias ya capturadas;
bugs de herramientas ajenos a la metodologÃ­a; observaciones que necesitarÃ­an info
confidencial del cliente.

## CÃ³mo loguear (mismo turno, silencioso)

Append **silencioso** a `Brain/Skills/observaciones.md`, al final, en el mismo turno o el
siguiente â€” nunca lo dejes para la memoria. **Checkpoint duro:** cada 3er TodoWrite completo
(de 3, 6, 9â€¦) escribÃ­ al log (observaciones pendientes o un marcador de una lÃ­nea
`(sin observaciones)`). El acto de escribir ES el mecanismo de enforcement.

**Formato (siempre append al final, una sola forma):**

```markdown
### Observacion N: [Titulo corto]
**Estado:** ABIERTA
**Fecha:** YYYY-MM-DD
**Contexto de sesion:** [tarea en curso]
**Skill:** [skill existente, o "Nueva skill candidata: <nombre>"]
**Tipo:** [open-source | interna]
**Fase/Area:** [seccion o parte del flujo]
**Problema:** [que paso, concreto]
**Mejora sugerida:** [cambio concreto; para skills existentes nombra seccion/regla]
**Principio:** [takeaway generalizable â€” el campo mas importante]
```

**Disciplina de numeraciÃ³n (obligatorio):**
1. Pre-chequeo: leÃ© `observaciones.md`, tomÃ¡ el mayor `### Observacion N` existente (grep).
2. Antes de escribir: verificÃ¡ que el nÃºmero propuesto (`max+1`) no colisione; si colisiona,
   incrementÃ¡ hasta max+1 real.
3. Post-write: contÃ¡ ocurrencias del nÃºmero; si >1, un escritor paralelo colisionÃ³ â€” renumerÃ¡
   TU entrada a max+1 (identificÃ¡ tu append por el largo de lÃ­nea previo/post).

**Seguridad de escritura del log (nunca mutar entre entradas):** cualquier reescritura total
(archivado, renumerado) arma desde un snapshot fresco: backup â†’ re-leÃ© el log vivo justo antes
y merge de entradas nuevas â†’ mutaciÃ³n acotada (una entrada a la vez) â†’ verificÃ¡ el conteo de
headers contra el archivo vivo â†’ confirmÃ¡ que TUS entradas sobrevivieron. Un patrÃ³n DOTALL
sobre todo el archivo puede tragarse entradas posteriores: mutÃ¡ de a una entrada, no con regex
greedy sobre el archivo entero.

**Cada nueva observaciÃ³n DEBE llevar `**Estado:** ABIERTA` como primer campo** â€” una sin
estado es invisible para pasadas filtradas. En observaciones de archivo, mover a
`Brain/Skills/archive/YYYY-MM-DD.md` lo ya resuelto con fecha registrada anterior a hoy.
Respaldo previo.

## Archivo (convenciÃ³n del vault)

En cada escritura, mover primero las entradas ya resueltas (con fecha legible anterior a hoy)
a `Brain/Skills/archive/log-YYYY-MM-DD.md` (preservando el header). Lo resuelto hoy queda en
el log activo hasta maÃ±ana. El header y la fila de estado se conservan en el archivo.

## TaxonomÃ­a

- **open-source:** metodologÃ­a agnÃ³stica de cliente, Ãºtil para otros practicantes.
- **interna:** contiene especificidades del usuario/proyecto o preferencias personales.
- Por defecto, cuando podrÃ­a ser cualquiera, elegÃ­ open-source despojando especificidades.
  El lÃ­mite tambiÃ©n es una frontera de confidencialidad. Los Principios open-source van
  generalizados sin nombrar clientes ni dominios rastreables.

## Protocolo de superficie

Por defecto al **final de la sesiÃ³n**, como resumen agrupado (mejoras por skill + candidatas a
nueva skill, una lÃ­nea + tipo sugerido); preguntÃ¡ sobre cuÃ¡les actuar. SuperficÃ© antes cuando una
observaciÃ³n necesita input del usuario, cuando un skill produce output incorrecto, o cuando varias
observaciones se amontonan sobre un skill.

**Default: loguear y diferir.** Superficar no invita a actuar. La aplicaciÃ³n en-sesiÃ³n es SOLO para:
revisiÃ³n programada, pedido explÃ­cito del usuario, o corregir un skill que produce output errÃ³neo
en la sesiÃ³n actual. No ofrezcas rutinariamente el binario "aplicar ahora vs dejarlo para la
revisiÃ³n".

**Autochequeo antes de superficar:** observaciones registradas toda la sesiÃ³n (incluidas fases de
discusiÃ³n); silenciosas; cada una con Problema â†’ Mejora â†’ Principio; tipadas; items existentes
nombran la secciÃ³n; ningÃºn Principio open-source contiene info identificable; cada append lleva
`**Estado:** ABIERTA`. Luego la verificaciÃ³n de supervivencia (regla 5 de seguridad).

## Actuar sobre observaciones

ActuÃ¡ solo en tres contextos: (1) la revisiÃ³n comprensiva; (2) un pedido explÃ­cito del usuario
("actualizÃ¡ skill X", "actuÃ¡ sobre la observaciÃ³n N"); (3) correcciÃ³n en-sesiÃ³n cuando una skill
produce output errÃ³neo que el usuario debe conocer. Si no: **logueÃ¡, no actÃºes**.

Al actuar: cambios pequeÃ±os, aditivos y de bajo riesgo (nueva regla, aclaraciÃ³n, fix factual)
pueden aplicarse directo. Cambios sustanciales (reestructurar, nuevas capacidades) y toda
creaciÃ³n de skill nueva: seguÃ­ las convenciones de `_Config/.opencode/skills/` (SKILL.md
kebab-case, frontmatter `name`/`description` en inglÃ©s para el auto-load) y las reglas del vault
(`Meta/Conventions`). Si la observaciÃ³n revela un principio que aplica a skills en general,
proponelo para `Reglas/Comunes/Ecosistema Skills.md`.

## Referencia rÃ¡pida

| Pregunta | Respuesta |
|----------|-----------|
| CuÃ¡ndo observo | Toda la sesiÃ³n, incluidas fases de feedback y reflexiÃ³n |
| CÃ³mo logueo | Silencioso, inmediato, append al final, con disciplina de numeraciÃ³n |
| CuÃ¡ndo superfico | Fin de sesiÃ³n, o antes si se necesita input |
| Estado | Obligatorio `**Estado:** ABIERTA` como primer campo de cada observaciÃ³n |
| DÃ³nde va la observaciÃ³n cruda | `Brain/Skills/observaciones.md` |
| PromociÃ³n durable | `Brain/Errores/` o `Brain/Aciertos/` (y `Lecciones/` con backlink si generaliza) |
| Actuar | Solo en revisiÃ³n programada, pedido explÃ­cito, o skill con output errÃ³neo |
| Reescribir el log | Backup â†’ re-leer vivo y merge â†’ mutaciÃ³n acotada â†’ verificar conteo |
| RevisiÃ³n semanal | Trigger en el inicio de sesiÃ³n; procedimiento por convenciÃ³n del vault |
