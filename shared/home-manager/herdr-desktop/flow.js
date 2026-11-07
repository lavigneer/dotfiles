// The ticket workflow after the worktree exists, for the Work sidebar:
//
//   no PR ─► draft (CI …/✗/✓, comments) ─► ready ─► approved ─► merged ─► finished
//
// A worktree's stage is derived from its pull request every time (nothing is
// stored), and each stage offers its next steps:
//   Draft PR / Fix CI / Address comments   sent to the space's agent as
//                                          /draft-pr, /fix-ci, /address-comments
//                                          (Claude Code commands in ../claude-commands)
//   Ready     gh pr ready; auto-merge (web UI's default method) when reviews
//             are required, so it merges on approval; Jira -> TRANSITIONS.review
//   Merge     when approved and green but auto-merge is off
//   Finish    after the merge: close its space, remove the worktree and local
//             branch (refused if anything isn't in the PR), Jira -> TRANSITIONS.done
//             unless other work on the ticket is still open
// Copied into each mod by Nix, like data.js.

import { agents, exec, panes, run, spaces, terminals } from "herdr";
import * as C from "./config.js";
import { basename, inside, spaceFor } from "./lib.js";
import {
  assertClean,
  markReady,
  mergePr,
  moveTicket,
  prDetails,
  removeWorktree,
} from "./data.js";

// --- Stage ------------------------------------------------------------------

// pr: prDetails() plus `unresolved` (a count, or null when unknown).
export function stageOf(pr) {
  if (!pr) return "no-pr";
  if (pr.state === "MERGED") return "merged";
  if (pr.state === "CLOSED") return "closed";
  if (pr.draft) return "draft";
  return pr.review === "APPROVED" ? "approved" : "in-review";
}

// The next steps for a worktree: [{ id, label, kind: "agent" | "direct" }].
// `working`: its agent is busy, so nothing is sent to it.
export function nextSteps(pr, { working = false } = {}) {
  const stage = stageOf(pr);
  const steps = [];
  const agent = (id, label) => {
    if (!working) steps.push({ id, label, kind: "agent" });
  };
  if (stage === "no-pr") agent("draft-pr", "Draft PR");
  if (["draft", "in-review", "approved"].includes(stage)) {
    if (pr.checks === "failed") agent("fix-ci", "Fix CI");
    if (pr.unresolved > 0)
      agent(
        "address-comments",
        `Address ${pr.unresolved} comment${pr.unresolved === 1 ? "" : "s"}`,
      );
    else if (pr.review === "CHANGES_REQUESTED")
      agent("address-comments", "Address review");
  }
  if (
    stage === "draft" &&
    pr.checks !== "failed" &&
    pr.checks !== "pending" &&
    !pr.unresolved
  )
    steps.push({ id: "ready", label: "Ready", kind: "direct" });
  if (
    stage === "approved" &&
    pr.checks !== "failed" &&
    pr.checks !== "pending" &&
    !pr.autoMerge
  )
    steps.push({ id: "merge", label: "Merge", kind: "direct" });
  if (stage === "merged")
    steps.push({
      id: "finish",
      label: "Finish",
      kind: "direct",
      confirm: true,
    });
  if (stage === "closed")
    steps.push({
      id: "clean-up",
      label: "Clean up",
      kind: "direct",
      confirm: true,
    });
  return steps;
}

// What the row says about where things stand.
export function stageLabel(pr) {
  const stage = stageOf(pr);
  if (stage === "no-pr") return null;
  if (stage === "draft") return "draft";
  if (stage === "in-review")
    return pr.autoMerge ? "in review · auto-merge" : "in review";
  if (stage === "approved")
    return pr.autoMerge ? "approved · merging" : "approved";
  return stage;
}

// --- The agent --------------------------------------------------------------

