# List available recipes
default:
    @just --list

# Remove OS/editor cruft (this repo has no build output to clean)
clean:
    find . -name .DS_Store -delete

# Validate the Client ID Document(s) in docs/ against schema/client-id-document.schema.json
validate:
    python3 -m pip install --quiet -r scripts/requirements.txt
    python3 scripts/validate_client_id_documents.py

# Canonical, corrected Justfile recipes for the GitHub App agent identity
# (see gh-agent-setup skill / gh-app-token.sh). Paste these into a repo's
# Justfile as-is.
#
# Why these look the way they do: `just` interpolates {{...}} as raw,
# unquoted text — it does NOT re-quote variadic *ARGS when joining them,
# and a single named parameter substituted inside quotes is still exposed
# to backtick/`$()` expansion by the shell. So free text (commit messages,
# PR bodies — both routinely contain backticks around `code`) must never
# be interpolated directly; route it through a file instead. Titles are
# short enough that inline text is accepted here, but keep titles free of
# backticks/`$()` too.
#
# First seen breaking in flint (wallaby-dev/flint#27): the original
# version of `agent-pr` took `*ARGS` and interpolated `{{ARGS}}` straight
# into `gh pr create {{ARGS}}` — a multi-word --title got word-split, and
# a --body containing backticks/newlines was re-parsed as shell syntax. It
# also didn't source gh-app.env, so GH_APP_ID etc. were unset.

# Fetch a valid GitHub App installation token (cached, auto-refreshed)
gh-agent-token:
    #!/usr/bin/env bash
    set -euo pipefail
    source ~/.claude/gh-app.env
    ~/.claude/scripts/gh-app-token.sh

# Commit staged changes authored as the agent identity, not the human.
# Takes the message from a file (`git commit -F`) — see header note above.
# `just agent-commit /tmp/msg.txt`
agent-commit msg_file:
    #!/usr/bin/env bash
    set -euo pipefail
    source ~/.claude/gh-app.env
    export GIT_AUTHOR_NAME="${GH_APP_SLUG}[bot]"
    export GIT_AUTHOR_EMAIL="${GH_APP_BOT_ID}+${GH_APP_SLUG}[bot]@users.noreply.github.com"
    export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
    export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
    git commit -F "{{msg_file}}"

# Open a PR authenticated as the agent identity, not the human. Body comes
# from a file for the same reason as agent-commit; title is inline text.
# Extra trailing flags (--draft, --reviewer someone, etc.) must each be a
# single token — no embedded spaces.
# `just agent-pr "Fix foo" /tmp/body.md --draft`
agent-pr title body_file *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    source ~/.claude/gh-app.env
    GH_TOKEN=$(~/.claude/scripts/gh-app-token.sh) gh pr create --title '{{title}}' --body-file "{{body_file}}" {{ARGS}}
