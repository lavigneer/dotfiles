# Shared by the demo's fake jira, gh and agent, and herdr-demo itself: the demo's
# "Jira and GitHub" live in $HERDR_DEMO/state.json (a copy of data.json made by
# setup, then changed as you work). CI runs take $DEMO_CI_SECONDS and pass
# unless `herdr-demo fail-ci` said otherwise; PRs with auto-merge on merge once
# approved and green, and GitHub deletes their branch.

state="${HERDR_DEMO:?}/state.json"
DEMO_CI_SECONDS="${DEMO_CI_SECONDS:-20}"

# state_jq [jq options...] <filter>: read the state.
state_jq() {
  [ -e "$state" ] || install -m 644 "${HERDR_DEMO_DATA:?}" "$state"
  jq "$@" "$state"
}

# state_set [jq options...] <filter>: change the state (one writer at a time).
state_set() {
  local tmp
  [ -e "$state" ] || install -m 644 "${HERDR_DEMO_DATA:?}" "$state"
  exec 9>"$state.lock"
  flock 9
  tmp="$(mktemp "$state.XXXXXX")"
  if jq "$@" "$state" >"$tmp"; then mv "$tmp" "$state"; else rm -f "$tmp"; fi
  flock -u 9
}

# A new CI run for the PR(s) matching <select filter>.
ci_start() {
  state_set "(.prs[] | select($1)) |= (.checks = \"IN_PROGRESS\" | .checksDoneAt = (now + $DEMO_CI_SECONDS) | .checksResult = (if .failNext then \"FAILURE\" else \"SUCCESS\" end) | .failNext = false)"
}

# Time passes: finish CI runs that are due, then merge what auto-merge can.
state_tick() {
  state_set '
    .prs |= map(
      (if .checks == "IN_PROGRESS" and (.checksDoneAt // 0) <= now
       then .checks = .checksResult else . end)
      | (if (.state // "OPEN") == "OPEN" and .autoMerge and (.draft | not)
            and .review == "APPROVED" and .checks == "SUCCESS"
         then .state = "MERGED" | .justMerged = true else . end))'
  delete_merged_branches
}

# GitHub deletes a merged PR's branch (its refs/pull/<n>/head stays).
delete_merged_branches() {
  local merged remote name branch number
  merged="$(state_jq -r '.prs[] | select(.justMerged) | [(.repo | split("/")[1]), .branch, .number] | @tsv')"
  [ -n "$merged" ] || return 0
  while IFS=$'\t' read -r name branch number; do
    remote="$HERDR_DEMO/remotes/$name.git"
    pr_head "$name" "$branch" "$number" >/dev/null
    git -C "$remote" update-ref -d "refs/heads/$branch" 2>/dev/null || true
  done <<<"$merged"
  state_set '.prs |= map(del(.justMerged))'
}

# The commit a PR's branch points at on the "GitHub" remote (its head).
# Like GitHub, refs/pull/<n>/head follows the branch while it exists.
pr_head() { # <repo name> <branch> <number>
  local remote="$HERDR_DEMO/remotes/$1.git" head
  if head="$(git -C "$remote" rev-parse --quiet --verify "refs/heads/$2" 2>/dev/null)"; then
    git -C "$remote" update-ref "refs/pull/$3/head" "$head"
    echo "$head"
  else
    git -C "$remote" rev-parse --quiet --verify "refs/pull/$3/head" 2>/dev/null || true
  fi
}
