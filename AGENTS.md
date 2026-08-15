# Agent git workflow

Commits and PRs from an agent should go through the GitHub App agent
identity, not the human's own account:

```bash
just agent-commit <path-to-message-file>
just agent-pr "<title>" <path-to-body-file> [extra gh pr create flags]
```

This applies by default — use these instead of plain `git commit` /
`gh pr create` without needing to be asked each time.

See `Justfile` for the recipes, and `~/.claude/scripts/justfile-agent-recipes.just`
on this machine for the canonical, shared version they're copied from.
