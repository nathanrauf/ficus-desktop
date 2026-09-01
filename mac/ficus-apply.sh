#!/bin/bash
# Does the actual hosts-file edit. Needs to run as root, since /etc/hosts isn't
# writable by a normal user. The AppleScript GUI calls this via "with administrator
# privileges"; the CLI calls it via sudo.
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/ficus_core.sh"

action="$1"
shift || true

case "$action" in
  enable)
    ficus_enable_block "$@"
    ;;
  disable)
    ficus_disable_block
    ;;
  *)
    echo "Usage: $0 enable [domain...] | disable" >&2
    exit 1
    ;;
esac
