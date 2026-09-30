#!/usr/bin/env node
// Construit le settings.json de VSCode par couches (appelé par `make vscode`) :
//   1. vscode/settings.json                commun à toutes les machines
//   2. vscode/settings.d/<os>.json         darwin ou linux (facultatif)
//   3. ~/.config/vscode/settings.d/*.json  contexte (dotfiles-private) puis machine, par ordre alphabétique
// Fusion : un objet étend celui de la couche précédente, une autre valeur le
// remplace, null le supprime. Les couches peuvent contenir des commentaires (JSONC).
//   vscode-settings.mjs [--layers]   écrit le résultat sur la sortie standard
//                                    (--layers : liste seulement les couches trouvées)
import { readFileSync, readdirSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { homedir, platform } from "node:os";
import { fileURLToPath } from "node:url";

const repo = dirname(dirname(fileURLToPath(import.meta.url)));
const os = platform() === "darwin" ? "darwin" : "linux";
const configHome = process.env.XDG_CONFIG_HOME || join(homedir(), ".config");
const localDir = join(configHome, "vscode", "settings.d");

const jsonFiles = (dir) =>
  existsSync(dir) ? readdirSync(dir).filter((f) => f.endsWith(".json")).sort().map((f) => join(dir, f)) : [];

const layers = [
  join(repo, "vscode", "settings.json"),
  join(repo, "vscode", "settings.d", `${os}.json`),
  ...jsonFiles(localDir),
].filter(existsSync);

if (process.argv.includes("--layers")) {
  for (const l of layers) console.log(l);
  process.exit(0);
}

// Un objet littéral JavaScript accepte commentaires et virgules finales (fichiers de confiance)
const load = (f) => {
  try {
    return new Function(`return (${readFileSync(f, "utf8")}\n)`)();
  } catch (e) {
    console.error(`vscode-settings : ${f} illisible (${e.message})`);
    process.exit(1);
  }
};

const isObject = (v) => v !== null && typeof v === "object" && !Array.isArray(v);
const merge = (base, over) => {
  const out = { ...base };
  for (const [k, v] of Object.entries(over)) {
    if (v === null) delete out[k];
    else if (isObject(v) && isObject(out[k])) out[k] = merge(out[k], v);
    else out[k] = v;
  }
  return out;
};

const settings = layers.map(load).reduce(merge, {});
const header = [
  "// Généré par `make vscode` : une modification ici sera remplacée au prochain passage.",
  "// Couches (la dernière l'emporte) :",
  ...layers.map((l) => `//   ${l.replace(homedir(), "~")}`),
];
console.log(`${header.join("\n")}\n${JSON.stringify(settings, null, 2)}`);
