#!/usr/bin/env zsh
# Auto-rename herdr panes and tabs to the program running in them, like tmux's
# automatic-rename. Herdr has no built-in equivalent, so this polls each pane's
# foreground process over the socket API and writes the label when it differs
# from what herdr already shows.
#
#   pane label -> "nvim"
#   tab label  -> "2:nvim"   (position kept, tmux #I:#W style)
#
# Herdr's own tab-bar extras (the zoom Z, agent status dots) are drawn outside
# the label, so they are untouched. Tabs you named yourself are left alone:
# only labels that are a bare position ("2") or our own "2:prog" are managed.
#
# Started automatically from .zshrc when inside herdr. Run manually with:
#   ~/.config/herdr/herdr-auto-rename.sh
#
# Tunables (env):
#   HERDR_RENAME_INTERVAL        poll seconds (default 2)
#   HERDR_RENAME_TABS            0 = panes only (default 1)
#   HERDR_RENAME_CLEAR_ON_SHELL  1 = idle shells show no program (default 0)

emulate -L zsh
setopt pipe_fail

INTERVAL=${HERDR_RENAME_INTERVAL:-2}
RENAME_TABS=${HERDR_RENAME_TABS:-1}
CLEAR_ON_SHELL=${HERDR_RENAME_CLEAR_ON_SHELL:-0}

# Wrappers that are never the interesting program: look past them to the
# process they launched (or fall back to the outermost one).
typeset -a SKIP
SKIP=(sh bash zsh env sudo doas caffeinate nice time xargs script)

command -v herdr >/dev/null || exit 0
command -v jq >/dev/null || exit 0

SKIP_JSON=$(printf '%s\n' "${SKIP[@]}" | jq -R . | jq -sc .)

pane_program() {
  herdr pane process-info --pane "$1" 2>/dev/null | jq -r --argjson skip "$SKIP_JSON" '
    .result.process_info.foreground_processes // []
    | map(.name | sub("^-"; ""))
    | (map(select(. as $n | $skip | index($n) | not)) | first) // (last // empty)
  ' 2>/dev/null
}

# The pane herdr considers active inside a tab; for a lone pane, itself.
tab_focused_pane() {
  local -a members
  members=(${=1})
  (( ${#members} > 1 )) || { print -r -- "${members[1]}"; return }
  herdr pane layout --pane "${members[1]}" 2>/dev/null \
    | jq -r '.result.layout.focused_pane_id // empty' 2>/dev/null
}

while :; do
  typeset -A prog_of tab_members

  # ── panes ──────────────────────────────────────────────────
  panes=$(herdr pane list 2>/dev/null \
    | jq -r '.result.panes[] | "\(.pane_id)\t\(.tab_id)\t\(.label // "-")\t\(.agent // "")"' 2>/dev/null)

  for line in ${(f)panes}; do
    [[ -n $line ]] || continue
    fields=(${(ps:\t:)line})
    pane=${fields[1]}
    tab=${fields[2]}
    label=${fields[3]}
    agent=${fields[4]:-}

    prog=$(pane_program "$pane")
    [[ -n $prog && $prog != null ]] || continue

    # An agent pane keeps the agent's name. Its foreground process is whatever
    # the agent happens to be shelling out to (node, ssh, git...), which is
    # noise, and herdr already identifies the occupant for us.
    [[ -n $agent ]] && prog=$agent

    prog_of[$pane]=$prog
    tab_members[$tab]="${tab_members[$tab]:-} $pane"

    if (( CLEAR_ON_SHELL )) && (( ${SKIP[(Ie)$prog]} )); then
      [[ $label == "-" ]] || herdr pane rename "$pane" --clear >/dev/null 2>&1
    elif [[ $label != $prog ]]; then
      herdr pane rename "$pane" "$prog" >/dev/null 2>&1
    fi
  done

  # ── tabs ───────────────────────────────────────────────────
  if (( RENAME_TABS )); then
    tabs=$(herdr tab list 2>/dev/null \
      | jq -r '.result.tabs[] | "\(.tab_id)\t\(.workspace_id)\t\(.label // "-")"' 2>/dev/null)

    typeset -A position_in
    for line in ${(f)tabs}; do
      [[ -n $line ]] || continue
      fields=(${(ps:\t:)line})
      tab=${fields[1]}
      ws=${fields[2]}
      label=${fields[3]:-}

      # herdr lists tabs in bar order, so the running count per workspace is
      # the position herdr would print for an unnamed tab.
      pos=$(( ${position_in[$ws]:-0} + 1 ))
      position_in[$ws]=$pos

      # Leave names the user typed alone.
      [[ $label == <-> || $label == <->:* ]] || continue

      active=$(tab_focused_pane "${tab_members[$tab]:-}")
      [[ -n $active ]] || continue
      prog=${prog_of[$active]:-}
      [[ -n $prog ]] || continue

      if (( CLEAR_ON_SHELL )) && (( ${SKIP[(Ie)$prog]} )); then
        want=$pos
      else
        want="${pos}:${prog}"
      fi
      [[ $label == $want ]] || herdr tab rename "$tab" "$want" >/dev/null 2>&1
    done
    unset position_in
  fi

  unset prog_of tab_members
  sleep "$INTERVAL"
done
