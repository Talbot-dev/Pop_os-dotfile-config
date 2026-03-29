#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"
BSPWM_CONFIG_DIR="${SCRIPT_DIR}/dotfiles-bspwm/config"
WALLPAPER_DIR="${SCRIPT_DIR}/Wallpapers"

WM_PROFILE=""
INSTALL_ALACRITTY=0
INSTALL_RANGER=1
INSTALL_BTOP=0
INSTALL_JGMENU=0
INSTALL_QT_GTK=0
INSTALL_THUNAR=0
INSTALL_MPD=0

has_bspwm_sources=0
if [ -d "$BSPWM_CONFIG_DIR/bspwm" ]; then
	has_bspwm_sources=1
fi

ask_choice() {
	local prompt="$1"
	shift
	local options=("$@")
	local i

	echo "$prompt" >&2
	for i in "${!options[@]}"; do
		echo "  $((i + 1))) ${options[$i]}" >&2
	done

	while true; do
		read -r -p "Choose [1-${#options[@]}]: " choice >&2
		if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
			echo "${options[$((choice - 1))]}"
			return
		fi
		echo "Invalid option. Try again." >&2
	done
}

ask_yes_no() {
	local prompt="$1"
	local default="$2"
	local answer

	while true; do
		if [ "$default" = "y" ]; then
			read -r -p "$prompt [Y/n]: " answer
			answer="${answer:-y}"
		else
			read -r -p "$prompt [y/N]: " answer
			answer="${answer:-n}"
		fi

		case "${answer,,}" in
			y|yes)
				return 0
				;;
			n|no)
				return 1
				;;
			*)
				echo "Please answer y or n."
				;;
		esac
	done
}

append_unique() {
	local item
	for item in "$@"; do
		if [[ " ${PACKAGES[*]} " != *" ${item} "* ]]; then
			PACKAGES+=("$item")
		fi
	done
}

