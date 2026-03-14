#!/usr/bin/env bash
set -euo pipefail

# Uninstaller for Pop_os-dotfile-config
# This script will attempt to revert all changes made by popOS.sh

CONFIG_DIR="$HOME/.config"
PICTURES_DIR="$HOME/Pictures"

# 1. Remove installed packages
# (Will not remove dependencies installed by other packages)
echo "[1/5] Removing desktop packages (i3, polybar, picom, rofi, kitty, etc.)"
sudo apt remove --purge -y \
    i3-wm i3lock i3status \
    polybar picom rofi \
    kitty feh numlockx \
    vim neofetch \
    fonts-font-awesome fonts-unifont \
    xdotool maim xss-lock network-manager-gnome \
    papirus-icon-theme || true
sudo apt autoremove -y

# 2. Remove dotfiles from ~/.config
echo "[2/5] Removing dotfiles from $CONFIG_DIR"
rm -rf "$CONFIG_DIR/kitty" "$CONFIG_DIR/i3" "$CONFIG_DIR/polybar" "$CONFIG_DIR/picom" "$CONFIG_DIR/rofi" "$CONFIG_DIR/neofetch"

# 3. Remove wallpapers and screenshots
echo "[3/5] Removing wallpapers and screenshots from $PICTURES_DIR"
rm -rf "$PICTURES_DIR/Wallpapers" "$PICTURES_DIR/Screenshots"

# 4. Restore default terminal if kitty was set as default
echo "[4/5] Restoring default terminal if needed"
if update-alternatives --list x-terminal-emulator 2>/dev/null | grep -q kitty; then
    # Try to set to gnome-terminal if available, else xterm
    if command -v gnome-terminal >/dev/null 2>&1; then
        sudo update-alternatives --set x-terminal-emulator $(command -v gnome-terminal)
    elif command -v xterm >/dev/null 2>&1; then
        sudo update-alternatives --set x-terminal-emulator $(command -v xterm)
    fi
fi

# 5. Final message
echo "\nUninstallation complete."
echo "Reboot or log out and back in to fully restore your previous desktop environment."
