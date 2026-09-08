#!/usr/bin/env bash
#
# screensaver.sh
#
# A terminal screensaver that mimics Omarchy Linux's built-in screensaver:
# it renders ASCII art through the "Terminal Text Effects" (tte) library,
# cycling through random animations, fullscreen in your terminal, until
# any key is pressed.
#
# Requires tte to already be installed — run ./install.sh once first.
#
# Usage:
#   ./screensaver.sh                  # use bundled logo.txt
#   ./screensaver.sh /path/to/art.txt # use your own ASCII art
#   SCREENSAVER_EXCLUDE="dev_worm,beams" ./screensaver.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGO_FILE="${1:-${SCREENSAVER_LOGO:-$SCRIPT_DIR/logo.txt}}"
EXCLUDE="${SCREENSAVER_EXCLUDE:-dev_worm}"

if [[ ! -f "$LOGO_FILE" ]]; then
  echo "Logo file not found: $LOGO_FILE" >&2
  exit 1
fi

# tte may live in ~/.local/bin (pipx default) which isn't always on PATH
export PATH="$HOME/.local/bin:$PATH"

if ! command -v tte >/dev/null 2>&1; then
  echo "tte (terminaltexteffects) isn't installed." >&2
  echo "Run ./install.sh once to set everything up, then try again." >&2
  exit 1
fi

# --- terminal setup ----------------------------------------------------------
cleanup() {
  tput cnorm      # show cursor again
  stty sane        # restore terminal input mode
  clear
}
trap cleanup EXIT INT TERM

tput civis         # hide cursor
stty -echo -icanon time 0 min 0   # non-blocking, no-echo key reads
clear

# --- main loop: let tte pick a random effect each time, no delay -----------
while true; do
  tte --input-file "$LOGO_FILE" \
      --frame-rate 120 \
      --canvas-width 0 \
      --canvas-height 0 \
      --anchor-canvas c \
      --anchor-text c \
      --no-eol \
      --random-effect \
      --exclude-effects "$EXCLUDE" \
      &

  TTE_PID=$!

  # Poll for keypress while the effect renders; exit the instant one is hit
  while kill -0 "$TTE_PID" 2>/dev/null; do
    if read -r -n 1 -t 0.02 key 2>/dev/null; then
      kill "$TTE_PID" 2>/dev/null || true
      wait "$TTE_PID" 2>/dev/null || true
      exit 0
    fi
  done
  wait "$TTE_PID" 2>/dev/null || true
  # No pause here -> next effect starts immediately
done
