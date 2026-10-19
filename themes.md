# 🎨 UI & GTK Theme Pairing Guide (`themes.md`)

This guide provides recommended pairings for **GTK Themes**, **Icon Packs**, **Cursor Themes**, and **Fonts** to match each color palette available in the Sway Suite.

> [!NOTE]
> **Optional Configuration**: Installing external GTK themes, icons, and cursor sets is completely **optional**. The internal dynamic engine ([scripts/global-theme-selector.sh](scripts/global-theme-selector.sh)) automatically themes Sway, Kitty, Waybar, Rofi, SwayNC, and Swaylock. The pairings documented below reflect the **author's personal setup** and recommended aesthetics for native GTK3/GTK4 and Qt applications.

---

## 🌐 Global Assets

These elements are configured globally across all palettes:

| Element | Selection | Reference / Link | Notes |
| :--- | :--- | :--- | :--- |
| **Global Font** | **JetBrainsMono Nerd Font** | [Nerd Fonts](https://www.nerdfonts.com/) | Standard monospace font for terminal, Waybar, Rofi, and Sway UI. Any Nerd Font of your choice can be substituted. |
| **Cursor Theme** | **s1mple-cursor-dark** (`Simp1e-Dark`) | [Gnome-Look](https://www.gnome-look.org/p/1932768) | Defined in [sway/.config/sway/config](sway/.config/sway/config) via `seat seat0 xcursor_theme Simp1e-Dark 24`. Global fallback across all color schemes. |

---

## 📑 Theme Pairing Matrix

| Suite Theme (`ID`) | Palette Aesthetic | GTK Theme | Icon Theme | Cursor Theme | Status & Origin |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`amoled`** | Pure Pitch Black (#000000) & High Contrast | [BOOmerang-Blackout](https://github.com/B00merang-Project/B00merang-Blackout) | [KDE-Classic-Icons](https://store.kde.org/p/2379533) | [s1mple-cursor-dark](https://www.gnome-look.org/p/1932768) | ⭐ **Author's Active Config** |
| **`nord`** | Arctic, Cool Blue & Frost | [Nordic](https://github.com/EliverLara/Nordic) | [Nordzy](https://github.com/alvatip/Nordzy-icon) | [Nordzy-cursors](https://github.com/alvatip/Nordzy-cursors) *(or Simp1e-Dark)* | Suggested Companion |
| **`gruvbox`** | Warm, Retro & Earth Tones | [Gruvbox-GTK](https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme) | [Gruvbox-Plus](https://github.com/SylEleuth/gruvbox-plus-icon-pack) | [Capitaine-cursors-gruvbox](https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme) *(or Simp1e-Dark)* | Suggested Companion |
| **`catppuccin-mocha`** | Soothing Pastel Dark | [Catppuccin-GTK (Mocha)](https://github.com/catppuccin/gtk) | [Papirus (Catppuccin Mocha)](https://github.com/catppuccin/papirus-folders) | [Catppuccin-Mocha-Cursors](https://github.com/catppuccin/cursors) *(or Simp1e-Dark)* | Suggested Companion |

---

## 🛠️ How to Apply GTK, Icon, and Cursor Themes

To ensure native GTK3/GTK4 applications and Flatpaks adopt your chosen theme and icon set:

### Method 1: Using `gsettings` (Command Line)

```bash
# Set GTK Theme (e.g., BOOmerang-Blackout)
gsettings set org.gnome.desktop.interface gtk-theme "BOOmerang-Blackout"

# Set Icon Theme (e.g., KDE-Classic-Icons)
gsettings set org.gnome.desktop.interface icon-theme "KDE-Classic-Icons"

# Set Cursor Theme & Size (e.g., Simp1e-Dark)
gsettings set org.gnome.desktop.interface cursor-theme "Simp1e-Dark"
gsettings set org.gnome.desktop.interface cursor-size 24

# Set Font
gsettings set org.gnome.desktop.interface font-name "JetBrainsMono Nerd Font 10"
```

### Method 2: Configuration Files (`~/.config/gtk-3.0/settings.ini` & `gtk-4.0`)

Create or update `~/.config/gtk-3.0/settings.ini`:

```ini
[Settings]
gtk-theme-name=BOOmerang-Blackout
gtk-icon-theme-name=KDE-Classic-Icons
gtk-cursor-theme-name=Simp1e-Dark
gtk-cursor-theme-size=24
gtk-font-name=JetBrainsMono Nerd Font 10
gtk-application-prefer-dark-theme=1
```

*(You can copy or symlink this file to `~/.config/gtk-4.0/settings.ini` for GTK4 apps).*

### Method 3: Graphical Configuration Tool

You can also use GUI tools built for Wayland environments to manage these settings easily:
- **`nwg-look`**: Highly recommended GTK3/GTK4 settings editor for wlroots / Sway.
- **`lxappearance`**: Standard X11/GTK utility (requires XWayland).

---

## 🗂️ Theme & Icon Installation Directories

Place downloaded themes and icon packs into the standard user directories:
- **GTK Themes**: `~/.themes/` or `~/.local/share/themes/`
- **Icon Packs & Cursors**: `~/.icons/` or `~/.local/share/icons/`
- **Fonts**: `~/.local/share/fonts/` (run `fc-cache -fv` after installing)
