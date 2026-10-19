#!/usr/bin/env bash
# Choose how hard each Noctia agent thinks (effort level), or show the choices.
# Usage: set-effort.sh show | reset | ROLE=LEVEL ...   (run from the project root)
# ROLE: reader, architect, security-reviewer, developer, tester, or lead (the main session).
# LEVEL: low, medium, high, xhigh, max, or default (drop the choice). The lead cannot take max.
# Agent choices go to .noctia/effort. The lead's choice goes to the "effortLevel" setting of .claude/settings.local.json.
set -eu

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
STATE_DIR="$PROJECT_DIR/.noctia"
STATE_FILE="$STATE_DIR/effort"
SETTINGS_FILE="$PROJECT_DIR/.claude/settings.local.json"

AGENTS="reader architect security-reviewer developer tester"
VALUES="low medium high xhigh max default"
LEAD_VALUES="low medium high xhigh default"
LEAD_KEY=effortLevel
LEAD_DEFAULT_LABEL="your /effort"

# shellcheck source=lib-choices.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-choices.sh"

# default_value AGENT: print the effort written in the agent's own file.
default_value() {
  sed -n 's/^effort:[[:space:]]*//p' "$PLUGIN_ROOT/agents/$1.md" | head -1
}

run_choices "$@"
