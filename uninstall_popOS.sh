#!/usr/bin/env bash

echo " (⊙ _ ⊙ ).... Removing Pop_OS Dotfile Config..."

set -euo pipefail

# Uninstaller for Pop_os-dotfile-config
# This script will attempt to revert all changes made by popOS.sh

CONFIG_DIR="$HOME/.config"
PICTURES_DIR="$HOME/Pictures"

# 1. Restore default terminal if kitty was set as default
echo "[1/5] Restoring default terminal if needed"
current_terminal="$(update-alternatives --query x-terminal-emulator 2>/dev/null | awk -F': ' '/^Value: /{print $2}')"
if [[ "$current_terminal" == *kitty* ]]; then
    # Prefer gnome-terminal, then xterm, to avoid leaving alternatives on kitty.
    if command -v gnome-terminal >/dev/null 2>&1; then
        sudo update-alternatives --set x-terminal-emulator "$(command -v gnome-terminal)" || true
    elif command -v xterm >/dev/null 2>&1; then
        sudo update-alternatives --set x-terminal-emulator "$(command -v xterm)" || true
    fi
fi

# 2. Remove installed packages
# (Will not remove dependencies installed by other packages)
echo "[2/5] Removing desktop packages (i3, polybar, picom, rofi, kitty, etc.)"
sudo apt remove --purge -y \
    i3-wm i3lock i3status \
    polybar picom rofi \
    kitty feh numlockx \
    vim neofetch \
    fonts-font-awesome fonts-unifont \
    flameshot \
    xdotool maim xss-lock network-manager-gnome \
    papirus-icon-theme || true
sudo apt autoremove --purge -y

# 3. Remove dotfiles from ~/.config
echo "[3/5] Removing dotfiles from $CONFIG_DIR"
rm -rf "$CONFIG_DIR/kitty" "$CONFIG_DIR/i3" "$CONFIG_DIR/polybar" "$CONFIG_DIR/picom" "$CONFIG_DIR/rofi" "$CONFIG_DIR/neofetch"

# 4. Remove wallpapers and screenshots
echo "[4/5] Removing wallpapers and screenshots from $PICTURES_DIR"
rm -rf "$PICTURES_DIR/Wallpapers" "$PICTURES_DIR/Screenshots"

# 5. Final message
echo "\nUninstallation complete."
echo "

Reboot or log out and back in to fully restore your previous desktop environment.
(つ╥﹏╥)つ
"
