// Tickets: Jira ticket -> git worktree -> coding agent, for the Herdr app.
//
// Lists your Jira tickets (JQL in config.js) with the work already linked to
// each: branches and worktrees whose name has the key, and pull requests that
// mention it, across your repos and GitHub owners. Enter on a ticket:
//   - nothing yet, and one obvious repo: create the worktree (BRANCH_PREFIX + key
//     under WORKTREE_DIR), open a space there and start the agent with the ticket;
//   - otherwise: choose from its work (open the space, or add a worktree for a
//     branch or PR), start it in a suggested repo (component / project maps, last
//     used, current repo) or any other repo, or ask the agent for another branch.
// Repos that aren't cloned yet are cloned into the first root with gh.
//
// Keys: type to filter, Up/Down or Ctrl+N/Ctrl+P to move, Enter to choose,
// Esc to go back or close, Ctrl+O to open the ticket in the browser, Ctrl+R to reload.
// Opened with mod.open:tickets (prefix+t).

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import {
  exec,
  focused,
  run,
  theme,
  props,
  closeOverlay,
  shared,
  setShared,
} from "herdr";
import * as C from "./config.js";
import { score, spaceFor, moveKey } from "./lib.js";
import {
  listTickets,
  localRepos,
  repoRoot,
  workFor,
  suggestRepos,
  addWorktree,
  cloneRepo,
  prLabel,
  fill,
  firstLine,
  openUrl,
} from "./data.js";

const REMEMBER = "tickets.repo"; // shared: ticket key -> repo slug or path

const repoId = (repo) => repo.slug || repo.path;
const repoLabel = (repo) => repo.slug || repo.name;

export default class Tickets extends View {
  init(_props, cx) {
    this.filter = "";
    this.at = 0;
    this.stage = null; // null: the ticket list; else { ticket, pickRepo? }
    this.tickets = null; // null while loading
    this.repos = [];
    this.work = new Map(); // key -> [{ repo, branch, worktree, pr }]
    this.workLoaded = false;
    this.error = null;
    this.busy = null;
    this.input = InputState.new({ placeholder: "Find a ticket…" });
    this.input.on("change", (_e, cx) => {
      this.filter = this.input.value();
      this.at = 0;
      cx.notify();
    });
    this.input.on("submit", (_e, cx) => this.choose(this.rows()[this.at], cx));
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    this.handle = cx.focus_handle();
    this.load(cx);
  }

  load(cx) {
    this.tickets = null;
    this.workLoaded = false;
    this.error = null;
    const cwd = focused()?.cwd ?? null;
    cx.spawn(async (cx) => {
      try {
        const [tickets, repos, here] = await Promise.all([
          listTickets(),
          localRepos(),
          repoRoot(cwd),
        ]);
        this.tickets = tickets;
        this.repos = repos;
        this.here = here;
        cx.notify();
        this.work = await workFor(
          tickets.map((t) => t.key),
          repos,
        );
        this.workLoaded = true;
      } catch (e) {
        this.error = `${e.message ?? e}`;
        this.tickets ??= [];
      }
      cx.notify();
    });
  }

  close() {
    closeOverlay(props().overlay);
  }

  clearFilter() {
    this.filter = "";
    this.input.set_value("");
    this.at = 0;
  }

  back() {
    if (!this.stage) return this.close();
    this.stage = this.stage.pickRepo ? { ticket: this.stage.ticket } : null;
    this.clearFilter();
  }

  // --- Rows ---------------------------------------------------------------

