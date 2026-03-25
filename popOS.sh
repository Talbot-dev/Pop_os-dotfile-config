#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"
WALLPAPER_DIR="${SCRIPT_DIR}/Wallpapers"

echo "[1/5] Updating system

"
sudo apt update
sudo apt upgrade -y

echo "[2/5] Installing desktop packages

"
sudo apt install -y \
	i3-wm i3lock i3status \
	polybar picom rofi \
	kitty feh numlockx \
	vim neofetch \
	fonts-font-awesome fonts-unifont \
	ranger \
	git \
	zsh \
	xdotool maim xss-lock network-manager-gnome

echo "[3/5] Copying dotfiles

"
mkdir -p "$HOME/.config/kitty/themes" "$HOME/.config/i3" "$HOME/.config/polybar" "$HOME/.config/picom"
cp "${CONFIG_DIR}/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
cp "${CONFIG_DIR}/kitty/themes/"*.conf "$HOME/.config/kitty/themes/"
cp "${CONFIG_DIR}/i3/config" "$HOME/.config/i3/config"
cp "${CONFIG_DIR}/polybar/config" "$HOME/.config/polybar/config"
cp "${CONFIG_DIR}/polybar/launch.sh" "$HOME/.config/polybar/launch.sh"
cp "${CONFIG_DIR}/picom/picom.conf" "$HOME/.config/picom/picom.conf"
chmod +x "$HOME/.config/polybar/launch.sh"

echo "[4/5] Copying wallpapers

"
mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Screenshots"
	# Copy supported wallpaper formats instead of a single hardcoded file.
	shopt -s nullglob
	WALLPAPER_FILES=("${WALLPAPER_DIR}"/*.{jpg,jpeg,png,webp})
	if [ ${#WALLPAPER_FILES[@]} -gt 0 ]; then
		cp "${WALLPAPER_FILES[@]}" "$HOME/Pictures/Wallpapers/"
	else
		echo "Warning: no wallpapers found in ${WALLPAPER_DIR}."
	fi
	shopt -u nullglob

echo "[Extra] Configuring Rofi theme and icons

"
mkdir -p "$HOME/.config/rofi"
cat > "$HOME/.config/rofi/config.rasi" <<'EOROFI'
configuration {
	show-icons: true;
	icon-theme: "Papirus";
	font: "FiraCode Nerd Font 12";
}
@theme "/usr/share/rofi/themes/gruvbox-dark.rasi"
EOROFI

# Instala Papirus icon theme si no está
if ! dpkg -l | grep -q papirus-icon-theme; then
	sudo apt install -y papirus-icon-theme
fi

echo "[Extra] Configuring Polybar colors (Gruvbox palette)

"
POLYBAR_CONFIG="$HOME/.config/polybar/config"
if [ -f "$POLYBAR_CONFIG" ]; then
	sed -i 's/^background = .*/background = #282828/' "$POLYBAR_CONFIG"
	sed -i 's/^foreground = .*/foreground = #ebdbb2/' "$POLYBAR_CONFIG"
	sed -i 's/^primary = .*/primary = #d79921/' "$POLYBAR_CONFIG"
	sed -i 's/^secondary = .*/secondary = #458588/' "$POLYBAR_CONFIG"
	sed -i 's/^alert = .*/alert = #cc241d/' "$POLYBAR_CONFIG"
fi

echo "[Extra] Configuring Neofetch with custom image

"
mkdir -p "$HOME/.config/neofetch"
	if [ -f "${WALLPAPER_DIR}/Neofetch.jpg" ]; then
		cp "${WALLPAPER_DIR}/Neofetch.jpg" "$HOME/.config/neofetch/Neofetch.jpg"
		NEOFETCH_IMAGE="$HOME/.config/neofetch/Neofetch.jpg"
	elif [ -f "${WALLPAPER_DIR}/Neofetch.png" ]; then
		cp "${WALLPAPER_DIR}/Neofetch.png" "$HOME/.config/neofetch/Neofetch.png"
		NEOFETCH_IMAGE="$HOME/.config/neofetch/Neofetch.png"
	else
		NEOFETCH_IMAGE=""
		echo "Warning: Neofetch image not found in ${WALLPAPER_DIR}."
	fi

cat > "$HOME/.config/neofetch/config.conf" <<'EONEO'
image_backend="kitty"
EONEO

if [ -n "${NEOFETCH_IMAGE}" ]; then
	echo "image_source=\"${NEOFETCH_IMAGE}\"" >> "$HOME/.config/neofetch/config.conf"
fi

echo "[5/5] Setting kitty as default terminal (if available)

"
if command -v kitty >/dev/null 2>&1; then
	kitty_path="$(command -v kitty)"
	if update-alternatives --list x-terminal-emulator >/dev/null 2>&1; then
		sudo update-alternatives --set x-terminal-emulator "$kitty_path" || true
	fi
fi


echo "[Extra] Configuring zsh.....

"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=no \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "[Skip] Oh My Zsh already installed"
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
install_plugin() {
  local repo=$1
  local dest=$2

  if [ ! -d "$dest" ]; then
    git clone "$repo" "$dest"
  else
    echo "[Skip] Plugin already exists: $(basename "$dest")"
  fi
}
install_plugin https://github.com/zsh-users/zsh-autosuggestions \
  $ZSH_CUSTOM/plugins/zsh-autosuggestions

install_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git \
  $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

install_plugin https://github.com/zsh-users/zsh-completions \
  $ZSH_CUSTOM/plugins/zsh-completions

echo "[Extra] Configuring .zshrc..."

ZSHRC="$HOME/.zshrc"

touch "$ZSHRC"

set_or_replace() {
  local key=$1
  local value=$2

  if grep -q "^$key=" "$ZSHRC"; then
    sed -i "s|^$key=.*|$key=$value|" "$ZSHRC"
  else
    echo "$key=$value" >> "$ZSHRC"
  fi
}
set_or_replace "plugins" "(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)"

grep -qxF 'autoload -U compinit && compinit' "$ZSHRC" || \
echo 'autoload -U compinit && compinit' >> "$ZSHRC"

echo "[Extra] Setting zsh as default shell..."

CURRENT_SHELL=$(basename "$SHELL")
ZSH_PATH=$(which zsh)

if [ "$CURRENT_SHELL" != "zsh" ]; then
  chsh -s "$ZSH_PATH"
else
  echo "[Skip] zsh already default shell"
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
