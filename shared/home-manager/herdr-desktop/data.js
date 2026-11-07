// Tickets, repos, worktrees and pull requests, shared by the tickets popup and
// the work outline sidebar. Copied into each mod by Nix (imports can't leave a
// mod's folder). Everything comes from git, gh and jira-cli at their Nix paths.

import { exec } from "herdr";
import * as C from "./config.js";
import { basename } from "./lib.js";

export const firstLine = (text) => (text || "").trim().split("\n")[0];
export const fill = (template, values) =>
  template.replace(/\{(\w+)\}/g, (m, k) => values[k] ?? m);

// Jira keys in a branch name or PR title: "lavigneer/WEB-142-fix" -> ["WEB-142"].
export const keysIn = (text) => [
  ...new Set((text || "").toUpperCase().match(/\b[A-Z][A-Z0-9]+-\d+\b/g) ?? []),
];
export const mentions = (text, key) => keysIn(text).includes(key.toUpperCase());

// Opens a URL in the browser (xdg-open on Linux, open on macOS).
export async function openUrl(url) {
  try {
    await exec("xdg-open", [url]);
  } catch {
    await exec("open", [url]).catch(() => {});
  }
}

// Runs `tasks` (functions returning promises) a few at a time.
export async function pool(tasks, size = 4) {
  const out = new Array(tasks.length);
  let next = 0;
  const worker = async () => {
    while (next < tasks.length) {
      const i = next++;
      out[i] = await tasks[i]().catch(() => null);
    }
  };
  await Promise.all(
    Array.from({ length: Math.min(size, tasks.length) }, worker),
  );
  return out;
}

const git = (cwd, ...args) => exec(C.GIT, args, { cwd });

// "owner/repo" from a GitHub remote URL, or null.
export function slugOf(url) {
  const m = (url || "")
    .trim()
    .match(/github\.com[:/]+([^/\s]+)\/([^/\s]+?)(?:\.git)?\/?$/i);
  return m ? `${m[1]}/${m[2]}` : null;
}

// --- Repos ------------------------------------------------------------------

// Local repos under ROOTS (main checkouts): [{ path, name, slug }].
export async function localRepos() {
  const paths = new Set();
  for (const root of C.ROOTS) {
    const depth = String(C.DEPTH + 1);
    const r = await exec("find", [
      root,
      "-mindepth",
      depth,
      "-maxdepth",
      depth,
      "-name",
      ".git",
      "-prune",
    ]).catch(() => null);
    for (const line of r?.stdout.split("\n") ?? [])
      if (line.endsWith("/.git")) paths.add(line.slice(0, -5));
  }
  const repos = await pool(
    [...paths].map((path) => async () => {
      const r = await git(path, "config", "--get", "remote.origin.url").catch(
        () => null,
      );
      return {
        path,
        name: basename(path),
        slug: r?.code === 0 ? slugOf(r.stdout) : null,
      };
    }),
  );
  return repos.filter(Boolean).sort((a, b) => a.name.localeCompare(b.name));
}

// The main checkout of the repo containing `dir` (also from inside a worktree), or null.
export async function repoRoot(dir) {
  if (!dir) return null;
  const r = await git(
    dir,
    "rev-parse",
    "--path-format=absolute",
    "--git-common-dir",
  ).catch(() => null);
  const common = r?.code === 0 ? r.stdout.trim() : "";
  return common.endsWith("/.git") ? common.slice(0, -5) : null;
}

// A configured target ("owner/repo" or a path) -> local repo, or { slug } when not cloned.
export function findRepo(target, repos) {
  if (!target) return null;
  if (target.startsWith("/") || target.startsWith("~"))
    return (
      repos.find((r) => r.path === target) ?? {
        path: target,
        name: basename(target),
        slug: null,
      }
    );
  return (
    repos.find((r) => r.slug?.toLowerCase() === target.toLowerCase()) ?? {
      path: null,
      name: target.split("/").pop(),
      slug: target,
    }
  );
}

