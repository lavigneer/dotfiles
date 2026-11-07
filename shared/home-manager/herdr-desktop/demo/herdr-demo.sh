# herdr-demo: a separate Herdr app with fake Jira tickets, GitHub PRs and repos,
# for trying the projects/tickets/work mods without touching your own setup.
#
#   herdr-demo           start it (creates the demo the first time)
#   herdr-demo --reset   throw the demo away and start fresh
#   herdr-demo --stop    quit the demo app and its herdr-core session (Linux)
#   herdr-demo --prepare create/refresh the demo without starting the app
#                        (combine with --reset to start over)
#
# Everything lives in $HERDR_DEMO (~/.local/state/herdr-demo): demo repos in
# ws/, their "GitHub" remotes in remotes/, the app's home in app/. The app runs
# with its own HERDR_APP_HOME and herdr-core session (HC_SESSION=herdr-demo), so
# your real spaces, settings and layouts are never touched. jira, gh and the
# agent are fakes answering from data.json. Wrapped by Nix, which defines
# HERDR_DEMO, HERDR_DEMO_DATA, install_mods and install_app_files.

session=herdr-demo

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
}

prepare_only=0
for arg in "$@"; do
  case "$arg" in
  --stop)
    stop
    exit 0
    ;;
  --reset)
    stop >/dev/null
    case "$HERDR_DEMO" in */herdr-demo) rm -rf "$HERDR_DEMO" ;; esac
    ;;
  --prepare) prepare_only=1 ;;
  *)
    echo "usage: herdr-demo [--reset] [--prepare] | --stop" >&2
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
cd "$HERDR_DEMO/ws"
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
  Sidebar    "Work" outline between Spaces and Agents.
  Ctrl+B f   projects picker over the demo repos.
Stop with: herdr-demo --stop     Start over with: herdr-demo --reset
EOF
