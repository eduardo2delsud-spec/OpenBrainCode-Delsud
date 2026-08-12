---
type: meta
project: OpenBrainCode
updated: 2026-08-07
tags: [mcp, knowledge-graph, semantica]
---

# Integración MCP: obra/knowledge-graph

Búsqueda semántica sobre el vault (vecinos, caminos, comunidades, centralidad) expuesta como MCP a opencode.

## Setup (documentado en `AGENTS.md` §6)
1. Clonar el tool como **hermano** del vault (fuera del repo): `git clone https://github.com/obra/knowledge-graph.git ../knowledge-graph`.
2. `npm install` (aprobando scripts: `better-sqlite3 esbuild onnxruntime-node protobufjs sharp`).
3. Indexar:
   ```powershell
   $env:KG_VAULT_PATH = "<ruta del vault>"; npx tsx src/cli/index.ts index
   ```
4. **Reiniciar opencode** para que cargue el MCP.

## Registro en `opencode.json`
```json
"mcp": { "openbraincode-kg": {
  "type": "local",
  "command": ["npx", "tsx", "src/mcp/index.ts"],
  "cwd": "../knowledge-graph",
  "environment": { "KG_VAULT_PATH": "../OpenBrainCode" },
  "enabled": true
}}
```
Paths relativos → portabilidad.

## 14 tools MCP
`kg_search`, `kg_node`, `kg_neighbors`, `kg_paths`, `kg_common`, `kg_subgraph`, `kg_communities`, `kg_community`, `kg_bridges`, `kg_central`, `kg_create_node`, `kg_annotate_node`, `kg_add_link`, `kg_index`.

## Índice
`<ruta de datos local>`/knowledge-graph/kg.db (SQLite, fuera del vault, no versionado).

## Bug corregido en el tool
`tools/list` reventaba al archivo `Cannot read properties of undefined (reading '_zod')` por `z.record(z.unknown())` (incompat con `@modelcontextprotocol/sdk`). Fix: `z.object({}).catchall(z.unknown()).optional()` en `src/mcp/index.ts` (repo `knowledge-graph`, cambios sin commitear).

Commit de referencia: `4b6e8fd`.