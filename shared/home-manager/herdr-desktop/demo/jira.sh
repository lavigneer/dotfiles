# Fake jira-cli for herdr-demo: answers the calls the tickets/work mods make
# from $HERDR_DEMO_DATA. Wrapped by Nix (writeShellApplication).

data="${HERDR_DEMO_DATA:?}"
issue='{key, fields: {summary, status: {name: .status}, components: (.components | map({name: .}))}}'

if [ -e "${HERDR_DEMO:?}/jira-down" ]; then
  echo "Error: Get \"https://jira.example.invalid/rest/api/2/...\": dial tcp: connection refused" >&2
  exit 1
fi

case "${1:-} ${2:-}" in
"issue list")
  jq ".tickets | map($issue)" "$data"
  ;;
"issue view")
  jq -e --arg key "${3:-}" ".tickets[] | select(.key == \$key) | $issue" "$data" ||
    {
      echo "Error: issue ${3:-} does not exist" >&2
      exit 1
    }
  ;;
"open "*)
  echo "https://jira.example.invalid/browse/${2:-}"
  ;;
*)
  echo "herdr-demo jira: unsupported: $*" >&2
  exit 1
  ;;
esac
