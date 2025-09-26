# Unified Nix Configuration

This directory contains a unified Nix flake configuration that manages both NixOS (Linux) and nix-darwin (macOS) systems using Home Manager for user-level package management and configuration.

## Structure

```
nix-rework/
├── flake.nix                          # Main flake configuration
├── systems/                           # System-specific configurations
│   ├── nixos/                        # NixOS configuration
│   │   ├── default.nix               # Main NixOS config
│   │   └── hardware-configuration.nix # Hardware-specific config
│   └── mac/                          # nix-darwin configuration
│       └── default.nix               # Main macOS config
├── modules/
│   ├── home-manager/                 # Home Manager configurations
│   │   ├── default.nix               # Main home config
│   │   ├── programs/                 # Program configurations
│   │   │   ├── default.nix
│   │   │   ├── git.nix
│   │   │   ├── zsh.nix
│   │   │   ├── neovim.nix
│   │   │   ├── tmux.nix
│   │   │   └── terminals.nix
│   │   └── services/                 # Service configurations
│   │       └── default.nix
│   └── shared/                       # Shared configurations
│       └── default.nix
└── README.md                         # This file
```

## Features

- **Unified Configuration**: Single flake manages both Linux and macOS systems
- **Home Manager Integration**: User-level packages and configurations
- **Platform Detection**: Automatically applies platform-specific configurations
- **Dotfile Symlinks**: Links to your existing dotfiles in the main directory
- **Modular Design**: Easy to customize and extend

## Setup Instructions

### Prerequisites

1. **Install Nix** (if not already installed):
   ```bash
   # macOS or Linux
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Enable flakes** (if not already enabled):
   ```bash
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

### NixOS Setup (Linux PC)

1. **Copy hardware configuration**:
   ```bash
   sudo cp /etc/nixos/hardware-configuration.nix ~/workspace/dotfiles/nix-rework/systems/nixos/
   ```

2. **Update flake inputs**:
   ```bash
   cd ~/workspace/dotfiles/nix-rework
   nix flake update
   ```

3. **Test the configuration**:
   ```bash
   sudo nixos-rebuild dry-build --flake .#nixos
   ```

4. **Apply the configuration**:
   ```bash
   sudo nixos-rebuild switch --flake .#nixos
   ```

### macOS Setup (nix-darwin)

1. **Install nix-darwin**:
   ```bash
   nix build .#darwinConfigurations.mac.system
   ./result/sw/bin/darwin-rebuild switch --flake .#mac
   ```

2. **For subsequent updates**:
   ```bash
   darwin-rebuild switch --flake ~/workspace/dotfiles/nix-rework#mac
   ```

### Home Manager (Optional Standalone)

If you want to use Home Manager without system-level Nix:

```bash
# Linux
home-manager switch --flake .#elavigne@nixos

# macOS  
home-manager switch --flake .#elavigne@mac
```

## Configuration Customization

### Adding New Programs

1. Create a new `.nix` file in `modules/home-manager/programs/`
2. Import it in `modules/home-manager/programs/default.nix`
3. Configure the program using Home Manager options

### Platform-Specific Configurations

Use the `isDarwin` variable to conditionally apply configurations:

```nix
{ config, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  # This will only apply on macOS
  programs.someProgram = pkgs.lib.mkIf isDarwin {
    enable = true;
    # macOS-specific settings
  };
  
  # This will only apply on Linux
  services.someService = pkgs.lib.mkIf (!isDarwin) {
    enable = true;
    # Linux-specific settings
  };
}
```

### Adding System Packages

- **System-level packages**: Add to `environment.systemPackages` in system configs
- **User-level packages**: Add to `home.packages` in Home Manager config

### Updating Dotfile Symlinks

To add new dotfile symlinks, edit the `xdg.configFile` section in `modules/home-manager/default.nix`.

## Daily Usage

### Useful Commands

```bash
# Update flake inputs
nix flake update

# Rebuild NixOS system
sudo nixos-rebuild switch --flake ~/workspace/dotfiles/nix-rework#nixos

# Rebuild macOS system  
darwin-rebuild switch --flake ~/workspace/dotfiles/nix-rework#mac

# Rebuild Home Manager only
home-manager switch --flake ~/workspace/dotfiles/nix-rework

# Check what will be built (dry run)
nixos-rebuild dry-build --flake ~/workspace/dotfiles/nix-rework#nixos
darwin-rebuild check --flake ~/workspace/dotfiles/nix-rework#mac

# Garbage collect old generations
sudo nix-collect-garbage -d
nix-collect-garbage -d

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
home-manager generations
```

### Shell Aliases

The zsh configuration includes helpful aliases:
- `rebuild-nixos`: Rebuild NixOS system
- `rebuild-darwin`: Rebuild macOS system  
- `rebuild-home`: Rebuild Home Manager

## Troubleshooting

### Common Issues

1. **Dotfile symlinks not working**: Ensure the dotfiles directory exists and paths are correct
2. **Permission errors**: Make sure you're using `sudo` for system rebuilds on NixOS
3. **Platform detection**: Check that `isDarwin` variable is working correctly
4. **Missing hardware config**: Copy from `/etc/nixos/hardware-configuration.nix` on NixOS

### Getting Help

- Check the [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- Check the [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)  
- Check the [Home Manager Manual](https://nix-community.github.io/home-manager/)
- Visit the [NixOS Discourse](https://discourse.nixos.org/)

## Migration Notes

This configuration is designed to work alongside your existing dotfiles. The old `nixos/` directory configuration is preserved for reference. Once you've verified everything works, you can:

1. Update your system to use this new flake
2. Remove the old `nixos/` directory if desired
3. Customize the configuration to your preferences

The configuration maintains compatibility with your existing dotfile structure by using symlinks to the original locations.
