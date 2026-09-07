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

# All effects tte ships with (as of terminaltexteffects >= 0.11). We pick one
# at random ourselves rather than relying on --random-effect / random_effect,
# since that flag's syntax has changed across tte versions.
ALL_EFFECTS=(beams binarypath blackhole bouncyballs bubbles burn colorshift
  crumble decrypt dev_worm errorcorrect expand fireworks highlight laseretch
  matrix middleout orbittingvolley overflow pour print rain randomsequence
  rings scattered slice slide spotlights spray swarm sweep synthgrid
  unstable vhstape waves wipe)

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

# Build the pool of effects to choose from, honoring $EXCLUDE (comma-separated)
IFS=',' read -r -a EXCLUDE_ARR <<< "$EXCLUDE"
EFFECT_POOL=()
for e in "${ALL_EFFECTS[@]}"; do
  skip=0
  for x in "${EXCLUDE_ARR[@]}"; do
    [[ "$e" == "$x" ]] && skip=1 && break
  done
  [[ "$skip" -eq 0 ]] && EFFECT_POOL+=("$e")
done
[[ ${#EFFECT_POOL[@]} -eq 0 ]] && EFFECT_POOL=("${ALL_EFFECTS[@]}")

# --- main loop: shuffle through every effect, no delay between them --------
# QUEUE holds a shuffled copy of EFFECT_POOL. We pop from it each round; once
# empty we reshuffle, so every effect plays once before any repeats.
QUEUE=()

refill_queue() {
  QUEUE=("${EFFECT_POOL[@]}")
  # Fisher-Yates shuffle
  local i j tmp
  for ((i = ${#QUEUE[@]} - 1; i > 0; i--)); do
    j=$((RANDOM % (i + 1)))
    tmp="${QUEUE[i]}"; QUEUE[i]="${QUEUE[j]}"; QUEUE[j]="$tmp"
  done
}

while true; do
  [[ ${#QUEUE[@]} -eq 0 ]] && refill_queue
  effect="${QUEUE[-1]}"
  unset 'QUEUE[-1]'

  tte --input-file "$LOGO_FILE" \
      --frame-rate 120 \
      --canvas-width 0 \
      --canvas-height 0 \
      --anchor-canvas c \
      --anchor-text c \
      --no-eol \
      "$effect" \
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