// Worktrees (not the main checkout) and branches of a repo.
export async function repoState(repo) {
  const worktrees = [];
  const wt = await git(repo.path, "worktree", "list", "--porcelain").catch(
    () => null,
  );
  let path = null;
  for (const line of wt?.stdout.split("\n") ?? []) {
    if (line.startsWith("worktree ")) path = line.slice(9);
    else if (
      line.startsWith("branch refs/heads/") &&
      path &&
      path !== repo.path
    )
      worktrees.push({ path, branch: line.slice(18) });
  }
  const branches = new Map(); // name -> { local, remote }
  const refs = await git(
    repo.path,
    "for-each-ref",
    "--format=%(refname)",
    "refs/heads",
    "refs/remotes/origin",
  ).catch(() => null);
  for (const ref of refs?.stdout.split("\n") ?? []) {
    let name, kind;
    if (ref.startsWith("refs/heads/")) [name, kind] = [ref.slice(11), "local"];
    else if (
      ref.startsWith("refs/remotes/origin/") &&
      ref !== "refs/remotes/origin/HEAD"
    )
      [name, kind] = [ref.slice(20), "remote"];
    else continue;
    branches.set(name, { ...(branches.get(name) ?? {}), [kind]: true });
  }
  return { worktrees, branches };
}

// --- Worktrees --------------------------------------------------------------

export const worktreePath = (repo, branch) =>
  `${repo.path}/${C.WORKTREE_DIR}/${branch.split("/").pop()}`;

// Adds a worktree for `branch` and returns its path. Where the branch comes from:
//   1. a local branch of that name;
//   2. origin's branch of that name (tracked);
//   3. with `pr` (a PR number): the PR's head, refs/pull/<pr>/head — for a PR
//      from a fork, or one whose branch was deleted after merging;
//   4. with `create`: a new branch from origin's default branch (new work).
// Anything else is an error: an existing PR or branch never silently becomes an
// empty look-alike branch cut from main.
export async function addWorktree(
  repo,
  branch,
  { create = false, pr = null } = {},
) {
  const path = worktreePath(repo, branch);
  // Keep worktrees out of the main checkout's `git status`.
  const rel = path.slice(repo.path.length + 1);
  if ((await git(repo.path, "check-ignore", "-q", rel)).code !== 0) {
    const common = (
      await git(
        repo.path,
        "rev-parse",
        "--path-format=absolute",
        "--git-common-dir",
      )
    ).stdout.trim();
    await exec("sh", [
      "-c",
      'mkdir -p "$1" && printf "%s\\n" "$2" >> "$1/exclude"',
      "sh",
      `${common}/info`,
      `/${C.WORKTREE_DIR}/`,
    ]);
  }
  // Best effort: offline, local branches still work and new ones start from
  // the last fetched default branch.
  await git(repo.path, "fetch", "--quiet", "origin");
  const has = async (ref) =>
    (await git(repo.path, "show-ref", "--verify", "--quiet", ref)).code === 0;
  const add = (...args) => git(repo.path, "worktree", "add", ...args);
  let r;
  if (await has(`refs/heads/${branch}`)) r = await add(path, branch);
  else if (await has(`refs/remotes/origin/${branch}`))
    r = await add("--track", "-b", branch, path, `origin/${branch}`);
  else if (pr) {
    const f = await git(
      repo.path,
      "fetch",
      "--quiet",
      "origin",
      `pull/${pr}/head:refs/heads/${branch}`,
    );
    if (f.code !== 0)
      throw new Error(
        `${branch} isn't on origin and PR #${pr}'s head couldn't be fetched: ${firstLine(f.stderr)}`,
      );
    r = await add(path, branch);
  } else if (create) {
    const head = await git(
      repo.path,
      "symbolic-ref",
      "--quiet",
      "--short",
      "refs/remotes/origin/HEAD",
    );
    r = await add(
      "--no-track",
      "-b",
      branch,
      path,
      head.code === 0 ? head.stdout.trim() : "HEAD",
    );
  } else throw new Error(`${branch} isn't a local branch or on origin`);
  if (r.code !== 0)
    throw new Error(firstLine(r.stderr) || "git worktree add failed");
  return path;
}

// Clones a repo that isn't local yet into the first root.
export async function cloneRepo(slug) {
  const path = `${C.ROOTS[0]}/${slug.split("/").pop()}`;
  const r = await exec(C.GH, ["repo", "clone", slug, path]);
  if (r.code !== 0)
    throw new Error(firstLine(r.stderr) || `gh repo clone ${slug} failed`);
  return { path, name: basename(path), slug };
}

// --- Jira -------------------------------------------------------------------

const ticketOf = (i) => ({
  key: i.key,
  summary: i.fields?.summary ?? "",
  status: i.fields?.status?.name ?? "",
  components: (i.fields?.components ?? []).map((c) => c.name),
  project: i.key.split("-")[0],
});

