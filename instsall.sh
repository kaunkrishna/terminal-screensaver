#!/usr/bin/env bash
#
# install.sh — one-time setup for the Omarchy-style terminal screensaver.
#
# Installs pipx (if not already present) and then uses it to install
# terminaltexteffects (tte), the library that powers the animations.
# Run this once; after that just use ./screensaver.sh.
#

set -euo pipefail

echo "== Omarchy-style screensaver: installer =="

# --- 1. Make sure python3 exists --------------------------------------------
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required but was not found. Please install Python 3 first." >&2
  exit 1
fi

# --- 2. Install pipx if it's missing -----------------------------------------
if command -v pipx >/dev/null 2>&1; then
  echo "pipx already installed: $(command -v pipx)"
else
  echo "pipx not found — installing it..."

  if command -v brew >/dev/null 2>&1; then
    # macOS with Homebrew
    brew install pipx
    pipx ensurepath

  elif command -v apt-get >/dev/null 2>&1; then
    # Debian/Ubuntu
    if sudo -n true 2>/dev/null || [[ $EUID -eq 0 ]]; then
      sudo apt-get update -y
      sudo apt-get install -y pipx
    else
      echo "Falling back to 'python3 -m pip install --user pipx' (no sudo access detected)"
      python3 -m pip install --user --break-system-packages pipx 2>/dev/null \
        || python3 -m pip install --user pipx
    fi
    python3 -m pipx ensurepath

  elif command -v dnf >/dev/null 2>&1; then
    # Fedora
    sudo dnf install -y pipx
    pipx ensurepath

  elif command -v pacman >/dev/null 2>&1; then
    # Arch / Omarchy itself
    sudo pacman -S --noconfirm python-pipx
    pipx ensurepath

  else
    # Generic fallback: pip's --user install
    echo "No known package manager found — installing pipx via pip --user"
    python3 -m pip install --user --break-system-packages pipx 2>/dev/null \
      || python3 -m pip install --user pipx
    python3 -m pipx ensurepath
  fi

  # pipx may have installed to ~/.local/bin, which might not be on PATH yet
  # in this shell session
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v pipx >/dev/null 2>&1; then
  echo "pipx installation finished, but 'pipx' isn't on PATH in this shell yet." >&2
  echo "Open a new terminal (or 'source ~/.bashrc' / ~/.zshrc) and re-run this installer." >&2
  exit 1
fi

# --- 3. Install tte (terminaltexteffects) via pipx --------------------------
if command -v tte >/dev/null 2>&1; then
  echo "tte already installed: $(command -v tte)"
else
  echo "Installing terminaltexteffects via pipx..."
  pipx install terminaltexteffects
fi

# --- 4. Make screensaver.sh executable, if present next to this script -----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/screensaver.sh" ]]; then
  chmod +x "$SCRIPT_DIR/screensaver.sh"
fi

echo
echo "✅ Setup complete. Run the screensaver with: ./screensaver.sh"
echo "   (If 'tte' isn't found in a new shell, open a new terminal so PATH updates take effect.)"
