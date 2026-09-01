#!/bin/bash
# Ficus for Linux, command line.
#
# Usage:
#   sudo bash ficus-cli.sh              # turn the block on
#   sudo bash ficus-cli.sh --disable    # turn it off
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/ficus_core.sh"

if [ "$EUID" -ne 0 ]; then
  echo "This needs to run as root, since it edits /etc/hosts. Try: sudo bash $0 $*" >&2
  exit 1
fi

if [ "$1" = "--disable" ]; then
  ficus_disable_block
  echo "Block removed."
else
  ficus_enable_block
  echo "Blocked ${#DEFAULT_DOMAINS[@]} sites."
fi

echo "Done."
