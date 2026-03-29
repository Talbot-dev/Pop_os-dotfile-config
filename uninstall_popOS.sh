#!/usr/bin/env bash

echo " (⊙ _ ⊙ ).... Removing Pop_OS Dotfile Config..."

set -euo pipefail

CONFIG_DIR="$HOME/.config"
PICTURES_DIR="$HOME/Pictures"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "[1/7] Restoring default terminal and shell"
current_terminal="$(update-alternatives --query x-terminal-emulator 2>/dev/null | awk -F': ' '/^Value: /{print $2}')"
if [[ "$current_terminal" == *kitty* ]] || [[ "$current_terminal" == *alacritty* ]]; then
    if command -v gnome-terminal >/dev/null 2>&1; then
        sudo update-alternatives --set x-terminal-emulator "$(command -v gnome-terminal)" || true
    elif command -v xterm >/dev/null 2>&1; then
        sudo update-alternatives --set x-terminal-emulator "$(command -v xterm)" || true
    fi
fi

if [ "$(basename "$SHELL")" = "zsh" ] && command -v bash >/dev/null 2>&1; then
    chsh -s "$(command -v bash)" || true
fi

echo "[2/7] Stopping services/processes if running"
pkill -x polybar 2>/dev/null || true
pkill -x picom 2>/dev/null || true
pkill -x dunst 2>/dev/null || true
pkill -x sxhkd 2>/dev/null || true
pkill -x greenclip 2>/dev/null || true

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user stop mpd 2>/dev/null || true
    systemctl --user disable mpd 2>/dev/null || true
fi

echo "[3/7] Removing desktop packages"
sudo apt remove --purge -y \
    i3-wm i3lock i3status \
    bspwm sxhkd dunst \
    polybar picom rofi jgmenu \
    kitty alacritty feh numlockx \
    vim neofetch btop ranger \
    thunar thunar-volman thunar-archive-plugin \
    qt5ct lxappearance \
    mpd ncmpcpp mpc mpdris2 \
    brightnessctl pamixer playerctl \
    wmctrl xdo xautolock acpi xclip jq \
    fonts-font-awesome fonts-unifont \
    xdotool maim xss-lock network-manager-gnome \
    papirus-icon-theme || true
sudo apt autoremove --purge -y

echo "[4/7] Removing dotfiles from $CONFIG_DIR"
rm -rf \
    "$CONFIG_DIR/kitty" \
    "$CONFIG_DIR/i3" \
    "$CONFIG_DIR/polybar" \
    "$CONFIG_DIR/picom" \
    "$CONFIG_DIR/rofi" \
    "$CONFIG_DIR/neofetch" \
    "$CONFIG_DIR/bspwm" \
    "$CONFIG_DIR/alacritty" \
    "$CONFIG_DIR/ranger" \
    "$CONFIG_DIR/btop" \
    "$CONFIG_DIR/jgmenu" \
    "$CONFIG_DIR/qt5ct" \
    "$CONFIG_DIR/gtk-3.0" \
    "$CONFIG_DIR/Thunar" \
    "$CONFIG_DIR/mpd" \
    "$CONFIG_DIR/ncmpcpp" \
    "$CONFIG_DIR/mpDris2"

echo "[5/7] Removing wallpapers and screenshots from $PICTURES_DIR"
rm -rf "$PICTURES_DIR/Wallpapers" "$PICTURES_DIR/Screenshots"

echo "[6/7] Removing local helper scripts copied by dotfiles"
rm -rf "$HOME/.local/bin/colorscript" "$HOME/.local/bin/hdd" "$HOME/.local/bin/sysfetch"

echo "[7/7] Reverting zsh plugin changes"
rm -rf \
    "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" \
    "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" \
    "$ZSH_CUSTOM_DIR/plugins/zsh-completions"

if [ -f "$HOME/.zshrc" ]; then
    sed -i '/^autoload -U compinit && compinit$/d' "$HOME/.zshrc" || true
    # Reset plugins line to a conservative default.
    if grep -q '^plugins=' "$HOME/.zshrc"; then
        sed -i 's|^plugins=.*|plugins=(git)|' "$HOME/.zshrc"
    fi
fi

echo "\nUninstallation complete."
echo "

Reboot or log out and back in to fully restore your previous desktop environment.
Arch-only packages from dotfiles-bspwm/app support were never installed.
(つ╥﹏╥)つ
"
