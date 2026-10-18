# 🌌 Sway Suite Dotfiles

[![Language: Bash](https://img.shields.io/badge/Language-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Shell: Fish](https://img.shields.io/badge/Shell-Fish-427A82?logo=fishshell&logoColor=white)](https://fishshell.com/)
[![Compositor: SwayFX](https://img.shields.io/badge/Compositor-SwayFX-336699?logo=wayland&logoColor=white)](https://github.com/WillPower3309/swayfx)
[![Dotfiles Manager: GNU Stow](https://img.shields.io/badge/Managed%20with-GNU%20Stow-darkblue)](https://www.gnu.org/software/stow/)

> **Dotfiles to maintain consistency across my Linux machines**  
> A productive, minimalist, and highly customizable Wayland environment built around **SwayFX**, managed via **GNU Stow**, featuring an exclusive unified dynamic theme-switching engine with real-time hot-reloading.

---

## 🚀 The Core Differentiator: Unified Theme Engine (Hot-Reload)

Switching themes across Linux setups usually requires editing configuration files in disparate directories and restarting either active applications or the entire graphical session.

In this repository, the highlight is **`global-theme-selector.sh`**: a modular suite of scripts that instantly harmonizes the color palette across the entire desktop environment simultaneously — **Kitty, Rofi, Waybar, SwayNC, and Swaylock** — with zero downtime, no closed terminals, and no desktop restarts.

```text
                               ┌─► Kitty      (SIGUSR1 - Hot Reload)
                               ├─► Waybar     (SIGUSR2 - CSS Hot Reload)
[ global-theme-selector.sh ] ──┼─► SwayNC     (IPC Client - Style Reload)
       (Rofi or CLI)           ├─► Swaylock   (Config Merger)
                               └─► Rofi       (Current Import)
```

### ✨ Theme Engine Highlights
- **Dual Usage Mode**: Interactive selection via **Rofi** menu or direct script invocation through the **CLI** (`./scripts/global-theme-selector.sh gruvbox`).
- **Zero Session Restarts**: Leverages POSIX kernel signals (`SIGUSR1`, `SIGUSR2`) and IPC protocols to apply changes on the fly.
- **Decoupled Architecture**: Each application is handled by a standalone helper in `scripts/components/` that can be tested or invoked independently.
- **Visual Feedback**: Clean aggregated desktop notification reporting success or component-level warnings.

---

## 🛠️ Tech Stack & Languages

| Category / Component | Technology | Role in System |
| :--- | :--- | :--- |
| **Primary Scripting** | [Bash](https://www.gnu.org/software/bash/) | Core logic for modular component helpers and orchestrator scripts |
| **Interactive Shell** | [Fish Shell](https://fishshell.com/) | Daily driver interactive shell with intelligent auto-completions |
| **Styling & Palettes** | CSS3 & RASI | Modular stylesheets defining color variables across UI components |
| **Window Manager** | [SwayFX](https://github.com/WillPower3309/swayfx) | Wayland compositor with rounded corners, window shadows, and blur effects |
| **Terminal Emulator** | [Kitty](https://sw.kovidgoyal.net/kitty/) | Fast GPU-accelerated terminal with native live-reloading support |
| **Status Bar** | [Waybar](https://github.com/Alexays/Waybar) | Customizable bar styled with CSS and real-time stylesheet updates |
| **Notification Center** | [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) | Sleek notification center and quick-settings panel for Wayland |
| **App Launcher & Menus**| [Rofi (Wayland)](https://github.com/lbonn/rofi) | Application launcher, power menus, and theme picker interface |
| **Screen Locker** | [Swaylock](https://github.com/swaywm/swaylock) | Secure screen locker dynamically styled before execution |
| **Dotfiles Manager** | [GNU Stow](https://www.gnu.org/software/stow/) | Symlink management maintaining symlinks into `$HOME` |

---

## 🏛️ Repository Architecture

The repository uses GNU Stow-ready modular packages, mirroring `$HOME/.config/`:

```text
~/.dotfiles/
├── fish/                              # Fish shell configurations and completions
├── kitty/                             # Kitty terminal + colors/ (nord, gruvbox, current.conf)
├── rofi/                              # Rofi launchers, applets, and colors/
├── sway/                              # Core SwayFX compositor configuration and keybindings
├── swaylock/                          # Swaylock layout base + colors/ + generated config
├── swaync/                            # SwayNC config.json + style.css + colors/
├── waybar/                            # Waybar config.jsonc + style.css + colors/
│
├── scripts/
│   ├── global-theme-selector.sh       # Main theme orchestrator (Rofi & CLI)
│   └── components/                    # Isolated per-application theme modules
│       ├── kitty.sh
│       ├── rofi.sh
│       ├── swaylock.sh
│       ├── swaync.sh
│       └── waybar.sh
│
├── AGENTS.md                          # Technical architecture & developer guide
└── README.md                          # Project documentation
```

---

## 📦 Installation & Setup

### 1. Clone the repository
```bash
git clone https://github.com/JoaoPedro787/sway-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Symlink packages using GNU Stow
Symlink the components into your home directory:
```bash
# Link all modules at once
stow fish kitty rofi sway swaylock swaync waybar
```

### 3. Running the Global Theme Selector

**Interactive Mode (Rofi Menu):**
```bash
~/.dotfiles/scripts/global-theme-selector.sh
```

**Direct CLI Mode:**
```bash
# Switch to Nord
~/.dotfiles/scripts/global-theme-selector.sh nord

# Switch to Gruvbox
~/.dotfiles/scripts/global-theme-selector.sh gruvbox
```

---

## 🎨 Available Themes & Adding New Ones

Currently curated palettes:
- **Nord** (Arctic, cool, and crisp)
- **Gruvbox** (Warm, retro, and ergonomic)

> 💡 **Want to add a new theme?**  
> Check the developer reference in [AGENTS.md](file:///home/joaofedora/.dotfiles/AGENTS.md). The process is streamlined: drop a color file with the same name into each component's `colors/` directory and add the theme identifier to the `AVAILABLE_THEMES` array in [scripts/global-theme-selector.sh](file:///home/joaofedora/.dotfiles/scripts/global-theme-selector.sh).
