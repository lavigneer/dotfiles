// Work: a repo -> worktree outline for the Herdr sidebar.
//
// Every worktree of your local repos (open in a space or not), grouped by repo.
// A row shows the Jira ticket its branch names (key, summary, status), its pull
// request (review and checks) and the agent status of its space. Click a row to
// go to its space, or to open one there with the agent. "+" opens the tickets
// popup to start new work; ↻ refreshes everything now.
//
// State:
//   git refresh, details   each runs one at a time; a request during a run
//                          queues one more (serial()), merging "force"
//   tickets, prs           caches of { state: "found" | "none" | "failed",
//                          value, at }; "failed" (Jira/GitHub unreachable) is
//                          retried after a minute and never shown as "none"
//   watched                folders of spaces not yet listed as worktrees,
//                          rechecked a few times (the tickets popup makes the
//                          worktree first; an agent may make it later)
// Git refreshes every 30 s and at once for a new space; PRs every 2 min,
// tickets every 10 min.

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
const RETRY_MS = 60_000; // after a failed Jira/GitHub lookup
const WATCH_MS = 3_000; // between rechecks of a new space's folder
const WATCH_TRIES = 3;

// Runs `body(cx, force)` one at a time. Asked again while running, it runs once
// more afterwards (forced if any of the requests was), rather than dropping it.
function serial(body) {
  let running = false;
  let queued = null; // null | { force }
  const start = (cx, force = false) => {
    if (running) {
      queued = { force: force || Boolean(queued?.force) };
      return;
    }
    running = true;
    cx.spawn(async (cx) => {
      try {
        await body(cx, force);
      } finally {
        running = false;
        const next = queued;
        queued = null;
        if (next) start(cx, next.force);
      }
    });
  };
  return start;
}

// A cache entry is due when missing, forced, failed a while ago, or old.
const due = (entry, force, maxAge, now) =>
  !entry ||
  force ||
  now - entry.at > (entry.state === "failed" ? RETRY_MS : maxAge);

// Looks something up into `cache[id]`: found / none (null) / failed. A failure
// keeps the last good value so a blip doesn't blank the row.
async function lookup(cache, id, f) {
  try {
    const value = await f();
    cache.set(id, { state: value ? "found" : "none", value, at: Date.now() });
  } catch {
    const last = cache.get(id);
    cache.set(id, {
      state: "failed",
      value: last?.value ?? null,
      at: Date.now(),
    });
  }
}

export default class Work extends View {
  init(_props, cx) {
    this.groups = null; // null until the first scan; [{ repo, worktrees: [{ path, branch, key }] }]
    this.mainCheckouts = new Set();
    this.tickets = new Map(); // key -> entry (see lookup)
    this.prs = new Map(); // worktree path -> entry
    this.folded = new Set();
    this.watched = new Map(); // space folder -> tries
    this.watchTimer = false;
    this.refresh = serial((cx, force) => this.scan(cx, force));
    this.details = serial((cx, force) => this.lookups(cx, force));
    this.refresh(cx);
    cx.timer.every(GIT_MS, (cx) => this.refresh(cx));
  }

  // Git only: worktrees and branches. Ticket and PR details follow separately,
  // so slow Jira/GitHub calls never hold up the next git refresh.
  async scan(cx, force) {
    const repos = (await localRepos()).filter((r) => r.path);
    const states = await pool(
      repos.map((repo) => async () => ({
        repo,
        ...(await repoState(repo)),
      })),
    );
    this.mainCheckouts = new Set(repos.map((r) => r.path));
    this.groups = states
      .filter((s) => s?.worktrees.length)
      .map((s) => ({
        repo: s.repo,
        worktrees: s.worktrees.map((w) => ({
          ...w,
          key: keysIn(w.branch)[0] ?? null,
        })),
      }));
    this.recheckWatched(cx);
    cx.notify();
    this.details(cx, force);
  }

  async lookups(cx, force) {
    if (!this.groups) return;
    const now = Date.now();
    const all = this.groups.flatMap((g) =>
      g.worktrees.map((w) => ({ ...w, repo: g.repo })),
    );
    const keys = [...new Set(all.map((w) => w.key).filter(Boolean))].filter(
      (k) => due(this.tickets.get(k), force, TICKET_MS, now),
    );
    const prs = all.filter(
      (w) => w.repo.slug && due(this.prs.get(w.path), force, PR_MS, now),
    );
    await Promise.all([
      pool(
        keys.map((key) => async () => {
          await lookup(this.tickets, key, () => viewTicket(key));
          cx.notify();
        }),
      ),
      pool(
        prs.map((w) => async () => {
          await lookup(this.prs, w.path, () =>
            prDetails(w.repo.slug, w.branch),
          );
          cx.notify();
        }),
      ),
    ]);
  }

  // Render runs whenever spaces change. A local space whose folder isn't one of
  // our worktrees (nor a main checkout) may be a new worktree: refresh now
  // rather than at the next poll, and recheck a few times in case it appears
  // a little later.
  watchSpaces(cx) {
    if (!this.groups) return;
    const known = this.knownFolders();
    const fresh = spaces()
      .filter((s) => !s.machine && s.folder)
      .map((s) => s.folder.replace(/\/+$/, ""))
      .filter((f) => !known.has(f) && !this.watched.has(f));
    if (!fresh.length) return;
    for (const f of fresh) this.watched.set(f, 0);
    cx.timer.after(0, (cx) => this.refresh(cx));
  }

  knownFolders() {
    return new Set([
      ...this.mainCheckouts,
      ...this.groups.flatMap((g) => g.worktrees.map((w) => w.path)),
    ]);
  }

  // After a scan: folders now listed are done; the rest get another try soon.
  recheckWatched(cx) {
    const known = this.knownFolders();
    let again = false;
    for (const [f, tries] of this.watched) {
      if (known.has(f)) this.watched.delete(f);
      else if (tries + 1 < WATCH_TRIES) {
        this.watched.set(f, tries + 1);
        again = true;
      } else this.watched.set(f, WATCH_TRIES); // given up: the 30 s poll covers it
    }
    if (again && !this.watchTimer) {
      this.watchTimer = true;
      cx.timer.after(WATCH_MS, (cx) => {
        this.watchTimer = false;
        this.refresh(cx);
      });
    }
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
      const entry = w.key ? this.tickets.get(w.key) : null;
      const ticket = entry?.value ?? null;
      const pr = prLabel(this.prs.get(w.path)?.value);
      const prColor =
        pr?.tone === "bad" ? t.blocked : pr?.tone === "good" ? t.done : t.muted;
      // Only a key Jira says it doesn't know (e.g. "UTF-8" in "fix-utf-8") isn't
      // a ticket: then show the branch. Not looked up yet, or Jira unreachable:
      // still the key.
      const isTicket = Boolean(w.key) && entry?.state !== "none";
      const title = isTicket ? w.key : w.branch;
      const sub = ticket
        ? ticket.summary
        : isTicket
          ? entry?.state === "failed"
            ? `${w.branch} · Jira unreachable`
            : w.branch
          : "";
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
