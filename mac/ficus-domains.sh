#!/bin/bash
# Manages the saved domain list (~/.ficus/domains.txt and checked.txt) that the
# GUI reads from. None of this touches /etc/hosts, so no sudo needed here either.
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/ficus_core.sh"

cmd="$1"
shift || true

case "$cmd" in
  list)
    ficus_list_domains
    ;;
  checked)
    ficus_list_checked
    ;;
  add)
    ficus_add_domain "$1"
    ;;
  set-checked)
    ficus_set_checked "$@"
    ;;
  *)
    echo "Usage: $0 list | checked | add <domain> | set-checked <domain...>" >&2
    exit 1
    ;;
esac
