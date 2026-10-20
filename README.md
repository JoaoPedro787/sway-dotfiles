# 🌌 Sway Suite Dotfiles

[![Language: Bash](https://img.shields.io/badge/Language-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Shell: Fish](https://img.shields.io/badge/Shell-Fish-427A82?logo=fishshell&logoColor=white)](https://fishshell.com/)
[![Compositor: SwayFX](https://img.shields.io/badge/Compositor-SwayFX-336699?logo=wayland&logoColor=white)](https://github.com/WillPower3309/swayfx)
[![Dotfiles Manager: GNU Stow](https://img.shields.io/badge/Managed%20with-GNU%20Stow-darkblue)](https://www.gnu.org/software/stow/)

> **Dotfiles to maintain consistency across my Linux machines**  
> A productive, minimalist, and highly customizable Wayland environment built around **SwayFX**, managed via **GNU Stow**, featuring unified dynamic theme-switching and border/corner-radius engines with real-time hot-reloading.

---

## 🚀 The Core Differentiator: Unified Dynamic Engines (Hot-Reload)

Switching themes or window geometry across Linux setups usually requires editing configuration files in disparate directories and restarting either active applications or the entire graphical sessThis repository provides three dedicated, decoupled orchestrators:
1. **`global-theme-selector.sh`**: Instantly harmonizes color palettes across Kitty, Rofi, Sway, Swaylock, SwayNC, and Waybar.
2. **`global-border-selector.sh`**: Dynamically adjusts corner radiuses (0px, 10px, 18px) and border styles (visible accent color vs invisible border) across the entire suite in real time.
3. **`waybar-layout-selector.sh`**: Seamlessly switches between modular Waybar layouts and geometries while maintaining full synchronization with the global color and border engines.

```text
                                  ┌─► Sway / SwayFX (swaymsg IPC - Window Borders & Radius)
                                  ├─► Waybar        (SIGUSR2 - CSS Hot Reload)
[ global-border-selector.sh ] ───┼─► SwayNC        (IPC Client - Card & Center Styles)
        (Rofi or CLI)            └─► Rofi          (Dynamic Window Border & Radius)

[ waybar-layout-selector.sh ] ───► Waybar          (Dynamic Symlinks & Hot Process Reload)
        (Rofi or CLI)                              (Inherits Colors & Border Presets)
```

### ✨ Engine Highlights
- **Dual Usage Mode**: Interactive selection via **Rofi** menu or direct script invocation through the **CLI** (e.g., `./scripts/global-border-selector.sh rounded-colored` or `./scripts/waybar-layout-selector.sh example`).
- **Zero Session Restarts**: Leverages POSIX kernel signals (`SIGUSR1`, `SIGUSR2`) and Sway IPC protocols to apply changes on the fly.
- **Theme & Border Synchronization**: When switching Waybar layouts, the newly loaded bar immediately inherits the currently active theme palette and border preset.
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
| **Status Bar** | [Waybar](https://github.com/Alexays/Waybar) | Customizable bar with modular layout switching and real-time stylesheet updates |
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
├── waybar/                            # Waybar layouts/ + colors/ + borders/ + active symlinks
│   └── layouts/                       # Modular Waybar layout variants (default, example, etc.)
│
├── scripts/
│   ├── global-theme-selector.sh       # Main theme orchestrator (Rofi & CLI)
│   ├── global-border-selector.sh      # Main border & radius orchestrator (Rofi & CLI)
│   ├── waybar-layout-selector.sh      # Main Waybar layout orchestrator (Rofi & CLI)
│   └── components/                    # Isolated per-application theme and layout modules
│       ├── kitty.sh
│       ├── rofi.sh
│       ├── sway.sh
│       ├── swaylock.sh
│       ├── swaync.sh
│       ├── waybar.sh                  # Waybar color component
│       ├── waybar-layout.sh           # Waybar layout switcher component
│       └── borders/                   # Isolated per-application border modules
│           ├── rofi.sh
│           ├── sway.sh
│           ├── swaync.sh
│           └── waybar.sh
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

### 5. Running the Waybar Layout Selector

**Interactive Mode (Rofi Menu):**
```bash
~/.dotfiles/scripts/waybar-layout-selector.sh
```

**Direct CLI Mode:**
```bash
# Switch to standard full layout
~/.dotfiles/scripts/waybar-layout-selector.sh default

# Switch to floating example layout
~/.dotfiles/scripts/waybar-layout-selector.sh example

# List all available layouts
~/.dotfiles/scripts/waybar-layout-selector.sh --list
```

---

## 📊 Modular Waybar Layouts

Waybar configurations are modularized under `waybar/.config/waybar/layouts/`. The active configuration and style are managed via dynamic symlinks (`config.jsonc` and `style.css`), allowing instant switching without losing theme or border styling.

| Layout | Style & Geometria | Modules & Description |
| :--- | :--- | :--- |
| `default` | Edge-to-edge top bar (44px) | Full status bar with workspace list, cava visualizer, mpris media player, hardware monitors (CPU/RAM), tray, and power menu. |
| `example` | Floating island bar (40px) | Minimalist floating bar with side margins, centered date/clock, essential audio, network, battery, and notification controls. |
| `simple` | Framed perimeter simple bar (38px) | Minimalist frame border with Fedora branding, workspaces, audio, battery, SwayNC, and quick power actions. |
| `block-1` | Modular block badges bar (20px) | Vibrant colored badges per module with solid border framing, workspaces with hover state, and center clock. |
| `block-2` | Colored glyph outline bar (20px) | Colored icon glyphs with distinct per-module solid borders and centered clock. |
| `block-3` | Uniform block boxes bar (20px) | Consistent dark module button boxes with subtle borders and centered clock. |
| `block-4` | Continuous full bar (20px) | Continuous solid background bar with block modules and right-aligned clock. |

### 🔄 Automatic Color & Border Inheritance
Every Waybar layout automatically connects to the Theme Suite and Border Suite via standard imports:
- `@import "colors/current.css";` (loaded at top)
- `@import "borders/current.css";` (loaded at bottom)

When switching themes (`global-theme-selector.sh`) or border presets (`global-border-selector.sh`), your active Waybar layout updates immediately via `SIGUSR2` without restarting the process.

---

## 📐 Border & Radius Presets

The border engine provides 6 standardized presets:

| Preset | Corner Radius | Border Outline |
| :--- | :--- | :--- |
| `sharp-none` | **0px** (Sharp) | None (0px) |
| `sharp-colored` | **0px** (Sharp) | 1px Accent Solid |
| `sharp-colored-2px` | **0px** (Sharp) | 2px Accent Solid |
| `rounded-none` | **10px** (Moderate) | None (0px) |
| `rounded-colored` | **10px** (Moderate) | 1px Accent Solid |
| `rounded-colored-2px` | **10px** (Moderate) | 2px Accent Solid |

---

## 🎨 Available Themes & Pairing Guide

Currently curated palettes:
- **Amoled** (Pitch black, minimalist, high contrast)
- **Nord** (Arctic, cool, and crisp)
- **Gruvbox** (Warm, retro, and ergonomic)
- **Catppuccin Mocha** (Soothing pastel dark)

> 🎨 **Looking for recommended GTK themes, icons, and cursor pairings?**  
> Check the [UI & GTK Theme Pairing Guide](themes.md).
>
> 💡 **Want to add a new theme, border preset, or Waybar layout?**  
> Check the comprehensive developer reference in [AGENTS.md](AGENTS.md). The process is fully standardized and modular.

