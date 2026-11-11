/**
 * Génère la version Markdown d'une fiche HTML (même contenu, lisible dans nvim).
 *
 * Usage : node cheatsheets/outils/html2md.ts cheatsheets/nvim/nvim-fiche.html [...]  → .md à côté
 * (make cheatsheets génère Markdown + PDF de toutes les fiches)
 *
 * Sans dépendance : un mini-parseur suffit, les fiches sont du HTML écrit à la main et bien formé.
 */
import { readFileSync, writeFileSync } from "node:fs";
import { relative } from "node:path";

type Child = Node | string;

interface Node {
  tag: string;
  attrs: Record<string, string>;
  parent: Node | null;
  children: Child[];
}

const VOID = new Set(["meta", "link", "br", "hr", "img", "input"]);
const RAW = new Set(["style", "script"]);

const isNode = (c: Child): c is Node => typeof c !== "string";
const classes = (n: Node): string[] => (n.attrs.class ?? "").split(/\s+/).filter(Boolean);

// ─── Parsing ─────────────────────────────────────────────────────

function decodeEntities(s: string): string {
  const named: Record<string, string> = { lt: "<", gt: ">", amp: "&", quot: '"', apos: "'", nbsp: " " };
  return s.replace(/&(#x[0-9a-f]+|#\d+|\w+);/gi, (m, e: string) => {
    if (e[0] === "#") {
      const code = e[1] === "x" || e[1] === "X" ? parseInt(e.slice(2), 16) : parseInt(e.slice(1), 10);
      return String.fromCodePoint(code);
    }
    return named[e.toLowerCase()] ?? m;
  });
}

