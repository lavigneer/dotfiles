// Work: a repo -> worktree outline for the Herdr sidebar.
//
// Every worktree of your local repos (open in a space or not), grouped by repo.
// A row shows the Jira ticket its branch names (key, summary, status), its pull
// request (review and checks) and the agent status of its space. Click a row to
// go to its space, or to open one there with the agent. "+" opens the tickets
// popup to start new work. Refreshes git every 30 s (and at once when a space
// opens on a folder it hasn't listed, e.g. one the tickets popup just made),
// pull requests every 2 min and tickets every 10 min.

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { run, spaces, theme } from "herdr";
import * as C from "./config.js";
import { spaceFor } from "./lib.js";
import {
  localRepos,
  repoState,
  keysIn,
  viewTicket,
  prDetails,
  prLabel,
  pool,
} from "./data.js";

const GIT_MS = 30_000;
const PR_MS = 120_000;
const TICKET_MS = 600_000;

export default class Work extends View {
  init(_props, cx) {
    this.groups = null; // [{ repo, worktrees: [{ path, branch, key }] }]
    this.tickets = new Map(); // key -> ticket | null, with .at
    this.prs = new Map(); // path -> pr | null
    this.prsAt = 0;
    this.folded = new Set();
    this.checked = new Set(); // space folders already refreshed for
    this.refresh(cx);
    cx.timer.every(GIT_MS, (cx) => this.refresh(cx));
  }

  // Git only: worktrees and branches. Ticket and PR details follow on their own,
  // so slow Jira/GitHub calls never hold up the next git refresh.
  refresh(cx, force = false) {
    if (this.loading) {
      this.again = { force: force || this.again?.force };
      return;
    }
    this.loading = true;
    cx.spawn(async (cx) => {
      try {
        const repos = (await localRepos()).filter((r) => r.path);
        const states = await pool(
          repos.map((repo) => async () => ({
            repo,
            ...(await repoState(repo)),
          })),
        );
        this.groups = states
          .filter((s) => s?.worktrees.length)
          .map((s) => ({
            repo: s.repo,
            worktrees: s.worktrees.map((w) => ({
              ...w,
              key: keysIn(w.branch)[0] ?? null,
            })),
          }));
        cx.notify();
      } finally {
        this.loading = false;
      }
      cx.notify();
      if (this.again) {
        const again = this.again;
        this.again = null;
        this.refresh(cx, again.force);
      }
      this.loadDetails(cx, force);
    });
  }

  loadDetails(cx, force) {
    if (this.detailing || !this.groups) return;
    this.detailing = true;
    cx.spawn(async (cx) => {
      try {
        await this.details(cx, force);
      } finally {
        this.detailing = false;
      }
      cx.notify();
    });
  }

  // Render runs whenever spaces change. A local space whose folder isn't one of
  // our worktrees may be a new one: refresh now instead of at the next poll.
  // Each folder triggers this once, so ordinary spaces cost one git scan.
  watchSpaces(cx) {
    if (!this.groups) return;
    const known = new Set(
      this.groups.flatMap((g) => g.worktrees.map((w) => w.path)),
    );
    const fresh = spaces()
      .filter((s) => !s.machine && s.folder)
      .map((s) => s.folder.replace(/\/+$/, ""))
      .filter((f) => !known.has(f) && !this.checked.has(f));
    if (!fresh.length) return;
    for (const f of fresh) this.checked.add(f);
    cx.timer.after(0, (cx) => this.refresh(cx));
  }

  async details(cx, force) {
    const now = Date.now();
    const all = this.groups.flatMap((g) =>
      g.worktrees.map((w) => ({ ...w, repo: g.repo })),
    );
    const keys = [...new Set(all.map((w) => w.key).filter(Boolean))].filter(
      (k) =>
        force ||
        !this.tickets.has(k) ||
        now - this.tickets.get(k).at > TICKET_MS,
    );
    const prsDue =
      force ||
      now - this.prsAt > PR_MS ||
      all.some((w) => !this.prs.has(w.path));
    await Promise.all([
      pool(
        keys.map((key) => async () => {
          this.tickets.set(key, {
            ticket: await viewTicket(key),
            at: Date.now(),
          });
          cx.notify();
        }),
      ),
      prsDue
        ? pool(
            all
              .filter((w) => w.repo.slug)
              .map((w) => async () => {
                this.prs.set(w.path, await prDetails(w.repo.slug, w.branch));
                cx.notify();
              }),
          ).then(() => (this.prsAt = Date.now()))
        : null,
    ]);
  }

  open(w) {
    const space = spaceFor(w.path);
    if (space) run("space.select", { id: space.id });
    else
      run("space.new", {
        name: w.key ?? w.branch.split("/").pop(),
        folder: w.path,
        argv: C.AGENT,
      });
  }