export async function listTickets() {
  const r = await exec(C.JIRA, [
    "issue",
    "list",
    "--raw",
    "--jql",
    C.JQL,
    "--order-by",
    "updated",
    "--paginate",
    "0:100",
  ]);
  if (r.code !== 0)
    throw new Error(
      firstLine(r.stderr) || firstLine(r.stdout) || "jira issue list failed",
    );
  return JSON.parse(r.stdout || "[]").map(ticketOf);
}

// Jira or GitHub saying "there's no such thing" (as opposed to failing).
const NOT_FOUND =
  /does not exist|not found|404|no pull requests? found|could not resolve/i;

// One ticket by key: the ticket, or null when Jira doesn't know the key (e.g. a
// key-like branch name such as "fix-utf-8"). Throws when Jira can't be asked,
// so callers can tell "not a ticket" from "Jira is down".
export async function viewTicket(key) {
  const r = await exec(C.JIRA, ["issue", "view", key, "--raw"]);
  if (r.code !== 0) {
    const why = firstLine(r.stderr) || firstLine(r.stdout);
    if (NOT_FOUND.test(why)) return null;
    throw new Error(why || `jira issue view ${key} failed`);
  }
  return ticketOf(JSON.parse(r.stdout));
}

// --- GitHub -----------------------------------------------------------------

// The orgs/users to search: GITHUB_OWNERS plus owners of known repos.
export function owners(repos) {
  const all = new Set(C.GITHUB_OWNERS);
  for (const r of repos) if (r.slug) all.add(r.slug.split("/")[0]);
  for (const t of [
    ...Object.values(C.PROJECTS),
    ...Object.values(C.COMPONENTS),
  ])
    if (/^[^/~][^/]*\/[^/]+$/.test(t)) all.add(t.split("/")[0]);
  return [...all];
}

// PRs mentioning any of `keys` (title or body) across `who`: [{ slug, number, title, state, url }].
export async function searchPRs(keys, who) {
  if (!keys.length || !who.length) return [];
  const chunks = [];
  for (let i = 0; i < keys.length; i += 6) chunks.push(keys.slice(i, i + 6));
  const found = await pool(
    chunks.map((chunk) => async () => {
      const query = chunk.map((k) => `"${k}"`).join(" OR ");
      const args = [
        "search",
        "prs",
        query,
        "--limit",
        "100",
        "--json",
        "number,title,body,state,url,repository",
      ];
      for (const o of who) args.push("--owner", o);
      const r = await exec(C.GH, args);
      return r.code === 0 ? JSON.parse(r.stdout) : [];
    }),
    2,
  );
  return found
    .flat()
    .filter(Boolean)
    .map((p) => ({
      slug: p.repository?.nameWithOwner,
      number: p.number,
      title: p.title,
      text: `${p.title}\n${p.body ?? ""}`,
      state: p.state,
      url: p.url,
    }));
}

const OK = ["SUCCESS", "NEUTRAL", "SKIPPED", "COMPLETED"];
const BAD = [
  "FAILURE",
  "ERROR",
  "TIMED_OUT",
  "CANCELLED",
  "ACTION_REQUIRED",
  "STARTUP_FAILURE",
];
// Details for a PR (number or branch) in `slug`, or null when there is none.
// Throws when GitHub can't be asked, so callers can tell "no PR" from "failed".
export async function prDetails(slug, ref) {
  const r = await exec(C.GH, [
    "pr",
    "view",
    String(ref),
    "--repo",
    slug,
    "--json",
    "number,url,title,state,isDraft,reviewDecision,statusCheckRollup,headRefName",
  ]);
  if (r.code !== 0) {
    const why = firstLine(r.stderr);
    if (NOT_FOUND.test(why)) return null;
    throw new Error(why || `gh pr view ${ref} --repo ${slug} failed`);
  }
  const pr = JSON.parse(r.stdout);
  const results = (pr.statusCheckRollup ?? []).map(
    (c) => c.conclusion || c.state || c.status || "",
  );
  // A result we don't recognise counts as still running, never as passed.
  const checks = !results.length
    ? null
    : results.some((x) => BAD.includes(x))
      ? "failed"
      : results.every((x) => OK.includes(x))
        ? "passed"
        : "pending";
  return {
    slug,
    number: pr.number,
    url: pr.url,
    title: pr.title,
    state: pr.state,
    draft: pr.isDraft,
    review: pr.reviewDecision || null,
    checks,
    branch: pr.headRefName,
  };
}

