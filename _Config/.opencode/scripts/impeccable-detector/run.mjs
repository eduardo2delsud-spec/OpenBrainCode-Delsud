#!/usr/bin/env node
/**
 * run.mjs — Runner autocontenido del "Impeccable detector" (librería anti-diseño-genérico).
 *
 * Subconjunto puro-Node extraído de pbakaus/impeccable v4 (Apache-2.0). Sin Puppeteer,
 * sin hooks; solo el análisis estático (HTML/CSS) + regex (CSS/JSX/TSX) que cubre las
 * reglas de "generic AI design": fuentes sobre-usadas, paletas genéricas, gradientes
 * saturados, glow/sombras tipo GPT, layout repetido, micro-copy cliché, etc.
 *
 * Uso:
 *   node run.mjs <archivo-or>:<dir>... [--json] [--scope <type,layout,...>]
 *   exit 0 = sin hallazgos primarios | exit 2 = hallazgos primarios
 *
 * Integrado al vault: regla `Reglas/Frontend/Arranque Frontend.md` y `skills/impeccable-detector`.
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { detectHtml } from './engines/static-html/detect-html.mjs';
import { detectText } from './engines/regex/detect-text.mjs';
import { filterByScopes, RULE_SCOPES } from './registry/antipatterns.mjs';

const HTML_EXTENSIONS = new Set(['.html', '.htm']);
const SKIP_DIRS = new Set(['node_modules', '.git', 'dist', 'build', '.next', '.nuxt', 'coverage']);
const SCANNABLE = /\.(html?|css|jsx|tsx|vue|svelte|scss|sass|less|ts|js)$/i;

function walk(dir) {
  const out = [];
  let entries;
  try { entries = fs.readdirSync(dir, { withFileTypes: true }); }
  catch { return out; }
  for (const e of entries) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) {
      if (!SKIP_DIRS.has(e.name)) out.push(...walk(p));
    } else if (SCANNABLE.test(e.name)) {
      out.push(p);
    }
  }
  return out;
}

function isAdvisory(f) { return f && f.advisory === true; }

function group(findings) {
  const byFile = {};
  for (const f of findings) { (byFile[f.file] = byFile[f.file] || []).push(f); }
  return byFile;
}

async function main() {
  let args = process.argv.slice(2);
  const jsonMode = args.includes('--json');
  args = args.filter(a => a !== '--json');

  let scopes = [];
  for (let i = 0; i < args.length; i++) {
    if (args[i] !== '--scope') continue;
    const v = args[i + 1];
    scopes = (v && !v.startsWith('--')) ? v.split(',').map(s => s.trim()).filter(Boolean) : [];
    args.splice(i, 1);
    if (scopes.length) args.splice(i, 1);
    break;
  }
  const ok = scopes.every(s => RULE_SCOPES.has(s));
  if (!ok) {
    console.error(`Error: --scope inválido. Válidos: ${[...RULE_SCOPES].join(', ')}`);
    process.exit(1);
  }

  const targets = args.length ? args : ['.'];
  const files = [];
  for (const t of targets) {
    const p = path.resolve(t);
    let st; try { st = fs.statSync(p); } catch { console.error(`Error: no existe ${t}`); process.exit(1); }
    if (st.isDirectory()) files.push(...walk(p));
    else if (SCANNABLE.test(p)) files.push(p);
  }

  const findings = [];
  for (const f of files) {
    const opts = { inlineIgnores: true };
    const content = fs.readFileSync(f, 'utf-8');
    const res = HTML_EXTENSIONS.has(path.extname(f).toLowerCase())
      ? await detectHtml(f, opts)
      : detectText(content, f, opts);
    findings.push(...res);
  }

  const filtered = filterByScopes(findings, scopes);
  const primary = filtered.filter(f => !isAdvisory(f));
  const advisory = filtered.filter(isAdvisory);

  if (jsonMode) { console.log(JSON.stringify(filtered, null, 2)); process.exit(primary.length ? 2 : 0); }

  const byFile = group(filtered);
  for (const [file, items] of Object.entries(byFile)) {
    console.log(`\n${file}`);
    for (const it of items) {
      const flag = isAdvisory(it) ? '(advisory) ' : '';
      console.log(`  ${flag}[${it.antipattern}]${it.line ? ' line ' + it.line : ''}: ${it.snippet}`);
      console.log(`    -> ${it.description}`);
    }
  }
  console.log(`\n${primary.length} anti-pattern${primary.length === 1 ? '' : 's'} encontrado${primary.length === 1 ? '' : 's'}${advisory.length ? ` (${advisory.length} advisory)` : ''}.`);
  process.exit(primary.length ? 2 : 0);
}

main().catch((e) => { console.error(e); process.exit(1); });