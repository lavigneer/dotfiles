# Fake gh for herdr-demo: PR search and details, ready, merge (with auto-merge),
# review threads, the repo's merge method and repo clone, from the demo's state
# (state.sh); clones come from the demo's local remotes. Wrapped by Nix.

demo="${HERDR_DEMO:?}"
state_tick

# `--repo <slug>` among the remaining arguments.
repo_arg() {
  while [ $# -gt 0 ]; do
    if [ "$1" = "--repo" ]; then
      echo "${2:-}"
      return
    fi
    shift
  done
}

# The PR in <slug> whose number or branch is <ref>, as JSON (exit 1 if none).
find_pr() {
  state_jq -e -c --arg ref "$2" --arg repo "$1" '
    [.prs[] | select(.repo == $repo and (.branch == $ref or (.number | tostring) == $ref))]
    | sort_by(if (.state // "OPEN") == "OPEN" then 0 else 1 end) | first // empty'
}

case "${1:-} ${2:-}" in
"search prs")
  state_jq '.prs | map({number, title, body, state: ((.state // "OPEN") | ascii_downcase), url: "https://github.com/\(.repo)/pull/\(.number)", repository: {nameWithOwner: .repo}})'
  ;;
"pr view")
  slug="$(repo_arg "$@")"
  pr="$(find_pr "$slug" "${3:-}")" || {
    echo "no pull requests found for branch \"${3:-}\"" >&2
    exit 1
  }
  head="$(pr_head "${slug##*/}" "$(jq -r .branch <<<"$pr")" "$(jq -r .number <<<"$pr")")"
  jq --arg head "$head" '
    {number, title, url: "https://github.com/\(.repo)/pull/\(.number)",
     state: (.state // "OPEN"), isDraft: .draft, reviewDecision: .review,
     headRefName: .branch, headRefOid: $head,
     autoMergeRequest: (if .autoMerge then {enabledAt: "now"} else null end),
     statusCheckRollup: [(if .checks == "IN_PROGRESS" then {status: .checks} else {conclusion: .checks} end)]}
  ' <<<"$pr"
  ;;
"pr ready")
  slug="$(repo_arg "$@")"
  find_pr "$slug" "${3:-}" >/dev/null || {
    echo "no pull request ${3:-} in $slug" >&2
    exit 1
  }
  state_set --arg repo "$slug" --arg n "${3:-}" '(.prs[] | select(.repo == $repo and (.number | tostring) == $n)).draft = false'
  echo "✓ Pull request $slug#${3:-} is marked as \"ready for review\""
  ;;
"pr merge")
  slug="$(repo_arg "$@")"
  pr="$(find_pr "$slug" "${3:-}")" || {
    echo "no pull request ${3:-} in $slug" >&2
    exit 1
  }
  case " $* " in
  *" --auto "*)
    state_set --arg repo "$slug" --arg n "${3:-}" '(.prs[] | select(.repo == $repo and (.number | tostring) == $n)).autoMerge = true'
    state_tick
    echo "✓ Pull request $slug#${3:-} will be automatically merged when all requirements are met"
    ;;
  *)
    if [ "$(jq -r '.draft' <<<"$pr")" = true ]; then
      echo "Pull request $slug#${3:-} is still a draft" >&2
      exit 1
    fi
    state_set --arg repo "$slug" --arg n "${3:-}" '(.prs[] | select(.repo == $repo and (.number | tostring) == $n)) |= (.state = "MERGED" | .justMerged = true)'
    delete_merged_branches
    echo "✓ Merged pull request $slug#${3:-}"
    ;;
  esac
  ;;
"repo view")
  # The demo's repos default to squash in the web UI.
  echo "SQUASH"
  ;;
"api graphql")
  # Only the unresolved-review-threads query: answer with the count (--jq applied).
  owner="" name="" number=""
  for a in "$@"; do
    case "$a" in
    owner=*) owner="${a#owner=}" ;;
    name=*) name="${a#name=}" ;;
    number=*) number="${a#number=}" ;;
    esac
  done
  state_jq --arg repo "$owner/$name" --arg n "$number" '[.prs[] | select(.repo == $repo and (.number | tostring) == $n)][0].unresolved // 0'
  ;;
"repo clone")
  slug="${3:?}"
  path="${4:?}"
  name="${slug##*/}"
  git clone --quiet "$demo/remotes/$name.git" "$path"
  git -C "$path" remote set-url origin "https://github.com/$slug.git"
  git -C "$path" config "url.$demo/remotes/$name.git.insteadOf" "https://github.com/$slug.git"
  ;;
*)
  echo "herdr-demo gh: unsupported: $*" >&2
  exit 1
  ;;
esac
