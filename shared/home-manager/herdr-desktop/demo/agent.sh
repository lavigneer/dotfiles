# Fake agent for herdr-demo: shows the task it was given (Herdr passes it as
# the last argument, as with `claude "<task>"`), then leaves you a shell in the
# worktree. Spaces reopened on an existing worktree get no task.

echo "herdr-demo: fake agent in $PWD"
echo "Branch: $(git branch --show-current 2>/dev/null || echo '?')"
if [ $# -gt 0 ]; then
  echo "Task: ${*: -1}"
else
  echo "No task (existing worktree)."
fi
exec "${SHELL:-sh}" -i
