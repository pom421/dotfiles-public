#!/usr/bin/env node
// Compare deux settings.json de VSCode clé par clé, pour trier des réglages qui ont
// divergé entre deux machines :
//   node vscode-settings-diff.mjs <A> <B>
// Les fichiers peuvent contenir des commentaires et des virgules finales (JSONC).
// Un réglage d'extension (préfixe « vim. », « prettier. »…) dont aucune extension
// installée ne porte le nom est signalé « extension absente ? » : souvent un vestige.
import { readFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { basename } from "node:path";

const [fileA, fileB] = process.argv.slice(2);
if (!fileA || !fileB) {
  console.error("Usage : node vscode-settings-diff.mjs <settings A> <settings B>");
  process.exit(1);
}

// Un objet littéral JavaScript accepte commentaires et virgules finales (fichiers de confiance)
const load = (f) => new Function(`return (${readFileSync(f, "utf8")}\n)`)();
const a = load(fileA);
const b = load(fileB);

// Préfixes des réglages intégrés à VSCode (pas d'extension à rechercher)
const builtin = new Set(("breadcrumbs chat css debug diffEditor editor emmet explorer extensions files " +
  "git github github.copilot html http javascript json markdown merge-conflict notebook npm " +
  "outline problems remote scm search security settingsSync telemetry terminal testing " +
  "typescript update window workbench zenMode accessibility audioCues").split(" "));

let extensions = [];
try {
  extensions = execFileSync("code", ["--list-extensions"], { encoding: "utf8", env: { ...process.env, NODE_NO_WARNINGS: "1" } })
    .toLowerCase().split("\n").filter(Boolean);
} catch {
  console.error("(commande code absente : pas de détection des extensions absentes)\n");
}

const namespace = (key) => (key.startsWith("[") ? "" : key.split(".")[0]);
const note = (key) => {
  const ns = namespace(key);
  if (!ns || builtin.has(ns) || extensions.length === 0) return "";
  const n = ns.toLowerCase().replace(/[^a-z0-9]/g, "");
  const found = extensions.some((e) => e.replace(/[^a-z0-9.]/g, "").includes(n));
  return found ? "" : "   ← extension absente ?";
};

const sortKeys = (v) =>
  v && typeof v === "object" && !Array.isArray(v)
    ? Object.fromEntries(Object.keys(v).sort().map((k) => [k, sortKeys(v[k])]))
    : v;
const same = (x, y) => JSON.stringify(sortKeys(x)) === JSON.stringify(sortKeys(y));
const show = (v) => JSON.stringify(v);

const keys = [...new Set([...Object.keys(a), ...Object.keys(b)])].sort();
const both = keys.filter((k) => k in a && k in b && same(a[k], b[k]));
const differ = keys.filter((k) => k in a && k in b && !same(a[k], b[k]));
const onlyA = keys.filter((k) => k in a && !(k in b));
const onlyB = keys.filter((k) => !(k in a) && k in b);

const labelA = `A (${basename(fileA)})`;
const labelB = `B (${basename(fileB)})`;
console.log(`A = ${fileA}\nB = ${fileB}\n`);

console.log(`== Identiques des deux côtés (${both.length}) : utilisés partout, à garder`);
for (const k of both) console.log(`  ${k} = ${show(a[k])}${note(k)}`);

console.log(`\n== Valeurs différentes (${differ.length}) : à trancher`);
for (const k of differ) {
  console.log(`  ${k}${note(k)}`);
  console.log(`    ${labelA} : ${show(a[k])}`);
  console.log(`    ${labelB} : ${show(b[k])}`);
}

console.log(`\n== Seulement dans ${labelA} (${onlyA.length})`);
for (const k of onlyA) console.log(`  ${k} = ${show(a[k])}${note(k)}`);

console.log(`\n== Seulement dans ${labelB} (${onlyB.length})`);
for (const k of onlyB) console.log(`  ${k} = ${show(b[k])}${note(k)}`);
