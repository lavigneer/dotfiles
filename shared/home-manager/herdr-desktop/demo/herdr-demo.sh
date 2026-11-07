# herdr-demo: a separate Herdr app with fake Jira tickets, GitHub PRs and repos,
# for trying the projects/tickets/work mods without touching your own setup.
#
#   herdr-demo           start it (creates the demo the first time)
#   herdr-demo --reset   throw the demo (repos, app home, spaces) away and start fresh
#   herdr-demo --stop    quit the demo app and its herdr-core session (Linux)
#   herdr-demo --prepare create/refresh the demo without starting the app
#                        (combine with --reset to start over)
#
# Playing the reviewers and CI (KEY: a ticket key, for its newest open PR, or
# owner/repo#number):
#   herdr-demo approve KEY             approve it (auto-merge then merges it)
#   herdr-demo comment KEY [N]         leave N unresolved review comments (default 2)
#   herdr-demo request-changes KEY [N] request changes, with N comments
#   herdr-demo fail-ci KEY             fail its running CI (or the next run)
#   herdr-demo status                  the demo's PRs and tickets
#
# To see how the mods cope with Jira being down: touch $HERDR_DEMO/jira-down
# (remove it to bring Jira back).
#
# Everything lives in $HERDR_DEMO (~/.local/state/herdr-demo): demo repos in
# ws/, their "GitHub" remotes in remotes/, the app's home in app/. The app runs
# with its own HERDR_APP_HOME and herdr-core session (HC_SESSION=herdr-demo), so
# your real spaces, settings and layouts are never touched. jira, gh and the
# agent are fakes working on state.json (a copy of data.json). Wrapped by Nix,
# which defines HERDR_DEMO, HERDR_DEMO_DATA, install_mods, install_app_files
# and the state_* helpers (state.sh).

# The herdr-core session is named after the demo folder, so a second demo
# (HERDR_DEMO=…/herdr-demo-2) never stops or resets the first one's.
session=$(basename "$HERDR_DEMO")

stop() {
  found=0
  for pid in $(pgrep -u "$(id -u)" -f 'herdr-app|herdr-core' || true); do
    if tr '\0' '\n' <"/proc/$pid/environ" 2>/dev/null | grep -qx "HC_SESSION=$session"; then
      kill "$pid" 2>/dev/null && found=1
    fi
  done
  [ "$found" = 1 ] && echo "herdr-demo: stopped." || echo "herdr-demo: not running."
}

setup() {
  echo "herdr-demo: creating demo repos in $HERDR_DEMO…"
  mkdir -p "$HERDR_DEMO/remotes" "$HERDR_DEMO/ws" "$HERDR_DEMO/app"
  g() { git -c user.name=herdr-demo -c user.email=demo@example.invalid -c init.defaultBranch=main "$@"; }

  # A "GitHub" remote per repo: main plus any remote-only branches.
  jq -r '(.repos + .uncloned)[] | [.name, .slug, ((.remoteBranches // .branches // []) | join(" "))] | @tsv' "$HERDR_DEMO_DATA" |
    while IFS=$'\t' read -r name slug remote_only; do
      seed="$HERDR_DEMO/seed-$name"
      g init --quiet --bare "$HERDR_DEMO/remotes/$name.git"
      g init --quiet "$seed"
      printf '# %s\n\nDemo repo for herdr-demo (%s).\n' "$name" "$slug" >"$seed/README.md"
      g -C "$seed" add README.md
      g -C "$seed" commit --quiet -m "Initial commit"
      g -C "$seed" push --quiet "$HERDR_DEMO/remotes/$name.git" main
      # Only uncloned repos get their branches on the remote (they're found via PRs).
      if jq -e --arg n "$name" '.uncloned | any(.name == $n)' "$HERDR_DEMO_DATA" >/dev/null; then
        for b in $remote_only; do g -C "$seed" push --quiet "$HERDR_DEMO/remotes/$name.git" "main:refs/heads/$b"; done
      fi
      rm -rf "$seed"
    done

  # PRs from forks: only GitHub's refs/pull/<n>/head, no branch on origin.
  jq -r '.prs[] | select(.fork) | [(.repo | split("/")[1]), .number] | @tsv' "$HERDR_DEMO_DATA" |
    while IFS=$'\t' read -r name number; do
      g -C "$HERDR_DEMO/remotes/$name.git" update-ref "refs/pull/$number/head" refs/heads/main
    done

  # Local clones with worktrees and branches, as if you'd been working on them.
  jq -r '.repos[] | [.name, .slug, (.worktrees | join(" ")), (.branches | join(" "))] | @tsv' "$HERDR_DEMO_DATA" |
    while IFS=$'\t' read -r name slug worktrees branches; do
      repo="$HERDR_DEMO/ws/$name"
      g clone --quiet "$HERDR_DEMO/remotes/$name.git" "$repo"
      g -C "$repo" remote set-url origin "https://github.com/$slug.git"
      g -C "$repo" config "url.$HERDR_DEMO/remotes/$name.git.insteadOf" "https://github.com/$slug.git"
      g -C "$repo" remote set-head origin main
      printf '/.claude/worktrees/\n' >>"$repo/.git/info/exclude"
      for b in $worktrees; do g -C "$repo" worktree add --quiet -b "$b" "$repo/.claude/worktrees/${b##*/}" origin/main; done
      for b in $branches; do g -C "$repo" branch --quiet --no-track "$b" origin/main; done
    done

  # Branches with a PR are on "GitHub" too (fork PRs only as refs/pull/<n>/head).
  jq -r '.prs[] | select(.fork | not) | [(.repo | split("/")[1]), .branch] | @tsv' "$HERDR_DEMO_DATA" |
    while IFS=$'\t' read -r name branch; do
      if [ -d "$HERDR_DEMO/ws/$name" ] && g -C "$HERDR_DEMO/ws/$name" show-ref --verify --quiet "refs/heads/$branch"; then
        g -C "$HERDR_DEMO/ws/$name" push --quiet origin "$branch"
      fi
    done

  # The demo's "Jira and GitHub", changed as you work. CI already running
  # finishes in a minute.
  install -m 644 "$HERDR_DEMO_DATA" "$HERDR_DEMO/state.json"
  state_set '(.prs[] | select(.checks == "IN_PROGRESS")) |= (.checksDoneAt = (now + 60) | .checksResult = "SUCCESS")'
}

