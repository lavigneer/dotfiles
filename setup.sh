#!/usr/bin/env bash
set -e

# setup.sh - Install dotfiles in VS Code devcontainer
# This script installs Nix with flakes support and applies home-manager configuration

echo "🚀 Starting dotfiles setup for devcontainer..."

# Check if Nix is already installed
if command -v nix &> /dev/null; then
    echo "✅ Nix is already installed"
else
    echo "📥 Installing Nix..."
    # Use official Nix installer in single-user mode (no systemd required)
    sh <(curl -L https://nixos.org/nix/install) --no-daemon

    # Source Nix for single-user install
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"

    # Enable flakes
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# Get the dotfiles directory (where this script is located)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📂 Dotfiles directory: $DOTFILES_DIR"

# Install home-manager if not already available
if ! command -v home-manager &> /dev/null; then
    echo "📥 Installing home-manager..."
    nix run home-manager/master -- init --switch
fi

# Apply home-manager configuration from the flake
echo "🏠 Applying home-manager configuration..."
cd "$DOTFILES_DIR"

# Apply the container configuration
nix run home-manager -- switch --flake "$DOTFILES_DIR#$USER@container"

echo "✅ Dotfiles setup complete!"
echo "💡 You may need to restart your shell for all changes to take effect"
