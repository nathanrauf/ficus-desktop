#!/bin/bash
# Shared logic for Ficus on macOS. Source this file; don't run it directly.

HOSTS_PATH="/etc/hosts"
MARKER_START="# >>> ficus-blocker >>>"
MARKER_END="# <<< ficus-blocker <<<"
STATE_DIR="$HOME/.ficus"
DOMAINS_FILE="$STATE_DIR/domains.txt"
CHECKED_FILE="$STATE_DIR/checked.txt"

DEFAULT_DOMAINS=(
  "facebook.com" "www.facebook.com" "m.facebook.com" "fb.com" "www.fb.com"
  "instagram.com" "www.instagram.com"
  "twitter.com" "www.twitter.com" "x.com" "www.x.com"
  "tiktok.com" "www.tiktok.com" "m.tiktok.com"
  "reddit.com" "www.reddit.com" "old.reddit.com"
  "snapchat.com" "www.snapchat.com"
  "pinterest.com" "www.pinterest.com"
  "tumblr.com" "www.tumblr.com"
  "threads.net" "www.threads.net"
  "linkedin.com" "www.linkedin.com"
)

ficus_init_state() {
  mkdir -p "$STATE_DIR"
  if [ ! -f "$DOMAINS_FILE" ]; then
    printf '%s\n' "${DEFAULT_DOMAINS[@]}" > "$DOMAINS_FILE"
  fi
  if [ ! -f "$CHECKED_FILE" ]; then
    cp "$DOMAINS_FILE" "$CHECKED_FILE"
  fi
}

ficus_list_domains() {
  ficus_init_state
  cat "$DOMAINS_FILE"
}

ficus_list_checked() {
  ficus_init_state
  cat "$CHECKED_FILE"
}

ficus_add_domain() {
  ficus_init_state
  local domain="$1"
  if ! grep -qxF "$domain" "$DOMAINS_FILE"; then
    echo "$domain" >> "$DOMAINS_FILE"
  fi
  if ! grep -qxF "$domain" "$CHECKED_FILE"; then
    echo "$domain" >> "$CHECKED_FILE"
  fi
}

ficus_set_checked() {
  ficus_init_state
  printf '%s\n' "$@" > "$CHECKED_FILE"
}

ficus_is_blocked() {
  grep -qF "$MARKER_START" "$HOSTS_PATH" 2>/dev/null
}

_ficus_strip_block() {
  awk -v start="$MARKER_START" -v end="$MARKER_END" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "$HOSTS_PATH"
}

_ficus_flush_dns() {
  dscacheutil -flushcache 2>/dev/null || true
  killall -HUP mDNSResponder 2>/dev/null || true
}

ficus_enable_block() {
  local domains=("$@")
  if [ ${#domains[@]} -eq 0 ]; then
    domains=("${DEFAULT_DOMAINS[@]}")
  fi

  if [ ! -f "${HOSTS_PATH}.bak" ]; then
    cp "$HOSTS_PATH" "${HOSTS_PATH}.bak"
  fi

  local cleaned
  cleaned=$(_ficus_strip_block)

  {
    printf '%s\n\n%s\n' "$cleaned" "$MARKER_START"
    for d in "${domains[@]}"; do
      printf '0.0.0.0\t%s\n' "$d"
      printf '::1\t%s\n' "$d"
    done
    printf '%s\n' "$MARKER_END"
  } > "$HOSTS_PATH"

  _ficus_flush_dns
}

ficus_disable_block() {
  local cleaned
  cleaned=$(_ficus_strip_block)
  printf '%s\n' "$cleaned" > "$HOSTS_PATH"

  _ficus_flush_dns
}
