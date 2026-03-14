#!/usr/bin/env bash

echo "
# ██████╗  ██████╗ ██████╗      ██████╗ ███████╗        
# ██╔══██╗██╔═══██╗██╔══██╗    ██╔═══██╗██╔════╝        
# ██████╔╝██║   ██║██████╔╝    ██║   ██║███████╗        
# ██╔═══╝ ██║   ██║██╔═══╝     ██║   ██║╚════██║        
# ██║     ╚██████╔╝██║         ╚██████╔╝███████║        
# ╚═╝      ╚═════╝ ╚═╝          ╚═════╝ ╚══════╝        
#                                                       
# ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗ 
# ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝ 
# ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗   
# ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝   
# ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗ 
# ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝ 
#                                                       
# ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     
# ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     
# ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     
# ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     
# ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗
# ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝

"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"
WALLPAPER_DIR="${SCRIPT_DIR}/Wallpapers"

echo "[1/5] Updating system"
sudo apt update
sudo apt upgrade -y

echo "[2/5] Installing desktop packages (i3, polybar, picom, rofi, kitty)"
sudo apt install -y \
	i3-wm i3lock i3status \
	polybar picom rofi \
	kitty feh numlockx \
	vim neofetch \
	fonts-font-awesome ttf-unifont \
	xdotool maim xss-lock network-manager-gnome

echo "[3/5] Copying dotfiles"
mkdir -p "$HOME/.config/kitty" "$HOME/.config/i3" "$HOME/.config/polybar" "$HOME/.config/picom"
cp "${CONFIG_DIR}/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
cp "${CONFIG_DIR}/i3/config" "$HOME/.config/i3/config"
cp "${CONFIG_DIR}/polybar/config" "$HOME/.config/polybar/config"
cp "${CONFIG_DIR}/polybar/launch.sh" "$HOME/.config/polybar/launch.sh"
cp "${CONFIG_DIR}/picom/picom.conf" "$HOME/.config/picom/picom.conf"
chmod +x "$HOME/.config/polybar/launch.sh"

echo "[4/5] Copying wallpapers"
mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Screenshots"
if compgen -G "${WALLPAPER_DIR}/*" > /dev/null; then
	cp -r "${WALLPAPER_DIR}/." "$HOME/Pictures/Wallpapers/"
else
	echo "Warning: no wallpapers found in ${WALLPAPER_DIR}."
fi

echo "[5/5] Setting kitty as default terminal (if available)"
if command -v kitty >/dev/null 2>&1; then
	kitty_path="$(command -v kitty)"
	if update-alternatives --list x-terminal-emulator >/dev/null 2>&1; then
		sudo update-alternatives --set x-terminal-emulator "$kitty_path" || true
	fi
fi

cat <<'EOF'

Installation complete.

Next steps:
1. Log out and choose i3 from the login screen.
2. Inside i3, press Mod+Shift+r to reload config (if needed).
3. Polybar should autostart from ~/.config/i3/config.
4. Open launcher with Mod+d (rofi).

If polybar does not appear, run:
	~/.config/polybar/launch.sh

EOF
