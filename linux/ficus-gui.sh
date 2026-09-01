#!/bin/bash
# Ficus for Linux, GUI. Needs zenity for the dialogs and pkexec for the admin
# password prompt when it actually edits /etc/hosts.
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/ficus_core.sh"

if ! command -v zenity >/dev/null 2>&1; then
  echo "zenity is required. On Debian/Ubuntu: sudo apt install zenity" >&2
  exit 1
fi
if ! command -v pkexec >/dev/null 2>&1; then
  zenity --error --text="pkexec is required for the admin password prompt (it's usually part of policykit). You can still use ficus-cli.sh with sudo instead." 2>/dev/null
  exit 1
fi

ficus_init_state

main_menu() {
  if ficus_is_blocked; then
    status="BLOCKED"
    toggle="Unblock Now"
  else
    status="NOT BLOCKED"
    toggle="Block Now"
  fi

  choice=$(zenity --list --title="Ficus" --text="Status: $status" \
    --column="Action" "$toggle" "Edit Sites" "Quit" \
    --hide-header --height=250 --width=300) || return 0

  case "$choice" in
    "Edit Sites")
      edit_sites
      main_menu
      ;;
    "Quit"|"")
      return 0
      ;;
    *)
      if ficus_is_blocked; then
        pkexec /bin/bash "$DIR/ficus-apply.sh" disable || zenity --error --text="Nothing changed (canceled, or the change failed)."
      else
        mapfile -t checked < "$CHECKED_FILE"
        if [ ${#checked[@]} -eq 0 ]; then
          zenity --warning --text="Check at least one site under Edit Sites first."
        else
          pkexec /bin/bash "$DIR/ficus-apply.sh" enable "${checked[@]}" || zenity --error --text="Nothing changed (canceled, or the change failed)."
        fi
      fi
      main_menu
      ;;
  esac
}

edit_sites() {
  mapfile -t all_domains < "$DOMAINS_FILE"
  mapfile -t checked < "$CHECKED_FILE"

  args=()
  for d in "${all_domains[@]}"; do
    is_checked="FALSE"
    for c in "${checked[@]}"; do
      if [ "$c" = "$d" ]; then is_checked="TRUE"; fi
    done
    args+=("$is_checked" "$d")
  done

  selection=$(zenity --list --checklist --title="Ficus — Edit Sites" \
    --column="Block" --column="Domain" "${args[@]}" \
    --separator="|" --height=400 --width=350) || selection=""

  if [ -n "$selection" ]; then
    IFS='|' read -r -a selected <<< "$selection"
    ficus_set_checked "${selected[@]}"
  fi

  new_domain=$(zenity --entry --title="Ficus" --text="Add a site (leave blank to skip):") || new_domain=""
  if [ -n "$new_domain" ]; then
    ficus_add_domain "$new_domain"
  fi
}

main_menu