  rows() {
    const f = this.filter;
    const keep = (rows, text) =>
      rows
        .map((r) => ({ r, s: score(text(r), f) }))
        .filter((x) => x.s !== null)
        .sort((a, b) => a.s - b.s)
        .map((x) => x.r);
    if (!this.stage) {
      return keep(
        (this.tickets ?? []).map((t) => ({
          kind: "ticket",
          ticket: t,
          work: this.work.get(t.key) ?? [],
        })),
        (r) => `${r.ticket.key} ${r.ticket.summary}`,
      );
    }
    const t = this.stage.ticket;
    if (this.stage.pickRepo) {
      return keep(
        this.repos.map((repo) => ({
          kind: "start",
          ticket: t,
          repo,
          why: repo.path === this.here ? "current repo" : "",
        })),
        (r) => `${r.repo.name} ${r.repo.slug ?? ""}`,
      );
    }
    const work = this.work.get(t.key) ?? [];
    const rows = work.map((item) => ({ kind: "item", ticket: t, item }));
    const used = new Set(work.map((w) => repoId(w.repo)));
    for (const s of suggestRepos(
      t,
      this.repos,
      this.here,
      (shared(REMEMBER) ?? {})[t.key],
    )) {
      if (!used.has(repoId(s.repo)))
        rows.push({ kind: "start", ticket: t, repo: s.repo, why: s.why });
    }
    rows.push({ kind: "pick", ticket: t });
    for (const repo of new Map(
      work.filter((w) => w.repo.path).map((w) => [w.repo.path, w.repo]),
    ).values()) {
      rows.push({ kind: "another", ticket: t, repo });
    }
    return keep(rows, (r) => this.rowText(r));
  }

  rowText(r) {
    if (r.kind === "item")
      return `${repoLabel(r.item.repo)} ${r.item.branch ?? ""} ${r.item.pr ? `#${r.item.pr.number}` : ""}`;
    if (r.kind === "start")
      return `start in ${repoLabel(r.repo)} ${r.why ?? ""}`;
    if (r.kind === "pick") return "start in another repo";
    if (r.kind === "another") return `another branch in ${repoLabel(r.repo)}`;
    return "";
  }

  // --- Actions ------------------------------------------------------------

  choose(r, cx) {
    if (!r || this.busy) return;
    if (r.kind === "ticket") {
      const suggestions = suggestRepos(
        r.ticket,
        this.repos,
        this.here,
        (shared(REMEMBER) ?? {})[r.ticket.key],
      );
      // A fresh ticket with one clear home: just start.
      if (
        this.workLoaded &&
        !r.work.length &&
        // The current repo is only a hint; a single mapped/remembered repo decides.
        suggestions.filter((x) => x.why !== "current repo").length === 1 &&
        suggestions[0].why !== "current repo" &&
        suggestions[0].repo.path
      ) {
        return this.act(cx, `Creating worktree for ${r.ticket.key}…`, (cx) =>
          this.start(r.ticket, suggestions[0].repo, cx),
        );
      }
      this.stage = { ticket: r.ticket };
      this.clearFilter();
      return;
    }
    if (r.kind === "pick") {
      this.stage = { ticket: r.ticket, pickRepo: true };
      this.clearFilter();
      return;
    }
    if (r.kind === "item")
      return this.act(cx, `Opening ${r.ticket.key}…`, (cx) =>
        this.openItem(r.ticket, r.item, cx),
      );
    if (r.kind === "start")
      return this.act(
        cx,
        `Creating worktree for ${r.ticket.key} in ${repoLabel(r.repo)}…`,
        (cx) => this.start(r.ticket, r.repo, cx),
      );
    if (r.kind === "another") return this.another(r.ticket, r.repo);
  }