  render(cx) {
    this.watchSpaces(cx);
    const t = theme();
    const icon = (name, label, onClick) =>
      div()
        .id(`work-${name}`)
        .h(20)
        .px(5)
        .flex()
        .items_center()
        .rounded(5)
        .text_size(12)
        .text_color(t.dim)
        .cursor_pointer()
        .hover((s) => s.bg(t.hover).text_color(t.foreground))
        .on_click((_e, cx) => {
          cx.stop_propagation();
          onClick(cx);
        })
        .child(label);

    const header = h_flex()
      .h(30)
      .flex_none()
      .px(12)
      .gap(4)
      .items_center()
      .child(
        div()
          .flex_1()
          .text_size(11)
          .font_semibold()
          .text_color(t.dim)
          .child("WORK"),
      )
      .child(icon("refresh", "↻", (cx) => this.refresh(cx, true)))
      .child(icon("new", "+", () => run("mod.open", { name: "tickets" })));

    const status = (space) => {
      if (!space) return div().w(12).flex_none().text_color(t.dim).child("○");
      if (space.status === "working")
        return svg("mods/workspace-chrome/spinner.svg")
          .size(11)
          .flex_none()
          .text_color(t.working)
          .spin(900);
      return div()
        .w(12)
        .flex_none()
        .text_color(t[space.status] ?? t.accent)
        .child("●");
    };

    const row = (w) => {
      const space = spaceFor(w.path);
      const ticket = w.key ? this.tickets.get(w.key)?.ticket : null;
      const pr = prLabel(this.prs.get(w.path));
      const prColor =
        pr?.tone === "bad" ? t.blocked : pr?.tone === "good" ? t.done : t.muted;
      // A key Jira doesn't know (e.g. "UTF-8" in "fix-utf-8") isn't a ticket: show the branch.
      const known = w.key && this.tickets.get(w.key)?.ticket !== null;
      const title = known ? w.key : w.branch;
      const sub = ticket ? ticket.summary : known ? w.branch : "";
      return v_flex()
        .id(`work-${w.path}`)
        .mx(6)
        .px(8)
        .py(4)
        .gap(1)
        .rounded(7)
        .cursor_pointer()
        .when(Boolean(space?.active), (el) => el.bg(t.selected ?? t.hover))
        .hover((s) => s.bg(t.hover))
        .on_click(() => this.open(w))
        .child(
          h_flex()
            .gap(6)
            .items_center()
            .child(status(space))
            .child(
              div()
                .flex_1()
                .truncate()
                .text_size(12.5)
                .text_color(t.foreground)
                .when(Boolean(space?.active), (d) => d.font_semibold())
                .child(title),
            )
            .when(Boolean(pr), (el) =>
              el.child(
                div()
                  .flex_none()
                  .text_size(10.5)
                  .text_color(prColor)
                  .child(pr.text),
              ),
            ),
        )
        .when(Boolean(sub || ticket?.status), (el) =>
          el.child(
            h_flex()
              .pl(18)
              .gap(6)
              .child(
                div()
                  .flex_1()
                  .truncate()
                  .text_size(11)
                  .text_color(t.dim)
                  .child(sub),
              )
              .when(Boolean(ticket?.status), (e) =>
                e.child(
                  div()
                    .flex_none()
                    .text_size(10.5)
                    .text_color(t.dim)
                    .child(ticket.status),
                ),
              ),
          ),
        );
    };

    const group = (g) => {
      const open = !this.folded.has(g.repo.path);
      return v_flex()
        .child(
          h_flex()
            .id(`work-repo-${g.repo.path}`)
            .mx(6)
            .px(6)
            .h(24)
            .gap(5)
            .items_center()
            .rounded(6)
            .cursor_pointer()
            .hover((s) => s.bg(t.hover))
            .on_click((_e, cx) => {
              open
                ? this.folded.add(g.repo.path)
                : this.folded.delete(g.repo.path);
              cx.notify();
            })
            .child(
              svg(
                `mods/workspace-chrome/chevron-${open ? "down" : "right"}.svg`,
              )
                .size(11)
                .flex_none()
                .text_color(t.dim),
            )
            .child(
              div()
                .flex_1()
                .truncate()
                .text_size(12)
                .font_semibold()
                .text_color(t.muted)
                .child(g.repo.name),
            )
            .child(
              div()
                .flex_none()
                .text_size(10.5)
                .text_color(t.dim)
                .child(String(g.worktrees.length)),
            ),
        )
        .when(open, (el) => el.children(g.worktrees.map(row)));
    };

    const body =
      this.groups === null
        ? div()
            .px(14)
            .py(6)
            .text_size(12)
            .text_color(t.dim)
            .child("Loading worktrees…")
        : this.groups.length
          ? v_flex().gap(4).children(this.groups.map(group))
          : div()
              .px(14)
              .py(6)
              .text_size(12)
              .text_color(t.dim)
              .child("No worktrees yet. Press + to start a ticket.");

    return v_flex()
      .id("work")
      .size_full()
      .min_h(0)
      .child(header)
      .child(
        v_flex().flex_1().min_h(0).pb(6).overflow_y_scrollbar().child(body),
      );
  }
}
