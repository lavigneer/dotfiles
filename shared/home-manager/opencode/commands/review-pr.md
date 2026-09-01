---
description: Runs a comprehensive pull-request review with specialized agents.
agent: build
---

Review the current changes using the pr-review-toolkit agents.

First inspect `git status`, `git diff --name-only`, and the applicable project
instructions. Use the requested aspects from `$ARGUMENTS`; otherwise run the
general code review and any applicable focused reviews:

- `code`: code-reviewer
- `tests`: pr-test-analyzer
- `comments`: comment-analyzer
- `errors`: silent-failure-hunter
- `types`: type-design-analyzer
- `simplify`: code-simplifier
- `all`: every applicable review

Delegate independent reviews with `Task` in parallel when practical. Then
aggregate the results into Critical Issues, Important Issues, Suggestions,
Positive Observations, and a short recommended action plan. Include exact file
and line references. Do not modify code unless the user explicitly asks for
the simplify aspect to apply changes.
