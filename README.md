# 🌌 Sway Suite Dotfiles

[![Language: Bash](https://img.shields.io/badge/Language-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Shell: Fish](https://img.shields.io/badge/Shell-Fish-427A82?logo=fishshell&logoColor=white)](https://fishshell.com/)
[![Compositor: SwayFX](https://img.shields.io/badge/Compositor-SwayFX-336699?logo=wayland&logoColor=white)](https://github.com/WillPower3309/swayfx)
[![Dotfiles Manager: GNU Stow](https://img.shields.io/badge/Managed%20with-GNU%20Stow-darkblue)](https://www.gnu.org/software/stow/)

> **Dotfiles to maintain consistency across my Linux machines**  
> A productive, minimalist, and highly customizable Wayland environment built around **SwayFX**, managed via **GNU Stow**, featuring unified dynamic theme-switching and border/corner-radius engines with real-time hot-reloading.

---

## 🚀 The Core Differentiator: Unified Dynamic Engines (Hot-Reload)

Switching themes or window geometry across Linux setups usually requires editing configuration files in disparate directories and restarting either active applications or the entire graphical session.

This repository provides two dedicated, decoupled orchestrators:
1. **`global-theme-selector.sh`**: Instantly harmonizes color palettes across Kitty, Rofi, Sway, Swaylock, SwayNC, and Waybar.
2. **`global-border-selector.sh`**: Dynamically adjusts corner radiuses (0px, 10px, 18px) and border styles (visible accent color vs invisible border) across the entire suite in real time.

```text
                                 ┌─► Sway / SwayFX (swaymsg IPC - Window Borders & Radius)
                                 ├─► Waybar        (SIGUSR2 - CSS Hot Reload)
[ global-border-selector.sh ] ───┼─► SwayNC        (IPC Client - Card & Center Styles)
        (Rofi or CLI)            └─► Rofi          (Dynamic Window Border & Radius)
```

### ✨ Engine Highlights
- **Dual Usage Mode**: Interactive selection via **Rofi** menu or direct script invocation through the **CLI** (e.g., `./scripts/global-border-selector.sh rounded-colored`).
- **Zero Session Restarts**: Leverages POSIX kernel signals (`SIGUSR1`, `SIGUSR2`) and Sway IPC protocols to apply changes on the fly.
- **Theme Synchronization**: When switching color themes, active colored borders automatically adopt the new theme's accent color.
- **Decoupled Architecture**: Each application is handled by a standalone helper in `scripts/components/` and `scripts/components/borders/`.
- **Visual Feedback**: Desktop notifications via `notify-send` report success or component-level warnings.

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
| **App Launcher & Menus**| [Rofi (Wayland)](https://github.com/lbonn/rofi) | Application launcher, power menus, and style picker interface |
| **Screen Locker** | [Swaylock](https://github.com/swaywm/swaylock) | Secure screen locker dynamically styled before execution |
| **Dotfiles Manager** | [GNU Stow](https://www.gnu.org/software/stow/) | Symlink management maintaining symlinks into `$HOME` |

---

## 🏛️ Repository Architecture

The repository uses GNU Stow-ready modular packages, mirroring `$HOME/.config/`:

```text
~/.dotfiles/
├── fish/                              # Fish shell configurations and completions
├── kitty/                             # Kitty terminal + colors/ (nord, gruvbox, current.conf)
├── rofi/                              # Rofi launchers, colors/, and borders/
├── sway/                              # Core SwayFX config, keybindings, colors/, and borders/
├── swaylock/                          # Swaylock layout base + colors/ + generated config
├── swaync/                            # SwayNC config.json + style.css + colors/ + borders/
├── waybar/                            # Waybar config.jsonc + style.css + colors/ + borders/
│
├── scripts/
│   ├── global-theme-selector.sh       # Main theme orchestrator (Rofi & CLI)
│   ├── global-border-selector.sh      # Main border & radius orchestrator (Rofi & CLI)
│   └── components/                    # Isolated per-application theme modules
│       ├── kitty.sh
│       ├── rofi.sh
│       ├── sway.sh
│       ├── swaylock.sh
│       ├── swaync.sh
│       ├── waybar.sh
│       └── borders/                   # Isolated per-application border modules
│           ├── rofi.sh
│           ├── sway.sh
│           ├── swaync.sh
│           └── waybar.sh
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

### 4. Running the Global Border Selector

**Interactive Mode (Rofi Menu):**
```bash
~/.dotfiles/scripts/global-border-selector.sh
```

**Direct CLI Mode:**
```bash
# Rounded with accent border
~/.dotfiles/scripts/global-border-selector.sh rounded-colored

# Sharp with no border
~/.dotfiles/scripts/global-border-selector.sh sharp-none

# Extra rounded with no border
~/.dotfiles/scripts/global-border-selector.sh extra-none
```

---

## 📐 Border & Radius Presets

The border engine provides 6 standardized presets:

| Preset | Corner Radius | Border Outline |
| :--- | :--- | :--- |
| `sharp-none` | **0px** (Sharp) | None (0px) |
| `sharp-colored` | **0px** (Sharp) | 2px Accent Solid |
| `rounded-none` | **10px** (Moderate) | None (0px) |
| `rounded-colored` | **10px** (Moderate) | 2px Accent Solid |
| `extra-none` | **18px** (Extra) | None (0px) |
| `extra-colored` | **18px** (Extra) | 2px Accent Solid |

---

## 🎨 Available Themes & Adding New Ones

Currently curated palettes:
- **Nord** (Arctic, cool, and crisp)
- **Gruvbox** (Warm, retro, and ergonomic)

> 💡 **Want to add a new theme or border preset?**  
> Check the developer reference in [AGENTS.md](file:///home/joaofedora/.dotfiles/AGENTS.md). The process is streamlined: drop a config file with the same identifier into each component's directory and register it in the orchestrator scripts.
