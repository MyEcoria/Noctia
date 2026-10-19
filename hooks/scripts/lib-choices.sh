#!/usr/bin/env bash
# Shared logic of set-models.sh and set-effort.sh: per-role choices stored in the project.
# Agent choices go to STATE_FILE (one ROLE=VALUE per line). The lead's choice goes to the LEAD_KEY setting of SETTINGS_FILE.
# The calling script sets, before sourcing this file: PROJECT_DIR, SETTINGS_FILE, STATE_DIR, STATE_FILE, AGENTS,
# VALUES (what an agent accepts), LEAD_VALUES (what the lead accepts), LEAD_KEY, LEAD_DEFAULT_LABEL,
# and defines default_value AGENT (the value written in the agent's own file).

# shellcheck source=lib-settings.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-settings.sh"

# in_list WORD LIST: succeed if WORD is one of the space-separated words of LIST.
in_list() {
  case " $2 " in *" $1 "*) return 0 ;; *) return 1 ;; esac
}

# stored_value AGENT: print the value chosen for the agent, or nothing.
stored_value() {
  [ -f "$STATE_FILE" ] || return 0
  grep "^$1=" "$STATE_FILE" | tail -1 | cut -d= -f2 || true
}

# store_value AGENT VALUE: remember the choice, or drop it when VALUE is default.
store_value() {
  local others
  mkdir -p "$STATE_DIR"
  echo '*' > "$STATE_DIR/.gitignore"
  others=$( { grep -v "^$1=" "$STATE_FILE" 2>/dev/null || true; } )
  { [ -z "$others" ] || echo "$others"; [ "$2" = default ] || echo "$1=$2"; } > "$STATE_FILE"
}

# store_lead VALUE: set the lead's value for next sessions, or drop it when VALUE is default.
store_lead() {
  if [ "$1" = default ]; then unset_top_setting "$LEAD_KEY"; else set_top_setting "$LEAD_KEY" "$1"; fi
}

# check_choice CHOICE: succeed if CHOICE reads ROLE=VALUE with a known role and a value that role accepts.
check_choice() {
  local role="${1%%=*}" value="${1#*=}" accepted="$VALUES"
  if [ "$role" = "$1" ] || { [ "$role" != lead ] && ! in_list "$role" "$AGENTS"; }; then
    echo "Unknown role in '$1'. Roles: lead $AGENTS" >&2; return 1
  fi
  [ "$role" = lead ] && accepted="$LEAD_VALUES"
  in_list "$value" "$accepted" || { echo "Unknown value in '$1' for $role. Accepted: $accepted" >&2; return 1; }
}

# apply_choice CHOICE: store one ROLE=VALUE choice.
apply_choice() {
  local role="${1%%=*}" value="${1#*=}"
  if [ "$role" = lead ]; then store_lead "$value"; else store_value "$role" "$value"; fi
}

# show_row ROLE CHOSEN DEFAULT: print one line of the table.
show_row() {
  if [ -n "$2" ]; then printf '%-18s %-8s (your choice)\n' "$1" "$2"; else printf '%-18s %-8s (default)\n' "$1" "$3"; fi
}

# show_choices: print the value of every role.
show_choices() {
  local agent
  show_row lead "$(read_setting "$LEAD_KEY")" "$LEAD_DEFAULT_LABEL"
  for agent in $AGENTS; do
    show_row "$agent" "$(stored_value "$agent")" "$(default_value "$agent")"
  done
}

# reset_choices: drop every choice.
reset_choices() {
  rm -f "$STATE_FILE"
  store_lead default
}

# run_choices ARGS...: show | reset | ROLE=VALUE ... Every choice is checked before any is stored.
run_choices() {
  local choice
  case "${1:-show}" in
    show) ;;
    reset) reset_choices ;;
    *)
      for choice in "$@"; do check_choice "$choice" || exit 1; done
      for choice in "$@"; do apply_choice "$choice"; done ;;
  esac
  show_choices
}