// The agent terminal in a space: one reporting its status (Claude Code does),
// else one running the configured agent program, else one labelled agent=…
// (`hc label`; the demo's fake agent does that).
export function agentIn(space) {
  if (!space) return null;
  const tabs = new Set(space.tabs.map((t) => t.id));
  const reported = agents().find((a) => a.space === space.id);
  if (reported) return reported.address;
  const ours = basename(C.AGENT[0]);
  const here = panes().filter((p) => tabs.has(p.tab) && p.terminal);
  const byProgram = here.find((p) => p.program?.key === ours);
  if (byProgram) return byProgram.terminal;
  const labelled = new Set(
    terminals()
      .filter((t) => t.labels?.agent)
      .map((t) => t.address),
  );
  return here.find((p) => labelled.has(p.terminal))?.terminal ?? null;
}

// Sends `/<command>` to the worktree's agent, or starts one with it.
async function tellAgent(w, command) {
  const text = `/${command}`;
  const space = spaceFor(w.path);
  const address = agentIn(space);
  if (address) {
    const r = await exec(C.HC, ["send", address, text]);
    if (r.code !== 0)
      throw new Error(
        `couldn't reach the agent: ${(r.stderr || "").trim().split("\n")[0]}`,
      );
    run("space.select", { id: space.id });
  } else if (space)
    run("tab.new", {
      space: space.id,
      folder: w.path,
      argv: C.AGENT,
      task: text,
    });
  else
    run("space.new", {
      name: w.key ?? basename(w.path),
      folder: w.path,
      argv: C.AGENT,
      task: text,
    });
}

// --- Steps ------------------------------------------------------------------

// Runs step `id` for worktree `w` ({ path, branch, key, repo }) whose PR is
// `pr`. `others`: the other worktrees with their PRs ([{ w, pr }]), to tell
// whether the ticket still has open work. Returns a short note for the row, or
// throws.
export async function runStep(id, w, pr, others = []) {
  if (["draft-pr", "fix-ci", "address-comments"].includes(id)) {
    await tellAgent(w, id);
    return `sent /${id}`;
  }
  if (id === "ready") {
    await markReady(w.repo.slug, pr.number);
    const notes = ["ready for review"];
    // Auto-merge only waits for what the repo requires; without required
    // reviews it would merge at once, so then leave merging to the Merge step.
    const now = await prDetails(w.repo.slug, pr.number);
    if (
      now?.review === "REVIEW_REQUIRED" ||
      now?.review === "CHANGES_REQUESTED"
    ) {
      await mergePr(w.repo.slug, pr.number, { auto: true });
      notes.push("auto-merge on approval");
    }
    if (w.key && C.TRANSITIONS.review) {
      await moveTicket(w.key, C.TRANSITIONS.review);
      notes.push(`${w.key} → ${C.TRANSITIONS.review}`);
    }
    return notes.join(" · ");
  }
  if (id === "merge") {
    await mergePr(w.repo.slug, pr.number);
    return "merged";
  }
  if (id === "finish" || id === "clean-up") {
    await assertClean(w.path, pr?.head ?? null);
    // Its spaces end with it (the agent's work is in the PR by now).
    for (const s of spaces())
      if (!s.machine && s.folder && inside(s.folder, w.path))
        run("space.close", { id: s.id, confirmed: true });
    await removeWorktree(w.repo, w.path, w.branch, pr?.head ?? null);
    const notes = ["worktree removed"];
    if (id === "finish" && w.key && C.TRANSITIONS.done) {
      const open = others.filter(
        (o) =>
          o.w.key === w.key && !["merged", "closed"].includes(stageOf(o.pr)),
      );
      if (open.length)
        notes.push(
          `${w.key} left open: ${open.map((o) => basename(o.w.path)).join(", ")} still in progress`,
        );
      else {
        await moveTicket(w.key, C.TRANSITIONS.done, C.RESOLUTION);
        notes.push(`${w.key} → ${C.TRANSITIONS.done}`);
      }
    }
    return notes.join(" · ");
  }
  throw new Error(`unknown step ${id}`);
}