copy_wallpapers() {
	echo "[4/7] Copying wallpapers"
	mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Screenshots"

	shopt -s nullglob
	WALLPAPER_FILES=("${WALLPAPER_DIR}"/*.{jpg,jpeg,png,webp})
	if [ ${#WALLPAPER_FILES[@]} -gt 0 ]; then
		cp "${WALLPAPER_FILES[@]}" "$HOME/Pictures/Wallpapers/"
	else
		echo "[Warn] No wallpapers found in ${WALLPAPER_DIR}."
	fi
	shopt -u nullglob
}

copy_i3_profile() {
	echo "[Profile] Applying i3 configuration"
	mkdir -p "$HOME/.config/kitty/themes" "$HOME/.config/i3" "$HOME/.config/polybar" "$HOME/.config/picom"
	cp "${CONFIG_DIR}/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
	cp "${CONFIG_DIR}/kitty/themes/"*.conf "$HOME/.config/kitty/themes/"
	cp "${CONFIG_DIR}/i3/config" "$HOME/.config/i3/config"
	cp "${CONFIG_DIR}/polybar/config" "$HOME/.config/polybar/config"
	cp "${CONFIG_DIR}/polybar/launch.sh" "$HOME/.config/polybar/launch.sh"
	cp "${CONFIG_DIR}/picom/picom.conf" "$HOME/.config/picom/picom.conf"
	chmod +x "$HOME/.config/polybar/launch.sh"
}

copy_bspwm_profile() {
	echo "[Profile] Applying bspwm configuration"
	if [ "$has_bspwm_sources" -ne 1 ]; then
		echo "[Warn] dotfiles-bspwm sources not found. Skipping bspwm profile."
		return
	fi

	mkdir -p "$HOME/.config/bspwm"
	cp -r "$BSPWM_CONFIG_DIR/bspwm/"* "$HOME/.config/bspwm/"

	if [ -f "$BSPWM_CONFIG_DIR/rofi/config.rasi" ]; then
		mkdir -p "$HOME/.config/rofi"
		cp "$BSPWM_CONFIG_DIR/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
	fi

	# Replace hardcoded home paths in imported scripts.
	while IFS= read -r file; do
		sed -i "s|/home/ryan|$HOME|g" "$file"
	done < <(grep -RIl '/home/ryan' "$HOME/.config/bspwm" || true)

	chmod +x "$HOME/.config/bspwm/bspwmrc" "$HOME/.config/bspwm/sxhkdrc" || true
	find "$HOME/.config/bspwm/scripts" -maxdepth 1 -type f -exec chmod +x {} \;
}

copy_optional_components() {
	if [ "$has_bspwm_sources" -ne 1 ]; then
		return
	fi

	if [ "$INSTALL_ALACRITTY" -eq 1 ] && [ -d "$BSPWM_CONFIG_DIR/alacritty" ]; then
		mkdir -p "$HOME/.config"
		cp -r "$BSPWM_CONFIG_DIR/alacritty" "$HOME/.config/"
	fi

	if [ "$INSTALL_RANGER" -eq 1 ] && [ -d "$BSPWM_CONFIG_DIR/ranger" ]; then
		mkdir -p "$HOME/.config"
		cp -r "$BSPWM_CONFIG_DIR/ranger" "$HOME/.config/"
	fi

	if [ "$INSTALL_BTOP" -eq 1 ] && [ -d "$BSPWM_CONFIG_DIR/btop" ]; then
		mkdir -p "$HOME/.config"
		cp -r "$BSPWM_CONFIG_DIR/btop" "$HOME/.config/"
	fi

	if [ "$INSTALL_JGMENU" -eq 1 ] && [ -d "$BSPWM_CONFIG_DIR/jgmenu" ]; then
		mkdir -p "$HOME/.config"
		cp -r "$BSPWM_CONFIG_DIR/jgmenu" "$HOME/.config/"
	fi

	if [ "$INSTALL_QT_GTK" -eq 1 ]; then
		[ -d "$BSPWM_CONFIG_DIR/qt5ct" ] && cp -r "$BSPWM_CONFIG_DIR/qt5ct" "$HOME/.config/"
		[ -d "$BSPWM_CONFIG_DIR/gtk-3.0" ] && cp -r "$BSPWM_CONFIG_DIR/gtk-3.0" "$HOME/.config/"
	fi

	if [ "$INSTALL_THUNAR" -eq 1 ] && [ -d "$BSPWM_CONFIG_DIR/Thunar" ]; then
		mkdir -p "$HOME/.config"
		cp -r "$BSPWM_CONFIG_DIR/Thunar" "$HOME/.config/"
	fi

	if [ "$INSTALL_MPD" -eq 1 ]; then
		[ -d "$BSPWM_CONFIG_DIR/mpd" ] && cp -r "$BSPWM_CONFIG_DIR/mpd" "$HOME/.config/"
		[ -d "$BSPWM_CONFIG_DIR/ncmpcpp" ] && cp -r "$BSPWM_CONFIG_DIR/ncmpcpp" "$HOME/.config/"
		[ -d "$BSPWM_CONFIG_DIR/mpDris2" ] && cp -r "$BSPWM_CONFIG_DIR/mpDris2" "$HOME/.config/"
	fi
}

configure_rofi() {
	echo "[5/7] Configuring rofi"
	mkdir -p "$HOME/.config/rofi"

	if [ "$has_bspwm_sources" -eq 1 ] && [ -f "$BSPWM_CONFIG_DIR/rofi/config.rasi" ]; then
		cp "$BSPWM_CONFIG_DIR/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
	else
		cat > "$HOME/.config/rofi/config.rasi" <<'EOROFI'
configuration {
	show-icons: true;
	icon-theme: "Papirus";
	font: "FiraCode Nerd Font 12";
}
@theme "/usr/share/rofi/themes/gruvbox-dark.rasi"
EOROFI
	fi

	if ! dpkg -l | grep -q papirus-icon-theme; then
		sudo apt install -y papirus-icon-theme
	fi
}

configure_neofetch() {
	echo "[6/7] Configuring neofetch"
	mkdir -p "$HOME/.config/neofetch"

	if [ "$has_bspwm_sources" -eq 1 ] && [ -f "$BSPWM_CONFIG_DIR/neofetch/config.conf" ]; then
		cp "$BSPWM_CONFIG_DIR/neofetch/config.conf" "$HOME/.config/neofetch/config.conf"
	else
		cat > "$HOME/.config/neofetch/config.conf" <<'EONEO'
image_backend="kitty"
EONEO
	fi

	if [ -f "${WALLPAPER_DIR}/Neofetch.jpg" ]; then
		cp "${WALLPAPER_DIR}/Neofetch.jpg" "$HOME/.config/neofetch/Neofetch.jpg"
	elif [ -f "${WALLPAPER_DIR}/Neofetch.png" ]; then
		cp "${WALLPAPER_DIR}/Neofetch.png" "$HOME/.config/neofetch/Neofetch.png"
	fi
}

configure_polybar_colors_for_i3() {
	if [ "$WM_PROFILE" = "i3" ] || [ "$WM_PROFILE" = "both" ]; then
		echo "[Extra] Applying gruvbox palette for i3 polybar"
		POLYBAR_CONFIG="$HOME/.config/polybar/config"
		if [ -f "$POLYBAR_CONFIG" ]; then
			sed -i 's/^background = .*/background = #282828/' "$POLYBAR_CONFIG"
			sed -i 's/^foreground = .*/foreground = #ebdbb2/' "$POLYBAR_CONFIG"
			sed -i 's/^primary = .*/primary = #d79921/' "$POLYBAR_CONFIG"
			sed -i 's/^secondary = .*/secondary = #458588/' "$POLYBAR_CONFIG"
			sed -i 's/^alert = .*/alert = #cc241d/' "$POLYBAR_CONFIG"
		fi
	fi
}

configure_terminal_default() {
	echo "[7/7] Configuring default terminal"
	local terminal_path=""

	if [ "$INSTALL_ALACRITTY" -eq 1 ] && command -v alacritty >/dev/null 2>&1; then
		terminal_path="$(command -v alacritty)"
	elif command -v kitty >/dev/null 2>&1; then
		terminal_path="$(command -v kitty)"
	fi

	if [ -n "$terminal_path" ] && update-alternatives --list x-terminal-emulator >/dev/null 2>&1; then
		sudo update-alternatives --set x-terminal-emulator "$terminal_path" || true
	fi
}

configure_zsh() {
	echo "[Extra] Configuring zsh and plugins"

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
		"$ZSH_CUSTOM/plugins/zsh-autosuggestions"
	install_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git \
		"$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
	install_plugin https://github.com/zsh-users/zsh-completions \
		"$ZSH_CUSTOM/plugins/zsh-completions"

	ZSHRC="$HOME/.zshrc"
	touch "$ZSHRC"

	if grep -q '^plugins=' "$ZSHRC"; then
		sed -i 's|^plugins=.*|plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)|' "$ZSHRC"
	else
		echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)' >> "$ZSHRC"
	fi

	grep -qxF 'autoload -U compinit && compinit' "$ZSHRC" || \
		echo 'autoload -U compinit && compinit' >> "$ZSHRC"

	CURRENT_SHELL="$(basename "$SHELL")"
	ZSH_PATH="$(command -v zsh)"
	if [ "$CURRENT_SHELL" != "zsh" ]; then
		chsh -s "$ZSH_PATH"
	else
		echo "[Skip] zsh already default shell"
	fi
}