function parse(html: string): Node {
  const root: Node = { tag: "root", attrs: {}, parent: null, children: [] };
  let cur = root;
  const token = /<!--[\s\S]*?-->|<!doctype[^>]*>|<(\/?)([a-zA-Z][a-zA-Z0-9]*)([^>]*)>|[^<]+|</gi;
  for (const m of html.matchAll(token)) {
    const [text, closing, rawTag, rawAttrs] = m;
    if (text.startsWith("<!")) continue;
    if (!rawTag) {
      cur.children.push(decodeEntities(text));
      continue;
    }
    const tag = rawTag.toLowerCase();
    if (closing) {
      // remonte jusqu'à la balise ouvrante correspondante (tolère les fermetures implicites)
      let n: Node | null = cur;
      while (n && n !== root && n.tag !== tag) n = n.parent;
      if (n && n !== root) cur = n.parent ?? root;
      continue;
    }
    const attrs: Record<string, string> = {};
    for (const a of rawAttrs.matchAll(/([\w:-]+)(?:\s*=\s*"([^"]*)")?/g)) attrs[a[1]] = decodeEntities(a[2] ?? "");
    const node: Node = { tag, attrs, parent: cur, children: [] };
    cur.children.push(node);
    if (RAW.has(tag)) {
      // contenu brut (CSS) : sauté jusqu'à la balise fermante
      const end = html.toLowerCase().indexOf(`</${tag}>`, m.index + text.length);
      token.lastIndex = end === -1 ? html.length : end + tag.length + 3;
    } else if (!VOID.has(tag) && !rawAttrs.trimEnd().endsWith("/")) {
      cur = node;
    }
  }
  return root;
}

function* findAll(node: Node, tag?: string, cls?: string): Generator<Node> {
  for (const c of node.children) {
    if (!isNode(c)) continue;
    if ((tag === undefined || c.tag === tag) && (cls === undefined || classes(c).includes(cls))) yield c;
    yield* findAll(c, tag, cls);
  }
}

const first = (node: Node, tag?: string, cls?: string): Node | undefined => findAll(node, tag, cls).next().value;

function textOf(node: Node): string {
  return node.children.map((c) => (isNode(c) ? textOf(c) : c)).join("");
}

function remove(node: Node, child: Node): void {
  node.children = node.children.filter((c) => c !== child);
}

// ─── Rendu Markdown ──────────────────────────────────────────────

/** `…` avec un délimiteur plus long que les backticks du contenu. */
function codeSpan(text: string): string {
  const longest = Math.max(0, ...(text.match(/`+/g) ?? []).map((r) => r.length));
  const fence = "`".repeat(longest + 1);
  const pad = text.startsWith("`") || text.endsWith("`") ? " " : "";
  return fence + pad + text + pad + fence;
}

/**
 * Texte d'un nœud en Markdown inline : kbd/code → `…`, b → **…**.
 * Deux spans de code collés (<kbd>f</kbd><code>c</code>) n'en font qu'un.
 */
function inline(node: Node): string {
  const tokens: { code: boolean; text: string }[] = [];
  const add = (code: boolean, text: string) => {
    const last = tokens.at(-1);
    if (code && last?.code) last.text += text;
    else tokens.push({ code, text });
  };
  for (const c of node.children) {
    if (!isNode(c)) add(false, c);
    else if (c.tag === "kbd" || c.tag === "code") add(true, textOf(c).trim());
    else if (c.tag === "b" || c.tag === "strong") {
      const t = inline(c).trim();
      add(false, t ? `**${t}**` : "");
    } else if (c.tag === "span" && classes(c).includes("lost")) add(false, "⚠"); // légende « rouge = fonction perdue »
    else if (c.tag === "br") add(false, " ");
    else if (!RAW.has(c.tag)) add(false, inline(c));
  }
  return tokens
    .map((t) => (t.code ? codeSpan(t.text) : t.text))
    .join("")
    .replace(/\s+/g, " ");
}

function cell(node: Node): string {
  const text = inline(node).trim().replaceAll("|", "\\|");
  return classes(node).includes("lost") ? `⚠ ${text}` : text; // cellule rouge = fonction perdue
}

function table(node: Node): string {
  const grid = [...findAll(node, "tr")].map((tr) =>
    tr.children.filter(isNode).filter((c) => c.tag === "td" || c.tag === "th").map((c) => ({ th: c.tag === "th", text: cell(c) })),
  );
  if (grid.length === 0) return "";
  const width = Math.max(...grid.map((r) => r.length));
  let head: string[];
  let body: typeof grid;
  if (grid[0].every((c) => c.th)) {
    head = grid[0].map((c) => c.text);
    body = grid.slice(1);
  } else {
    head = width === 2 ? ["Touche", "Action"] : Array(width).fill(" ");
    body = grid;
  }
  head = [...head, ...Array(width - head.length).fill(" ")];
  const lines = [`| ${head.join(" | ")} |`, "|" + "---|".repeat(width)];
  for (const r of body) {
    const vals = [...r.map((c) => c.text), ...Array(width - r.length).fill("")];
    lines.push(`| ${vals.join(" | ")} |`);
  }
  return lines.join("\n");
}

/** Convertit le contenu d'une section en blocs Markdown. */
function block(node: Node): string {
  const out: string[] = [];
  for (const c of node.children) {
    if (!isNode(c)) {
      if (c.trim()) out.push(c.trim());
      continue;
    }
    const cls = classes(c);
    if (c.tag === "h2") out.push(`## ${inline(c).trim()}`);
    else if (c.tag === "h3") out.push(`### ${inline(c).trim()}`);
    else if (c.tag === "table") out.push(table(c));
    else if (c.tag === "pre") out.push("```\n" + textOf(c).replace(/^\n+|\n+$/g, "") + "\n```");
    else if (c.tag === "ul") out.push([...findAll(c, "li")].map((li) => `- ${inline(li).trim()}`).join("\n"));
    else if (c.tag === "ol") out.push([...findAll(c, "li")].map((li, i) => `${i + 1}. ${inline(li).trim()}`).join("\n"));
    else if (c.tag === "div" && cls.includes("ex")) {
      const label = first(c, "b");
      const title = label ? inline(label).trim() : "Exemple";
      if (label) remove(c, label);
      out.push(`> **${title}** : ${inline(c).trim()}`);
    } else if (c.tag === "div" && cls.includes("formula")) out.push(`> ${inline(c).trim()}`);
    else if (c.tag === "div" || c.tag === "section") out.push(block(c));
    else if (c.tag === "p") out.push(inline(c).trim());
  }
  return out.filter(Boolean).join("\n\n");
}

/** Écrit la version .md de la fiche et renvoie son chemin. */
export function convert(path: string): string {
  const root = parse(readFileSync(path, "utf-8"));
  const title = first(root, "title");
  const parts = [`# ${title ? inline(title).trim() : ""}`];
  [...findAll(root, "div", "sheet")].forEach((sheet, i) => {
    const h1 = first(sheet, "h1");
    const legend = first(sheet, "div", "legend");
    if (i === 0 && legend) {
      const ver = first(legend, "span", "ver");
      if (ver) {
        remove(legend, ver);
        parts.push(`*${inline(ver).trim()}* — ${inline(legend).trim()}`);
      } else {
        parts.push(`*${inline(legend).trim()}*`);
      }
    }
    parts.push(`---\n\n**${h1 ? inline(h1).trim() : ""}**`);
    for (const sec of findAll(sheet, "section")) {
      if (sec.parent?.tag !== "section") parts.push(block(sec));
    }
  });
  const md = (parts.join("\n\n") + "\n").replace(/\n{3,}/g, "\n\n");
  const out = path.replace(/\.html$/, ".md");
  writeFileSync(out, md, "utf-8");
  return out;
}

if (import.meta.main) {
  for (const p of process.argv.slice(2)) console.log(relative(process.cwd(), convert(p)));
}
