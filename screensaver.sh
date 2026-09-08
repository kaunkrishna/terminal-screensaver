#!/bin/bash

ASCII_FILE="ascii.txt"

cleanup() {
    tput cnorm
    stty sane
    clear
}

trap cleanup EXIT INT TERM

tput civis
stty -echo -icanon time 0 min 0
clear

while true; do
    tte -i "$ASCII_FILE" \
        --frame-rate 60 \
        --canvas-width 0 \
        --canvas-height 0 \
        --reuse-canvas \
        --anchor-canvas c \
        --anchor-text c \
        --random-effect \
        --exclude-effects dev_worm \
        --no-eol \
        --no-restore-cursor &

    TTE_PID=$!

    while kill -0 "$TTE_PID" 2>/dev/null; do
        if read -r -n 1 -t 0.02; then
            kill "$TTE_PID" 2>/dev/null || true
            wait "$TTE_PID" 2>/dev/null || true
            exit 0
        fi
    done

    wait "$TTE_PID" 2>/dev/null || true
done