print_binary_notice() {
	cat <<'EOF'
[Notice] Arch binaries are intentionally excluded on Pop!_OS:
  - dotfiles-bspwm/app support/*.pkg.tar.zst
Use apt/source alternatives instead.
EOF
}

echo "== Pop!_OS Dotfiles Installer (i3 + bspwm) =="
if [ "$has_bspwm_sources" -eq 0 ]; then
	echo "[Warn] dotfiles-bspwm/config not found. Only i3 profile is available."
	WM_PROFILE="i3"
else
	WM_PROFILE="$(ask_choice 'Select window manager profile:' 'i3' 'bspwm' 'both')"
fi

if [ "$WM_PROFILE" = "bspwm" ] || [ "$WM_PROFILE" = "both" ]; then
	INSTALL_ALACRITTY=1
fi

if ask_yes_no "Install optional: Alacritty terminal config" "y"; then INSTALL_ALACRITTY=1; fi
if ask_yes_no "Install optional: Ranger config" "y"; then INSTALL_RANGER=1; else INSTALL_RANGER=0; fi
if ask_yes_no "Install optional: btop config" "n"; then INSTALL_BTOP=1; fi
if ask_yes_no "Install optional: jgmenu config" "n"; then INSTALL_JGMENU=1; fi
if ask_yes_no "Install optional: qt5ct + gtk-3.0 config" "n"; then INSTALL_QT_GTK=1; fi
if ask_yes_no "Install optional: Thunar config" "n"; then INSTALL_THUNAR=1; fi
if ask_yes_no "Install optional: mpd/ncmpcpp/mpDris2 config" "n"; then INSTALL_MPD=1; fi

echo "[1/7] Updating system"
sudo apt update
sudo apt upgrade -y

echo "[2/7] Installing packages"
PACKAGES=(
	polybar picom rofi
	kitty feh numlockx
	vim neofetch
	fonts-font-awesome fonts-unifont
	git zsh xdotool maim xss-lock network-manager-gnome
	ranger
)

if [ "$WM_PROFILE" = "i3" ] || [ "$WM_PROFILE" = "both" ]; then
	append_unique i3-wm i3lock i3status
fi

if [ "$WM_PROFILE" = "bspwm" ] || [ "$WM_PROFILE" = "both" ]; then
	append_unique bspwm sxhkd dunst brightnessctl pamixer playerctl jq wmctrl xdo xautolock acpi xclip
fi

if [ "$INSTALL_ALACRITTY" -eq 1 ]; then append_unique alacritty; fi
if [ "$INSTALL_BTOP" -eq 1 ]; then append_unique btop; fi
if [ "$INSTALL_JGMENU" -eq 1 ]; then append_unique jgmenu; fi
if [ "$INSTALL_QT_GTK" -eq 1 ]; then append_unique qt5ct lxappearance; fi
if [ "$INSTALL_THUNAR" -eq 1 ]; then append_unique thunar thunar-volman thunar-archive-plugin; fi
if [ "$INSTALL_MPD" -eq 1 ]; then append_unique mpd ncmpcpp mpc mpdris2; fi

sudo apt install -y "${PACKAGES[@]}"

echo "[3/7] Copying selected profiles"
if [ "$WM_PROFILE" = "i3" ] || [ "$WM_PROFILE" = "both" ]; then
	copy_i3_profile
fi
if [ "$WM_PROFILE" = "bspwm" ] || [ "$WM_PROFILE" = "both" ]; then
	copy_bspwm_profile
fi

copy_optional_components
copy_wallpapers
configure_rofi
configure_neofetch
configure_polybar_colors_for_i3
configure_terminal_default
configure_zsh
print_binary_notice

cat <<EOF

Installation complete.

Profile selected: $WM_PROFILE

Next steps:
1. Log out and choose your desired session (i3 or bspwm) from the login screen.
2. For i3, polybar can be launched with: ~/.config/polybar/launch.sh
3. For bspwm, ensure X11 session is enabled in your display manager.

EOF