  // Runs an async action, showing `busy` meanwhile and any error after.
  act(cx, busy, f) {
    this.busy = busy;
    this.error = null;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        await f(cx);
      } catch (e) {
        this.error = `${e.message ?? e}`;
      }
      this.busy = null;
      cx.notify();
    });
  }

  remember(ticket, repo) {
    setShared(REMEMBER, {
      ...(shared(REMEMBER) ?? {}),
      [ticket.key]: repoId(repo),
    });
  }

  async local(repo, cx) {
    if (repo.path) return repo;
    this.busy = `Cloning ${repo.slug}…`;
    cx.notify();
    const cloned = await cloneRepo(repo.slug);
    this.repos.push(cloned);
    return cloned;
  }

  openSpace(name, folder, task) {
    this.close();
    const open = spaceFor(folder);
    if (open) run("space.select", { id: open.id });
    else
      run("space.new", {
        name,
        folder,
        argv: C.AGENT,
        ...(task ? { task } : {}),
      });
  }

  spaceName(ticket, repo) {
    const others = (this.work.get(ticket.key) ?? []).filter(
      (w) => repoId(w.repo) !== repoId(repo),
    );
    return others.length ? `${ticket.key} ${repo.name}` : ticket.key;
  }

  async start(ticket, target, cx) {
    const repo = await this.local(target, cx);
    const branch = C.BRANCH_PREFIX + ticket.key;
    const existing = (this.work.get(ticket.key) ?? []).find(
      (w) => w.repo.path === repo.path && w.branch === branch && w.worktree,
    );
    const path = existing?.worktree ?? (await addWorktree(repo, branch));
    this.remember(ticket, repo);
    this.openSpace(
      this.spaceName(ticket, repo),
      path,
      existing
        ? null
        : fill(C.TASK, { key: ticket.key, summary: ticket.summary }),
    );
  }

  async openItem(ticket, item, cx) {
    if (item.worktree)
      return this.openSpace(this.spaceName(ticket, item.repo), item.worktree);
    if (!item.branch) {
      // A PR whose branch we can't check out: show it instead.
      if (item.pr?.url) await openUrl(item.pr.url);
      return this.close();
    }
    const repo = await this.local(item.repo, cx);
    const path = await addWorktree(repo, item.branch);
    this.remember(ticket, repo);
    this.openSpace(this.spaceName(ticket, repo), path);
  }

  // The agent names and creates the extra branch itself (BRANCH_PREFIX + key + short description).
  another(ticket, repo) {
    this.close();
    run("space.new", {
      name: `${ticket.key} ${repo.name}+`,
      folder: repo.path,
      argv: C.AGENT,
      task: fill(C.EXTRA_BRANCH_TASK, {
        key: ticket.key,
        summary: ticket.summary,
        prefix: C.BRANCH_PREFIX,
        worktreeDir: C.WORKTREE_DIR,
      }),
    });
  }

  openInBrowser(key, cx) {
    cx.spawn(async () => {
      const r = await exec(C.JIRA, ["open", key, "--no-browser"]).catch(
        () => null,
      );
      const url = r?.stdout.trim();
      if (url) await openUrl(url);
    });
  }

  // --- Drawing ------------------------------------------------------------

  render() {
    const t = theme();
    const rows = this.rows();
    this.at = Math.max(0, Math.min(this.at, rows.length - 1));
    const sel = rows[this.at];
    const tone = (label) =>
      label?.tone === "bad"
        ? t.blocked
        : label?.tone === "good"
          ? t.done
          : t.muted;
    const small = (text, color = t.dim) =>
      div().flex_none().text_size(11).text_color(color).child(text);
    const dot = (on) =>
      div()
        .w(12)
        .flex_none()
        .text_color(on ? t.accent : t.dim)
        .child(on ? "●" : "·");

    const line = (r, i, cells) =>
      h_flex()
        .id(`tk-${i}-${r.kind}`)
        .mx(4)
        .px(10)
        .h(32)
        .rounded(7)
        .gap(10)
        .items_center()
        .cursor_pointer()
        .when(r === sel, (el) => el.bg(t.hover))
        .hover((s) => s.bg(t.hover))
        .on_click((_e, cx) => this.choose(r, cx))
        .children(cells.filter(Boolean));

    const row = (r, i) => {
      if (r.kind === "ticket") {
        const pr = r.work.map((w) => prLabel(w.pr)).find(Boolean);
        const where = [...new Set(r.work.map((w) => w.repo.name))];
        return line(r, i, [
          dot(r.work.some((w) => w.worktree)),
          div()
            .w(100)
            .flex_none()
            .font_semibold()
            .text_color(t.foreground)
            .child(r.ticket.key),
          div()
            .flex_1()
            .truncate()
            .text_color(t.foreground)
            .child(r.ticket.summary),
          where.length
            ? small(
                where.length > 2 ? `${where.length} repos` : where.join(", "),
              )
            : null,
          pr ? small(pr.text, tone(pr)) : null,
          small(r.ticket.status),
        ]);
      }
      if (r.kind === "item") {
        const pr = prLabel(r.item.pr);
        const open = r.item.worktree && spaceFor(r.item.worktree);
        return line(r, i, [
          dot(Boolean(r.item.worktree)),
          div()
            .w(150)
            .flex_none()
            .truncate()
            .text_color(t.foreground)
            .child(repoLabel(r.item.repo)),
          div()
            .flex_1()
            .truncate()
            .text_color(t.muted)
            .child(r.item.branch ?? r.item.pr?.title ?? ""),
          pr ? small(pr.text, tone(pr)) : null,
          small(
            open
              ? "open"
              : r.item.worktree
                ? "worktree"
                : r.item.repo.path
                  ? "branch"
                  : "not cloned",
          ),
        ]);
      }
      const label =
        r.kind === "start"
          ? `Start in ${repoLabel(r.repo)}${r.repo.path ? "" : " (clone)"}`
          : r.kind === "pick"
            ? "Start in another repo…"
            : `Ask ${C.AGENT[0]} for another branch in ${repoLabel(r.repo)}`;
      return line(r, i, [
        div().w(12).flex_none().text_color(t.dim).child("+"),
        div().flex_1().truncate().text_color(t.foreground).child(label),
        r.why ? small(r.why) : null,
      ]);
    };

    const title = this.stage
      ? `${this.stage.ticket.key}  ${this.stage.ticket.summary}`
      : "Tickets";
    let message = this.busy ?? this.error;
    if (!message && this.tickets === null) message = "Loading tickets…";
    else if (!message && !rows.length)
      message = this.stage
        ? "Nothing matches"
        : this.tickets.length
          ? "No matching ticket"
          : "No tickets for this query";
    else if (!message && !this.stage && !this.workLoaded)
      message = "Looking for branches and pull requests…";

    return v_flex()
      .id("tickets")
      .track_focus(this.handle)
      .w_full()
      .min_h(0)
      .p(18)
      .gap(10)
      .bg(t.popover)
      .text_size(13)
      .on_key_down((e, cx) => {
        const ticket = this.stage?.ticket ?? sel?.ticket;
        if (e.modifiers.control && e.key === "o" && ticket)
          this.openInBrowser(ticket.key, cx);
        else if (e.modifiers.control && e.key === "r") this.load(cx);
        else if (!moveKey(e, this, rows.length, () => this.back())) return;
        cx.stop_propagation();
        cx.notify();
      })
      .child(
        h_flex()
          .gap(10)
          .items_center()
          .child(
            div()
              .flex_1()
              .truncate()
              .text_size(15)
              .font_semibold()
              .text_color(t.foreground)
              .child(title),
          )
          .child(
            small(
              this.stage ? "Esc back" : "Ctrl+O browser · Ctrl+R reload · Esc",
            ),
          ),
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
      .when(Boolean(message), (el) =>
        el.child(
          div()
            .px(10)
            .py(4)
            .text_color(this.error && !this.busy ? t.blocked : t.dim)
            .child(firstLine(message)),
        ),
      )
      .when(rows.length > 0, (el) =>
        el.child(
          v_flex()
            .h(Math.min(420, 6 + rows.length * 32))
            .min_h(0)
            .flex_shrink(1)
            .pb(6)
            .overflow_y_scrollbar()
            .children(rows.map(row)),
        ),
      );
  }
}