// "#881 draft approved ✓" and a tone for coloring: "bad" | "good" | null.
export function prLabel(pr) {
  if (!pr) return null;
  const parts = [`#${pr.number}`];
  if (pr.state === "MERGED") parts.push("merged");
  else if (pr.state === "CLOSED") parts.push("closed");
  else {
    if (pr.draft) parts.push("draft");
    if (pr.review === "APPROVED") parts.push("approved");
    else if (pr.review === "CHANGES_REQUESTED") parts.push("changes requested");
    if (pr.checks)
      parts.push({ failed: "✗", pending: "…", passed: "✓" }[pr.checks]);
  }
  const bad = pr.checks === "failed" || pr.review === "CHANGES_REQUESTED";
  const good =
    pr.state === "MERGED" ||
    (pr.review === "APPROVED" &&
      pr.checks !== "failed" &&
      pr.checks !== "pending");
  return { text: parts.join(" "), tone: bad ? "bad" : good ? "good" : null };
}

// --- Putting it together ----------------------------------------------------

// Every piece of work for each ticket key: [{ repo, branch, worktree, pr }], from
// local branches/worktrees whose name mentions the key and PRs that mention it.
export async function workFor(keys, repos, { prs = true } = {}) {
  const states = await pool(
    repos
      .filter((r) => r.path)
      .map((repo) => async () => ({ repo, ...(await repoState(repo)) })),
  );
  const work = new Map(keys.map((k) => [k, []]));
  const add = (key, item) => {
    const list = work.get(key);
    const same = list.find(
      (w) =>
        w.repo.slug === item.repo.slug &&
        w.repo.path === item.repo.path &&
        w.branch &&
        w.branch === item.branch,
    );
    if (same)
      Object.assign(
        same,
        Object.fromEntries(Object.entries(item).filter(([, v]) => v != null)),
      );
    else list.push(item);
  };
  for (const s of states.filter(Boolean)) {
    for (const key of keys) {
      for (const w of s.worktrees)
        if (mentions(w.branch, key))
          add(key, {
            repo: s.repo,
            branch: w.branch,
            worktree: w.path,
            pr: null,
          });
      for (const [name] of s.branches)
        if (mentions(name, key))
          add(key, { repo: s.repo, branch: name, worktree: null, pr: null });
    }
  }
  if (!prs) return work;

  // PRs: the branches we found, plus any PR that mentions the key.
  const found = await searchPRs(keys, owners(repos));
  const lookups = [];
  for (const [key, items] of work) {
    for (const item of items)
      if (item.repo.slug)
        lookups.push({ key, slug: item.repo.slug, ref: item.branch, item });
    for (const p of found.filter((p) => mentions(p.text, key))) {
      if (
        !items.some((i) => i.repo.slug === p.slug && i.pr?.number === p.number)
      )
        lookups.push({ key, slug: p.slug, ref: p.number });
    }
  }
  const details = await pool(
    // A failed lookup just leaves that item without PR details here.
    lookups.map((l) => () => prDetails(l.slug, l.ref)),
  );
  lookups.forEach((l, i) => {
    const pr = details[i];
    if (!pr) return;
    if (l.item) l.item.pr = pr;
    else {
      const repo = findRepo(pr.slug, repos);
      add(l.key, { repo, branch: pr.branch, worktree: null, pr });
    }
  });
  return work;
}

// Where new work on a ticket should go: [{ repo, why }] best first (may be empty).
export function suggestRepos(ticket, repos, here, remembered) {
  const out = [];
  const push = (repo, why) => {
    if (
      repo &&
      !out.some(
        (o) =>
          (o.repo.slug && o.repo.slug === repo.slug) ||
          (o.repo.path && o.repo.path === repo.path),
      )
    )
      out.push({ repo, why });
  };
  if (remembered) push(findRepo(remembered, repos), "last used");
  const byComponent = ticket.components.filter((c) => C.COMPONENTS[c]);
  for (const c of byComponent)
    push(findRepo(C.COMPONENTS[c], repos), `component ${c}`);
  // A component is more specific than the project, so it wins.
  if (!byComponent.length && C.PROJECTS[ticket.project])
    push(
      findRepo(C.PROJECTS[ticket.project], repos),
      `project ${ticket.project}`,
    );
  if (here)
    push(
      repos.find((r) => r.path === here) ?? {
        path: here,
        name: basename(here),
        slug: null,
      },
      "current repo",
    );
  return out;
}
