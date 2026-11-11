/**
 * Génère les versions PDF et Markdown de toutes les fiches HTML (ou de celles passées en argument).
 *
 * Usage : node cheatsheets/outils/build.ts [fiche.html ...]   (ou : make cheatsheets)
 *
 * - Markdown : via html2md.ts (même dossier)
 * - PDF : Chrome / Chromium headless. Les polices Google Fonts sont embarquées en
 *   data URI (sinon Chrome imprime avec une police de repli) et mises en cache
 *   dans outils/.cache. Chemin du navigateur forçable avec CHROME=/chemin.
 */
import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { basename, dirname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";
import { convert } from "./html2md.ts";

const OUTILS = dirname(fileURLToPath(import.meta.url));
const RACINE = dirname(OUTILS);
const CACHE = join(OUTILS, ".cache");
// User-agent récent : Google Fonts renvoie alors du woff2 découpé par sous-ensemble
const UA =
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36";
const LINK = /<link rel="stylesheet" href="(https:\/\/fonts\.googleapis\.com\/[^"]+)">/g;

function which(cmd: string): string | undefined {
  try {
    return execFileSync("which", [cmd], { encoding: "utf-8" }).trim() || undefined;
  } catch {
    return undefined;
  }
}

function chrome(): string {
  const candidats = [
    process.env.CHROME,
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
    which("google-chrome"),
    which("chromium"),
    which("chromium-browser"),
  ];
  const trouve = candidats.find((c) => c && existsSync(c));
  if (!trouve) {
    console.error("Chrome ou Chromium introuvable (forcer le chemin avec CHROME=/chemin)");
    process.exit(1);
  }
  return trouve;
}

/** <style> avec les polices latin / latin-ext en data URI (mis en cache). */
async function polices(url: string): Promise<string> {
  mkdirSync(CACHE, { recursive: true });
  const fichier = join(CACHE, createHash("sha1").update(url).digest("hex").slice(0, 12) + ".css");
  if (!existsSync(fichier)) {
    const css = await (await fetch(url.replaceAll("&amp;", "&"), { headers: { "User-Agent": UA } })).text();
    const faces: string[] = [];
    for (const [, sousEnsemble, bloc] of css.matchAll(/\/\* ([\w-]+) \*\/\s*(@font-face\s*{[^}]*})/g)) {
      if (sousEnsemble !== "latin" && sousEnsemble !== "latin-ext") continue;
      const src = bloc.match(/url\((https[^)]+)\)/)![1];
      const data = Buffer.from(await (await fetch(src)).arrayBuffer()).toString("base64");
      faces.push(bloc.replace(src, "data:font/woff2;base64," + data));
    }
    writeFileSync(fichier, faces.join("\n"));
  }
  return "<style>" + readFileSync(fichier, "utf-8") + "</style>";
}

async function pdf(htmlPath: string, navigateur: string): Promise<{ sortie: string; pages: string }> {
  let html = readFileSync(htmlPath, "utf-8");
  for (const [balise, url] of [...html.matchAll(LINK)]) html = html.replace(balise, await polices(url));
  const sortie = htmlPath.replace(/\.html$/, ".pdf");
  const tmp = mkdtempSync(join(tmpdir(), "cheatsheet-"));
  try {
    const page = join(tmp, basename(htmlPath));
    writeFileSync(page, html, "utf-8");
    execFileSync(
      navigateur,
      ["--headless", "--disable-gpu", "--no-pdf-header-footer", `--user-data-dir=${tmp}/profil`, `--print-to-pdf=${sortie}`, page],
      { stdio: "ignore" },
    );
  } finally {
    rmSync(tmp, { recursive: true, force: true });
  }
  let pages = "?";
  if (which("pdfinfo")) {
    const info = execFileSync("pdfinfo", [sortie], { encoding: "utf-8" });
    pages = info.match(/Pages:\s+(\d+)/)?.[1] ?? "?";
  }
  return { sortie, pages };
}

const fiches =
  process.argv.length > 2
    ? process.argv.slice(2)
    : readdirSync(RACINE, { recursive: true, encoding: "utf-8" })
        .filter((f) => f.endsWith(".html") && !f.includes(".cache"))
        .sort()
        .map((f) => join(RACINE, f));

const navigateur = chrome();
for (const f of fiches) {
  console.log(relative(process.cwd(), convert(f)));
  const { sortie, pages } = await pdf(f, navigateur);
  console.log(`${relative(process.cwd(), sortie)} : ${pages} page(s)`);
}
