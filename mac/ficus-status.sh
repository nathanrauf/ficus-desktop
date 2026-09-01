#!/bin/bash
# Prints "blocked" or "unblocked". Just reads /etc/hosts, so no sudo needed.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/ficus_core.sh"

if ficus_is_blocked; then
  echo "blocked"
else
  echo "unblocked"
fi
