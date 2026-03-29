```
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
```

𓆝 𓆟 𓆞 𓆝 𓆟

Personal **Pop_OS!** dotfiles to customize a minimal, lightweight, keyboard-driven desktop environment.

The installer now supports an interactive merge workflow for:
- `i3` profile (original setup)
- `bspwm` profile (imported from `dotfiles-bspwm`)
- `both` profiles in the same system

## Preview

![Pop_OS Desktop](screenshots/Dotfile1.png)

![Neofetch](screenshots/Dotfile2.png)

![Full environment](screenshots/Dotfile3.png)

---
> [!IMPORTANT]
> If you're new to **i3 Window Manager**, check the official reference card:
https://i3wm.org/docs/refcard.html

---

## Installation

### 1. Clone the repository

Open a terminal and run:

```bash
git clone git@github.com:Talbot-dev/Pop_os-dotfile-config.git
```
Make sure your **GitHub SSH credentials** are configured before cloning.

The repository will be installed on **$HOME** 

### 2. Enter the project directory

```bash
cd Pop_os-dotfile-config
```
### 3. Make the installer executable

```bash
sudo chmod +x popOS.sh
```

### 4. Run the installer

```bash
./popOS.sh
```

The installer now lets you choose:
- Window manager profile: `i3`, `bspwm`, or `both`
- Optional components: `alacritty`, `ranger`, `btop`, `jgmenu`, `qt5ct/gtk`, `Thunar`, `mpd/ncmpcpp`

Core setup includes:
- `rofi`, `picom`, `neofetch`, `zsh` + Oh My Zsh plugins
- Wallpaper and screenshot directories
- Dotfiles merge from `config/` and `dotfiles-bspwm/config/` according to the selected profile

---
### 🔄 Reboot / Relogin
Restart or log out, then select your session (`i3` or `bspwm`) on the login screen.

If Polybar does not show up after login, run:

```bash
~/.config/polybar/launch.sh
```

> [!NOTE]
> `dotfiles-bspwm/app support/*.pkg.tar.zst` are Arch packages and are intentionally **not installed** on Pop!_OS.

#### Enjoy the custom Pop_OS! environment

---

## Uninstallation

If you want to undo all changes and remove the settings installed by this script, run the uninstaller

```bash
sudo chmod +x uninstall_popOS.sh
./uninstall_popOS.sh
```

This will uninstall packages and configuration files and restore the default terminal, if applicable. To fully restore the previous environment, I recommend restarting or logging out after uninstallation.

> [!NOTE]
> This configuration can be applied to any distro based on Ubuntu/Debian
---
Talbot dev ( ദ്ദി ˙ᗜ˙ )
