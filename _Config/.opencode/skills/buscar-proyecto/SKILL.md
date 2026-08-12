---
name: buscar-proyecto
description: Use when the user wants to find information in the knowledge graph. Triggers: "buscar", "qué proyecto usa X", "dónde está Y", "qué proyectos tienen Z", "concepto", "patrón", "lección", "search". Searches projects, concepts, patterns, lessons, and decisions.
---

# Buscar en el Knowledge Graph

Busca información en el vault OpenBrainCode, siguiendo conexiones entre notas.

## Ruta del vault

El vault es la raíz de este proyecto (donde vive `OpenBrainCode.md`). Las notas están en las subcarpetas `Proyectos/`, `Conceptos/`, `Patrones/`, `Lecciones/`, `Decisiones/` y `Brain/`.

## Flujo de búsqueda

### 1. Determinar tipo de búsqueda

El usuario puede preguntar de varias formas:

| Pregunta | Tipo | Dónde buscar |
|----------|------|-------------|
| "¿Qué proyecto usa X?" | concepto | `Conceptos/` → "Proyectos que lo usan" |
| "¿Cómo está hecho Y?" | proyecto | `Proyectos/` |
| "¿Qué proyectos son microservicios?" | patrón | `Patrones/` o frontmatter `arch:` |
| "¿Qué lecciones aprendiste de X?" | lección | `Lecciones/` → "De dónde viene" |
| "¿Por qué se usó Biome?" | decisión | `Decisiones/` |
| "¿Me pasó este error / cómo lo arreglé?" | error | `Brain/Errores/` → Síntoma/Causa/Solución/Keywords |
| "¿Qué me funcionó / acierto?" | acierto | `Brain/Aciertos/` → "Cómo repetirlo" |
| "¿Qué conceptos comparten X e Y?" | intersección | Comparar "Conceptos que usa" de ambos |

### 2. Búsqueda en conceptos

```bash
grep -r "<término>" Conceptos/
```

Si encuentra el concepto, leer la nota y seguir:
- "Proyectos que lo usan" → listar proyectos
- "Patrones relacionados" → seguir enlaces
- "Lecciones" → seguir enlaces

### 3. Búsqueda en proyectos

```bash
grep -r "<término>" Proyectos/
```

Leer la ficha del proyecto y seguir:
- "Conceptos que usa" → seguir enlaces
- "Patrones que sigue" → seguir enlaces
- "Decisiones clave" → seguir enlaces
- "Lecciones" → seguir enlaces

### 4. Búsqueda en patrones

```bash
grep -r "<término>" Patrones/
```

Leer el patrón y seguir:
- "Proyectos que lo usan" → listar proyectos
- "Conceptos relacionados" → seguir enlaces

### 5. Búsqueda en lecciones

```bash
grep -r "<término>" Lecciones/
```

Leer la lección y seguir:
- "De dónde viene" → proyectos fuente
- "Relacionado" → conceptos/patrones

### 6. Búsqueda en decisiones

```bash
grep -r "<término>" Decisiones/
```

Leer la ADR y seguir:
- "Proyectos que la aplican" → listar proyectos
- "Relacionado" → conceptos/patrones

### 6b. Búsqueda de errores (troubleshooting)

Cuando el usuario describe un error ("¿me pasó esto?", "¿cómo solucioné X?"):

```bash
grep -ri "mensaje de error\|síntoma\|causa\|fix" Brain/Errores/
```

Buscar por **síntomas, mensajes de error reales y keywords**. Al leer la nota, extraer:
- "Síntoma" → ¿coincide con lo que ve el usuario?
- "Solución / Fix" → el arreglo exacto
- "Regla práctica" / "Prevención" → consejo para el futuro

### 6c. Búsqueda de aciertos (qué reutilizar)

```bash
grep -ri "<término>" Brain/Aciertos/
```

Leer la nota y seguir:
- "Cómo repetirlo" → pasos reutilizables
- "Por qué funcionó" → principio
- "Relacionado" → patrones/conceptos

### 7. Búsqueda transversal (el poder del cerebro)

Cuando el usuario pregunta algo complejo:

**"¿Qué proyectos tienen auth con refresh tokens?"**
1. Buscar "refresh token" en `Conceptos/`
2. Encontrar `Conceptos/autenticacion-jwt.md`
3. Leer "Proyectos que lo usan"
4. Filtrar por "refresh token" en cada proyecto
5. Responder con la lista y las diferencias

**"¿Qué lecciones aplican a un proyecto con SQLite?"**
1. Buscar "SQLite" en `Conceptos/`
2. Encontrar `Conceptos/SQLite.md`
3. Leer "Lecciones" → encontrar `Lecciones/<Nombre de la lección>`
4. Responder con la lección y los proyectos afectados

**"¿Qué patrones comparten el Proyecto A y el Proyecto B?"**
1. Leer `Proyectos/Proyecto A/Proyecto A.md` → "Patrones que sigue"
2. Leer `Proyectos/Proyecto B/Proyecto B.md` → "Patrones que sigue"
3. Intersectar → encontrar patrones comunes
4. Responder con los patrones compartidos

### 8. Presentar resultados

Para cada resultado:
- **Tipo**: proyecto / concepto / patrón / lección / decisión
- **Nombre**: enlace a la nota
- **Relevancia**: por qué coincide
- **Conexiones**: qué otros notas enlaza
- **Ruta**: dónde está la nota

**Formato de respuesta:**
```
Encontré "<término>" en <N> notas:

1. **Conceptos/autenticacion-jwt.md** (concepto)
   - Qué es: autenticación JWT con access + refresh tokens
   - Proyectos que lo usan: Proyecto A, Proyecto B, Proyecto C
   - Patrones relacionados: SPA + API
   - Lecciones: "Siempre usar refresh tokens rotados"

2. **Proyectos/Proyecto B/Proyecto B.md** (proyecto)
   - En sección "Conceptos que usa": [[Conceptos/autenticacion-jwt]]
   - Usa refresh token rotado (15min access + refresh)
   - Ruta: <PROJECTS_ROOT>/Proyecto B
```

## Respuestas típicas

**"¿Qué proyecto usa Stripe?"**
→ Buscar "stripe" en `Conceptos/` → encontrar → listar proyectos

**"¿Dónde hay auth con refresh tokens?"**
→ Buscar "refresh token" en `Conceptos/` → leer → listar proyectos con detalles

**"¿Cómo está hecho el Proyecto A?"**
→ Leer `Proyectos/Proyecto A/Proyecto A.md` → dar resumen con conexiones

**"¿Qué lecciones hay sobre SQLite?"**
→ Buscar "SQLite" en `Lecciones/` → listar lecciones

**"Este error de connection refused me pasó antes?"**
→ Buscar "connection refused" (y variantes) en `Brain/Errores/` → si hay nota, leer "Síntoma"/"Solución"/"Regla práctica" → responder y enlazar

**"¿Qué patrones usan mis proyectos de IA?"**
→ Buscar proyectos con `#dominio/ia` → leer patrones → intersectar

## Si no encuentra nada

1. Verificar ortografía
2. Buscar sin acentos
3. Buscar en `$OPENBRAIN_PROJECTS_ROOT\*\README.md` (proyectos no indexados aún)
4. Si es un proyecto nuevo → sugerir `/scrape-proyecto <ruta>`
