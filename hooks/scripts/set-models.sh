#!/usr/bin/env bash
# Choose the model each Noctia agent runs on, or show the choices.
# Usage: set-models.sh show | reset | ROLE=MODEL ...   (run from the project root)
# ROLE: reader, architect, security-reviewer, developer, tester, or lead (the main session).
# MODEL: opus, sonnet, haiku, fable, or default (drop the choice).
# Agent choices go to .noctia/models. The lead's choice goes to the "model" setting of .claude/settings.local.json.
set -eu

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
STATE_DIR="$PROJECT_DIR/.noctia"
STATE_FILE="$STATE_DIR/models"
SETTINGS_FILE="$PROJECT_DIR/.claude/settings.local.json"

AGENTS="reader architect security-reviewer developer tester"
VALUES="opus sonnet haiku fable default"
LEAD_VALUES="$VALUES"
LEAD_KEY=model
LEAD_DEFAULT_LABEL="your /model"

# shellcheck source=lib-choices.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-choices.sh"

# default_value AGENT: print the model written in the agent's own file.
default_value() {
  sed -n 's/^model:[[:space:]]*//p' "$PLUGIN_ROOT/agents/$1.md" | head -1
}

run_choices "$@"
