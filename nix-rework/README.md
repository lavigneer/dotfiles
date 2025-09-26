# Nix Configuration

A clean, modular Nix configuration supporting both NixOS and nix-darwin with Home Manager integration.

## 🏗️ Architecture

This configuration uses a layered architecture with shared components and platform-specific overrides:

```
nix-rework/
├── flake.nix                    # Main flake entry point
├── shared/                      # Cross-platform components
├── linux/                      # Linux/NixOS specific
├── darwin/                      # macOS/nix-darwin specific
└── systems/                     # Machine-specific configs
```

## 📁 Directory Structure

### `shared/` - Cross-platform Components
```
shared/
├── home-manager/               # User-level configs
│   ├── cli-tools.nix          # CLI utilities (fzf, ripgrep, direnv, yazi)
│   ├── development.nix        # Programming languages & tools
│   ├── git.nix               # Git configuration
│   ├── neovim.nix            # Neovim with LSPs and tools
│   ├── zsh.nix               # Zsh with oh-my-zsh and starship
│   ├── tmux.nix              # Tmux configuration
│   ├── terminals.nix         # Terminal emulators (ghostty)
│   ├── zed.nix               # Zed editor
│   ├── browser.nix           # Web browser (Chrome)
│   ├── discord.nix           # Discord
│   ├── docker.nix            # Docker tools (lazydocker)
│   ├── thunderbird.nix       # Email client
│   └── core.nix              # Basic Home Manager setup
└── system/                    # System-level configs
    ├── nix.nix               # Core Nix settings
    ├── fonts.nix             # Font packages
    ├── shell.nix             # System shell config
    └── stylix.nix            # Theming with Stylix
```

### `linux/` - Linux Platform
```
linux/
├── default.nix               # Linux platform defaults
└── modules/
    ├── system/               # System-level Linux configs
    │   ├── gaming.nix       # Steam and gaming setup
    │   ├── polybar.nix      # Status bar (shared across WMs)
    │   └── rofi.nix         # Application launcher (shared)
    ├── programs/             # User programs (Linux-specific)
    │   ├── desktop-apps.nix # Desktop applications
    │   └── gaming.nix       # User gaming tools (lutris)
    └── window-managers/      # Window manager configs
        ├── wayland.nix      # Wayland ecosystem (mako, grim, slurp, kanshi)
        ├── x11.nix          # X11 ecosystem (dunst, picom, feh, xss-lock)
        ├── i3.nix           # i3 window manager
        ├── sway.nix         # Sway compositor
        └── hyprland.nix     # Hyprland compositor
```

### `darwin/` - macOS Platform
```
darwin/
├── default.nix               # macOS platform defaults
└── modules/
    ├── programs/
    │   └── karabiner.nix     # Karabiner-Elements key remapping
    └── window-managers/
        └── aerospace.nix     # AeroSpace tiling window manager
```

### `systems/` - Machine-specific Configurations
```
systems/
├── nixos/                    # Linux machine config
│   ├── default.nix         # NixOS system configuration
│   └── hardware-configuration.nix
└── mac/                      # macOS machine config
    └── default.nix          # nix-darwin system configuration
```

## 🎯 Key Features

### Modular Design
- **Shared components** for cross-platform consistency
- **Platform-specific modules** for Linux and macOS differences
- **Machine-specific overrides** for personal preferences

### Window Manager Support
- **Linux**: i3 (X11), Sway (Wayland), Hyprland (Wayland)
- **macOS**: AeroSpace tiling window manager
- **Unified tools**: Rofi launcher and Polybar status bar across all WMs

### Development Environment
- **Languages**: Rust, Go, Node.js, Nix
- **Editors**: Neovim (with LSPs), Zed Editor
- **Tools**: Git, Docker, CLI utilities

### Clean Architecture
- **DRY principle**: No code duplication
- **Layered imports**: Platform defaults → Machine overrides
- **Consistent formatting**: Clean, readable configuration

## 🚀 Usage

### Build NixOS System
```bash
sudo nixos-rebuild switch --flake ~/workspace/dotfiles/nix-rework#nixos
```

### Build macOS System
```bash
darwin-rebuild switch --flake ~/workspace/dotfiles/nix-rework#mac
```

### Development Shell
```bash
nix develop
```

## 🔧 Configuration

### Adding New Programs
1. **Cross-platform**: Add to `shared/home-manager/`
2. **Linux-specific**: Add to `linux/modules/programs/`
3. **macOS-specific**: Add to `darwin/modules/programs/`

### Adding New Window Managers
1. Create new file in `linux/modules/window-managers/`
2. Import appropriate base module (`wayland.nix` or `x11.nix`)
3. Import shared components (`../system/polybar.nix`, `../system/rofi.nix`)
4. Add to system imports in `systems/nixos/default.nix`

### Customizing Per Machine
- Edit files in `systems/*/default.nix`
- Override platform defaults using higher priority
- Add machine-specific Home Manager module imports

## 📋 System Requirements

- **NixOS**: 25.05 or later
- **nix-darwin**: Compatible version
- **Home Manager**: Latest stable
- **Flakes**: Enabled (`experimental-features = nix-command flakes`)

## 🎨 Theming

The configuration uses Stylix for consistent theming across:
- Terminal applications
- Desktop environments
- Development tools

Theme is configured in `shared/system/stylix.nix` and enabled for both platforms.

## 🔄 Updates

To update all inputs:
```bash
nix flake update
```

To update specific input:
```bash
nix flake lock --update-input nixpkgs
```

## 📝 Notes

- **Email configuration** is machine-specific (personal vs work)
- **Gaming setup** is Linux-only
- **Polybar** works on Wayland via XWayland
- **Rofi 2.0.0+** has native Wayland support
- **Configuration files** are symlinked from dotfiles directory

## 🤝 Contributing

This is a personal configuration, but feel free to use it as inspiration for your own setup. The modular architecture makes it easy to adapt to different needs.