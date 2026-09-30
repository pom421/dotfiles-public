#!/usr/bin/env node
// Compare deux settings.json de VSCode clé par clé, pour trier des réglages qui ont
// divergé entre deux machines :
//   node vscode-settings-diff.mjs <A> <B>
// Les fichiers peuvent contenir des commentaires et des virgules finales (JSONC).
// Un réglage qu'aucune extension installée ne déclare (contributes.configuration de
// son package.json, extensions intégrées comprises) est signalé « aucune extension
// installée ne le déclare » : c'est un vestige d'extension désinstallée.
import { readFileSync, readdirSync, realpathSync, existsSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { basename, dirname, join } from "node:path";
import { homedir } from "node:os";

const [fileA, fileB] = process.argv.slice(2);
if (!fileA || !fileB) {
  console.error("Usage : node vscode-settings-diff.mjs <settings A> <settings B>");
  process.exit(1);
}

// Un objet littéral JavaScript accepte commentaires et virgules finales (fichiers de confiance)
const load = (f) => new Function(`return (${readFileSync(f, "utf8")}\n)`)();
const a = load(fileA);
const b = load(fileB);

// Réglages du cœur de VSCode (déclarés par l'application, pas par une extension)
const core = new Set(("accessibility audioCues breadcrumbs chat comments debug diffEditor editor " +
  "explorer extensions files http inlineChat issueReporter js/ts keyboard mcp merge-editor notebook " +
  "outline problems remote " +
  "scm search security settingsSync telemetry terminal testing timeline update window workbench " +
  "zenMode").split(" "));

// Réglages déclarés par les extensions installées (utilisateur et intégrées)
const declared = new Set();
const extensionDirs = [join(homedir(), ".vscode", "extensions")];
try {
  const app = dirname(dirname(realpathSync(execFileSync("sh", ["-c", "command -v code"], { encoding: "utf8" }).trim())));
  extensionDirs.push(join(app, "extensions"), join(app, "resources", "app", "extensions"));
} catch {
  console.error("(commande code absente : extensions intégrées non lues)\n");
}
for (const dir of extensionDirs.filter(existsSync)) {
  for (const ext of readdirSync(dir)) {
    try {
      const pkg = JSON.parse(readFileSync(join(dir, ext, "package.json"), "utf8"));
      const conf = pkg.contributes?.configuration;
      for (const c of Array.isArray(conf) ? conf : conf ? [conf] : []) {
        for (const key of Object.keys(c.properties ?? {})) declared.add(key);
      }
    } catch {}
  }
}

const note = (key) => {
  if (key.startsWith("[") || declared.size === 0) return "";
  if (core.has(key.split(".")[0]) || declared.has(key)) return "";
  return "   ← aucune extension installée ne le déclare";
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
