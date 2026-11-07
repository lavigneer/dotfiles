# Fake agent for herdr-demo: shows the task it was given (Herdr types it in as
# the first message), then leaves you a shell in the worktree.

echo "herdr-demo: fake agent in $PWD"
echo "Waiting for the task (Herdr types it in)…"
if IFS= read -r task; then
  echo "Task: $task"
fi
echo "Branch: $(git branch --show-current 2>/dev/null || echo '?')"
exec "${SHELL:-sh}" -i
