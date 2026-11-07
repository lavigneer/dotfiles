# Fake gh for herdr-demo: PR search, PR details and repo clone from
# $HERDR_DEMO_DATA; clones come from the demo's local remotes. Wrapped by Nix.

data="${HERDR_DEMO_DATA:?}"
demo="${HERDR_DEMO:?}"

case "${1:-} ${2:-}" in
"search prs")
  jq '.prs | map({number, title, body, state: "open", url: "https://github.com/\(.repo)/pull/\(.number)", repository: {nameWithOwner: .repo}})' "$data"
  ;;
"pr view")
  ref="${3:-}"
  repo=""
  shift 3
  while [ $# -gt 0 ]; do
    if [ "$1" = "--repo" ]; then repo="${2:-}"; fi
    shift
  done
  jq -e --arg ref "$ref" --arg repo "$repo" '
    .prs[] | select(.repo == $repo and (.branch == $ref or (.number | tostring) == $ref))
    | {number, title, url: "https://github.com/\(.repo)/pull/\(.number)", state: "OPEN",
       isDraft: .draft, reviewDecision: .review, headRefName: .branch,
       statusCheckRollup: [(if .checks == "IN_PROGRESS" then {status: .checks} else {conclusion: .checks} end)]}
  ' "$data" || {
    echo "no pull requests found for branch \"$ref\"" >&2
    exit 1
  }
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
