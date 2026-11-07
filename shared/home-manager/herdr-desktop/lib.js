// Helpers shared by the projects and tickets mods. herdr-app only resolves
// imports inside a mod's own folder, so Nix copies this file into each one.

import { panes, spaces } from "herdr";

export const basename = (p) => p.replace(/\/+$/, "").split("/").pop();
export const inside = (dir, root) => dir === root || dir.startsWith(root + "/");

// Subsequence match ("dtf" matches "dotfiles"); a lower score is a better match,
// null is no match.
export function score(text, query) {
  if (!query) return 0;
  const t = text.toLowerCase();
  const q = query.toLowerCase();
  const direct = t.indexOf(q);
  if (direct >= 0) return direct;
  let at = -1;
  let gaps = 0;
  for (const ch of q) {
    const next = t.indexOf(ch, at + 1);
    if (next < 0) return null;
    gaps += next - at - 1;
    at = next;
  }
  return 100 + gaps;
}

// The local space already working in `dir`: its start folder, else any of its terminals.
export function spaceFor(dir) {
  const local = spaces().filter((s) => !s.machine);
  const byFolder = local.find((s) => s.folder && inside(s.folder, dir));
  if (byFolder) return byFolder;
  const live = panes();
  return local.find((s) => {
    const tabs = new Set(s.tabs.map((t) => t.id));
    return live.some((p) => tabs.has(p.tab) && p.cwd && inside(p.cwd, dir));
  });
}

// Up/Down and Ctrl+N/Ctrl+P move a selection through `n` rows; Esc calls `close`.
// Returns true when it handled the key.
export function moveKey(e, view, n, close) {
  const k = e.key;
  if (k === "escape") {
    close();
    return true;
  }
  if (k === "down" || (k === "n" && e.modifiers.control))
    view.at = (view.at + 1) % Math.max(n, 1);
  else if (k === "up" || (k === "p" && e.modifiers.control))
    view.at = (view.at + Math.max(n, 1) - 1) % Math.max(n, 1);
  else return false;
  return true;
}
