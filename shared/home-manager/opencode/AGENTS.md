# Shell Command Conventions

## git commit messages
Use `-m "..."` directly — never `"$(cat <<'EOF' ... EOF)"`. Bash scans for balanced
quotes inside `$(...)`, so apostrophes and backticks in the content cause eval errors.

## gh pr create --body
Write to a temp file and use `--body-file` to avoid quoting issues with markdown
(backticks, apostrophes):

```bash
cat > /tmp/pr-body.md << 'EOF'
body content here
EOF
gh pr create --title "..." --body-file /tmp/pr-body.md
```

## sed
Prefer the `edit` tool over sed for file modifications. When sed is needed in a
pipeline, use GNU form — GNU sed 4.9 is installed:

```bash
sed -i 's/old/new/g' file     # correct: GNU sed
sed -i '' 's/old/new/g' file  # wrong: BSD/macOS form, do not use
```

# Attribution

Do not add "Generated with opencode", "Co-Authored-By", or any similar tool
attribution to commit messages or pull request descriptions.
