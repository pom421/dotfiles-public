/**
 * Met à jour nvim en respectant un cooldown (7 jours par défaut) : on ne prend que des
 * versions publiées depuis au moins N jours, pour laisser le temps de détecter une version
 * compromise ou cassée.
 *
 * Usage : node scripts/nvim-cooldown.ts [--days N] [--now plugin1,plugin2]   (ou : make nvim-update)
 *
 * - Plugins : pour chaque plugin de lazy.nvim, le commit le plus récent de plus de N jours
 *   (dernier tag semver de plus de N jours si le plugin déclare `version`), écrit dans
 *   lazy-lock.json puis appliqué par :Lazy restore.
 * - Outils Mason (LSP, formateurs, linters, débogueurs) : le registre Mason est figé sur une
 *   release de plus de N jours (lua/config/cooldown.lua), puis :MasonSync installe les versions
 *   qu'il référence.
 * - --now : exception pour un correctif de sécurité, ces plugins prennent la dernière version.
 *   Pour un outil Mason, fixer sa version dans lua/plugins/mason.lua ({ "nom", version = "x" }).
 */
import { execFileSync, spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { parseArgs } from "node:util";

const REPO = dirname(dirname(fileURLToPath(import.meta.url)));
const NVIM_CONF = join(REPO, "nvim/.config/nvim");
const LOCKFILE = join(NVIM_CONF, "lazy-lock.json");
const COOLDOWN_LUA = join(NVIM_CONF, "lua/config/cooldown.lua");
const MASON_REGISTRY = "https://github.com/mason-org/mason-registry";

const { values } = parseArgs({
  options: {
    days: { type: "string", default: "7" },
    now: { type: "string", default: "" },
  },
});
const days = Number(values.days);
if (!Number.isInteger(days) || days < 0) throw new Error(`--days invalide : ${values.days}`);
const immediats = new Set(values.now.split(",").filter(Boolean));
const limite = new Date(Date.now() - days * 86_400_000);

type Spec = { name: string; dir: string; branch?: string; version?: string; installed: boolean };
type Lock = Record<string, { branch: string; commit: string }>;

function git(dir: string, ...args: string[]): string {
  return execFileSync("git", ["-C", dir, ...args], { encoding: "utf-8" }).trim();
}

/** nvim headless ; sa sortie (journal verbeux de lazy) n'est affichée que pour les erreurs. */
function nvim(...cmds: string[]): void {
  const r = spawnSync("nvim", ["--headless", ...cmds.map((c) => `+${c}`), "+qa"], { encoding: "utf-8" });
  const sortie = `${r.stdout}\n${r.stderr}`.replace(/\x1b\[[0-9;]*m/g, "");
  for (const ligne of sortie.split(/[\r\n]+/))
    // hors journal git de lazy (« log | <commit> »), dont les messages contiennent souvent « error »
    if (/error|failed|erreur|échec/i.test(ligne) && !/\blog \| /.test(ligne)) console.error(`  nvim : ${ligne.trim()}`);
  if (r.status !== 0) throw new Error(`nvim ${cmds.join(" ")} : code ${r.status}`);
}

/** Plugins déclarés dans la config, lus par lazy.nvim lui-même. */
function specs(): Spec[] {
  const tmp = mkdtempSync(join(tmpdir(), "nvim-cooldown-"));
  const out = join(tmp, "specs.json");
  try {
    const lua =
      "local t = {} " +
      'for _, p in pairs(require("lazy.core.config").plugins) do ' +
      "if not p._.is_local then " +
      "t[#t + 1] = { name = p.name, dir = p.dir, branch = p.branch, " +
      'version = type(p.version) == "string" and p.version or nil, installed = p._.installed == true } ' +
      "end end " +
      `vim.fn.writefile({ vim.json.encode(t) }, ${JSON.stringify(out)})`;
    nvim(`lua ${lua}`);
    return JSON.parse(readFileSync(out, "utf-8")) as Spec[];
  } finally {
    rmSync(tmp, { recursive: true, force: true });
  }
}

type Semver = [number, number, number];

function semver(tag: string): Semver | undefined {
  const m = /^v?(\d+)\.(\d+)\.(\d+)$/.exec(tag);
  return m ? [Number(m[1]), Number(m[2]), Number(m[3])] : undefined;
}

/** Seules les formes utilisées dans la config : "*" et "N.*". */
function correspond(v: Semver, plage: string): boolean {
  if (plage === "*") return true;
  const m = /^(\d+)\.\*$/.exec(plage);
  if (!m) throw new Error(`version non gérée par le cooldown : "${plage}" (utiliser "*" ou "N.*")`);
  return v[0] === Number(m[1]);
}

function compare(a: Semver, b: Semver): number {
  return a[0] - b[0] || a[1] - b[1] || a[2] - b[2];
}

/** Commit cible d'un plugin, ou undefined si rien d'assez ancien. */
function cible(spec: Spec, lock: Lock): { branch: string; commit: string; ref: string } | undefined {
  const sansCooldown = immediats.has(spec.name);
  const branch =
    spec.branch ?? lock[spec.name]?.branch ?? git(spec.dir, "rev-parse", "--abbrev-ref", "origin/HEAD").replace(/^origin\//, "");

  if (spec.version) {
    let meilleur: { v: Semver; tag: string } | undefined;
    const lignes = git(spec.dir, "for-each-ref", "--format=%(refname:short) %(creatordate:iso-strict)", "refs/tags");
    for (const ligne of lignes.split("\n").filter(Boolean)) {
      const [tag, date] = ligne.split(" ");
      const v = semver(tag);
      if (!v || !correspond(v, spec.version)) continue;
      if (!sansCooldown && new Date(date) > limite) continue;
      if (!meilleur || compare(v, meilleur.v) > 0) meilleur = { v, tag };
    }
    if (!meilleur) return undefined;
    return { branch, commit: git(spec.dir, "rev-parse", `${meilleur.tag}^{commit}`), ref: meilleur.tag };
  }

  const args = ["rev-list", "-1"];
  if (!sansCooldown) args.push(`--before=${limite.toISOString()}`);
  const commit = git(spec.dir, ...args, `origin/${branch}`);
  return commit ? { branch, commit, ref: branch } : undefined;
}

function ecrireLock(lock: Lock): void {
  // Même format que lazy.nvim (lua/lazy/manage/lock.lua), pour des diffs propres
  const noms = Object.keys(lock).sort();
  const lignes = noms.map((n) => `  ${JSON.stringify(n)}: { "branch": ${JSON.stringify(lock[n].branch)}, "commit": ${JSON.stringify(lock[n].commit)} }`);
  writeFileSync(LOCKFILE, `{\n${lignes.join(",\n")}\n}\n`);
}

/** Release du registre Mason la plus récente parmi celles d'avant la limite (tags AAAA-MM-JJ-…). */
function registreMason(): string {
  const jour = limite.toISOString().slice(0, 10);
  const tags = execFileSync("git", ["ls-remote", "--tags", "--refs", MASON_REGISTRY], {
    encoding: "utf-8",
    maxBuffer: 64 * 1024 * 1024, // des dizaines de milliers de releases
  })
    .split("\n")
    .map((l) => l.replace(/^.*refs\/tags\//, ""))
    .filter((t) => /^\d{4}-\d{2}-\d{2}-/.test(t) && t.slice(0, 10) < jour)
    .sort();
  const tag = tags.at(-1);
  if (!tag) throw new Error("aucune release du registre Mason assez ancienne");
  return tag;
}

// ─── Plugins ──────────────────────────────────────────────────────
console.log(`Cooldown : versions publiées avant le ${limite.toISOString().slice(0, 16).replace("T", " ")} UTC`);
// Installe les plugins ajoutés à la config (à leur dernière version : corrigé juste après)
nvim("Lazy! install");

const lock = JSON.parse(readFileSync(LOCKFILE, "utf-8")) as Lock;
for (const spec of specs().sort((a, b) => a.name.localeCompare(b.name))) {
  if (!spec.installed) {
    console.log(`  ?  ${spec.name} : non installé, ignoré`);
    continue;
  }
  git(spec.dir, "fetch", "--quiet", "--tags", "--force", "origin");
  const c = cible(spec, lock);
  if (!c) {
    console.log(`  !  ${spec.name} : aucune version de plus de ${days} jours, inchangé`);
    continue;
  }
  const avant = lock[spec.name]?.commit;
  const marque = avant === c.commit ? "   " : avant ? " ↻ " : " + ";
  const date = git(spec.dir, "log", "-1", "--format=%cs", c.commit);
  console.log(`${marque}${spec.name} : ${c.ref} ${c.commit.slice(0, 7)} (${date})${immediats.has(spec.name) ? " [--now]" : ""}`);
  lock[spec.name] = { branch: c.branch, commit: c.commit };
}
ecrireLock(lock);

// ─── Registre Mason ───────────────────────────────────────────────
const tag = registreMason();
const lua = readFileSync(COOLDOWN_LUA, "utf-8");
const neuf = lua.replace(/mason_registry = "[^"]*"/, `mason_registry = "${tag}"`);
if (neuf === lua && !lua.includes(`"${tag}"`)) throw new Error(`mason_registry introuvable dans ${COOLDOWN_LUA}`);
writeFileSync(COOLDOWN_LUA, neuf);
console.log(`Registre Mason : ${tag}`);

// ─── Application ──────────────────────────────────────────────────
nvim("Lazy! restore");
// Absente tant que Mason n'est pas configuré
nvim("if exists(':MasonSync') | MasonSync | endif");
console.log("Fait. Vérifier avec :checkhealth puis committer lazy-lock.json et lua/config/cooldown.lua");
