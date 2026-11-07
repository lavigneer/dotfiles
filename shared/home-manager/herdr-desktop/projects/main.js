// Projects: a sessionizer for the Herdr app.
//
// Lists the git repos under the configured roots (config.js, written by Nix),
// filtered as you type. Enter goes to the space already open on that repo, or
// opens a new space there. Opened with mod.open:projects (prefix+f).
//
// Keys: type to filter, Up/Down or Ctrl+N/Ctrl+P to move, Enter to open, Esc to close.

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import {
  exec,
  home,
  panes,
  spaces,
  run,
  theme,
  props,
  closeOverlay,
} from "herdr";
import { ROOTS, DEPTH } from "./config.js";

const basename = (p) => p.replace(/\/+$/, "").split("/").pop();
const inside = (dir, repo) => dir === repo || dir.startsWith(repo + "/");

// Subsequence match ("dtf" matches "dotfiles"); a lower score is a better match.
function score(text, query) {
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

// Repos at exactly DEPTH below a root: <root>/<repo>/.git (a dir, or a file for worktrees).
async function scan() {
  const found = new Set();
  for (const root of ROOTS) {
    const depth = String(DEPTH + 1);
    try {
      const r = await exec("find", [
        root,
        "-mindepth",
        depth,
        "-maxdepth",
        depth,
        "-name",
        ".git",
        "-prune",
      ]);
      for (const line of r.stdout.split("\n")) {
        if (line.endsWith("/.git")) found.add(line.slice(0, -"/.git".length));
      }
    } catch {
      // A missing root just contributes nothing.
    }
  }
  return [...found].sort((a, b) => basename(a).localeCompare(basename(b)));
}

// The local space already working in a repo: its start folder, else any of its terminals.
function spaceFor(repo) {
  const local = spaces().filter((s) => !s.machine);
  const byFolder = local.find((s) => s.folder && inside(s.folder, repo));
  if (byFolder) return byFolder;
  const live = panes();
  return local.find((s) => {
    const tabs = new Set(s.tabs.map((t) => t.id));
    return live.some((p) => tabs.has(p.tab) && p.cwd && inside(p.cwd, repo));
  });
}

export default class Projects extends View {
  init(_props, cx) {
    this.filter = "";
    this.at = 0;
    this.repos = null; // null while the first scan runs
    this.input = InputState.new({ placeholder: "Open a project…" });
    this.input.on("change", (_e, cx) => {
      this.filter = this.input.value();
      this.at = 0;
      cx.notify();
    });
    this.input.on("submit", () => this.go(this.rows()[this.at]));
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    this.handle = cx.focus_handle();
    cx.spawn(async (cx) => {
      this.repos = await scan();
      cx.notify();
    });
  }

  close() {
    closeOverlay(props().overlay);
  }

  rows() {
    const rows = [];
    for (const path of this.repos ?? []) {
      const name = basename(path);
      const s = score(name, this.filter) ?? score(path, this.filter);
      if (s === null) continue;
      rows.push({ path, name, score: s, space: spaceFor(path) });
    }
    // Best match first; among equals, repos with an open space, then by name.
    rows.sort(
      (a, b) =>
        a.score - b.score ||
        Boolean(b.space) - Boolean(a.space) ||
        a.name.localeCompare(b.name),
    );
    return rows;
  }

  go(r) {
    if (!r) return;
    this.close();
    const open = spaceFor(r.path);
    if (open) run("space.select", { id: open.id });
    else run("space.new", { name: r.name, folder: r.path });
  }

  render() {
    const t = theme();
    const rows = this.rows();
    this.at = Math.max(0, Math.min(this.at, rows.length - 1));
    const sel = rows[this.at];
    const tilde = (p) =>
      p.startsWith(home()) ? "~" + p.slice(home().length) : p;

    const row = (r) =>
      h_flex()
        .id(`pj-${r.path}`)
        .mx(4)
        .px(10)
        .h(32)
        .rounded(7)
        .gap(10)
        .items_center()
        .cursor_pointer()
        .when(r === sel, (el) => el.bg(t.hover))
        .hover((s) => s.bg(t.hover))
        .on_click(() => this.go(r))
        .child(
          div()
            .w(12)
            .flex_none()
            .text_color(r.space ? t.accent : t.dim)
            .child(r.space ? "●" : "·"),
        )
        .child(
          div()
            .flex_none()
            .text_color(t.foreground)
            .when(Boolean(r.space?.active), (d) => d.font_semibold())
            .child(r.name),
        )
        .child(
          div()
            .flex_1()
            .truncate()
            .text_size(11)
            .text_color(t.dim)
            .child(tilde(r.path)),
        )
        .when(Boolean(r.space), (el) =>
          el.child(div().text_size(11).text_color(t.dim).child("open")),
        );

    const empty =
      this.repos === null
        ? "Scanning…"
        : rows.length
          ? null
          : this.repos.length
            ? "No matching project"
            : `No git repos in ${ROOTS.map(tilde).join(", ")}`;

    return v_flex()
      .id("projects")
      .track_focus(this.handle)
      .w_full()
      .min_h(0)
      .p(18)
      .gap(10)
      .bg(t.popover)
      .text_size(13)
      .on_key_down((e, cx) => {
        const k = e.key;
        const n = rows.length || 1;
        if (k === "escape") return this.close();
        if (k === "down" || (k === "n" && e.modifiers.control))
          this.at = (this.at + 1) % n;
        else if (k === "up" || (k === "p" && e.modifiers.control))
          this.at = (this.at + n - 1) % n;
        else return;
        cx.stop_propagation();
        cx.notify();
      })
      .child(
        h_flex()
          .items_center()
          .child(
            div()
              .flex_1()
              .text_size(15)
              .font_semibold()
              .text_color(t.foreground)
              .child("Projects"),
          )
          .child(div().text_size(11).text_color(t.dim).child("Esc")),
      )
      .child(
        h_flex()
          .h(36)
          .flex_none()
          .px(10)
          .gap(8)
          .items_center()
          .rounded(9)
          .border_1()
          .border_color(t.accent)
          .bg(t.background)
          .child(
            svg("mods/workspace-chrome/search.svg").size(15).text_color(t.dim),
          )
          .child(
            Input.new(this.input)
              .flex_1()
              .h_full()
              .text_size(12.8)
              .text_color(t.foreground),
          ),
      )
      .child(
        empty
          ? div().px(10).py(8).text_color(t.dim).child(empty)
          : v_flex()
              .h(Math.min(420, 6 + rows.length * 32))
              .min_h(0)
              .flex_shrink(1)
              .pb(6)
              .overflow_y_scrollbar()
              .children(rows.map(row)),
      );
  }
}