# The open PR for KEY (by branch or title; the newest if several), or for an
# exact "owner/repo#number", as "repo<TAB>number".
pr_for() {
  state_tick
  state_jq -r --arg key "$1" '
    [.prs[] | select((.state // "OPEN") == "OPEN"
                     and ("\(.repo)#\(.number)" == $key
                          or (.branch | ascii_upcase | contains($key))
                          or (.title | contains($key))))]
    | max_by(.number) // empty | [.repo, .number] | @tsv'
}

# Reviewer and CI commands (see the top).
review() {
  local cmd="$1" key="${2:-}" n="${3:-2}" pr repo number
  if [ "$cmd" = status ]; then
    state_tick
    state_jq -r '.prs[] | "\(.repo)#\(.number)  \(.branch)  \(.state // "OPEN")\(if .draft then " draft" else "" end)  review:\(.review)  checks:\(.checks)\(if .autoMerge then " auto-merge" else "" end)  comments:\(.unresolved // 0)"'
    echo
    state_jq -r '.tickets[] | "\(.key)  \(.status)  \(.summary)"'
    return
  fi
  [ -n "$key" ] || {
    echo "usage: herdr-demo $cmd KEY" >&2
    exit 2
  }
  pr="$(pr_for "$key")"
  [ -n "$pr" ] || {
    echo "herdr-demo: no open PR for $key" >&2
    exit 1
  }
  IFS=$'\t' read -r repo number <<<"$pr"
  local sel=".repo == \"$repo\" and .number == $number"
  case "$cmd" in
  approve) state_set "(.prs[] | select($sel)).review = \"APPROVED\"" ;;
  comment) state_set "(.prs[] | select($sel)).unresolved += $n" ;;
  request-changes) state_set "(.prs[] | select($sel)) |= (.review = \"CHANGES_REQUESTED\" | .unresolved += $n)" ;;
  fail-ci) state_set "(.prs[] | select($sel)) |= (if .checks == \"IN_PROGRESS\" then .checksResult = \"FAILURE\" else .failNext = true end)" ;;
  esac
  state_tick
  echo "herdr-demo: $cmd $repo#$number"
}

case "${1:-}" in
approve | comment | request-changes | fail-ci | status)
  review "$@"
  exit 0
  ;;
esac

prepare_only=0
for arg in "$@"; do
  case "$arg" in
  --stop)
    stop
    exit 0
    ;;
  --reset)
    stop >/dev/null
    case "$HERDR_DEMO" in */herdr-demo*) rm -rf "$HERDR_DEMO" ;; esac
    # herdr-core keeps the session's spaces and terminals on its own (Linux path).
    rm -rf "${XDG_STATE_HOME:-$HOME/.local/state}/herdr-core/$session"
    ;;
  --prepare) prepare_only=1 ;;
  *)
    echo "usage: herdr-demo [--reset] [--prepare] | --stop | approve|comment|request-changes|fail-ci KEY | status" >&2
    exit 2
    ;;
  esac
done

[ -d "$HERDR_DEMO/ws" ] || setup

# The demo's own app home: our mods (pointed at the demo), keys, look, layout.
install_app_files "$HERDR_DEMO/app"
install_mods "$HERDR_DEMO/app/mods"
sed -i "s|@HERDR_DEMO@|$HERDR_DEMO|g" "$HERDR_DEMO"/app/mods/*/config.js
if [ "$prepare_only" = 1 ]; then
  echo "herdr-demo: prepared in $HERDR_DEMO"
  exit 0
fi

export HERDR_APP_HOME="$HERDR_DEMO/app" HC_SESSION="$session" HERDR_APP_ID="$session" GIT_TERMINAL_PROMPT=0
cd "$HERDR_DEMO/ws" || exit 1
setsid herdr-app >"$HERDR_DEMO/app.log" 2>&1 </dev/null &

# Switch the demo window to the work layout once it's listening.
for _ in $(seq 1 40); do
  if [ -S "$HERDR_APP_HOME/herdr-app.sock" ] && herdr-app "do" layout.switch --name work >/dev/null 2>&1; then
    break
  fi
  sleep 0.5
done

cat <<EOF
herdr-demo: started (log: $HERDR_DEMO/app.log).
  Ctrl+B t   tickets popup: WEB-105 starts straight away (component Fern),
             WEB-101 has two branches and a PR, WEB-104's PR is in an uncloned
             repo (clones it), PLAT-9 has no repo (pick one).
  Sidebar    "Work": each worktree with its next step (Draft PR, Fix CI,
             Address comments, Ready, Merge, Finish).
  Ctrl+B f   projects picker over the demo repos.
The whole flow with WEB-105: start it, Draft PR, wait for CI (${DEMO_CI_SECONDS:-20}s),
  herdr-demo comment WEB-105 → Address comments → Ready →
  herdr-demo approve WEB-105 (auto-merge merges it) → Finish.
Stop with: herdr-demo --stop     Start over with: herdr-demo --reset
EOF
