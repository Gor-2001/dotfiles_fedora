#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Fedora Dev Setup ==="
echo "Dotfiles directory: $DOTFILES_DIR"

# Check if running on Fedora
if ! command -v dnf &>/dev/null; then
    echo "Error: This script is designed for Fedora (dnf not found)"
    exit 1
fi

# -----------------------------
# System update
# -----------------------------
echo "[1/7] Updating system..."
sudo dnf update -y

# -----------------------------
# Core packages
# -----------------------------
echo "[2/7] Installing core packages..."
sudo dnf install -y \
  git \
  stow \
  neovim \
  vim \
  fzf \
  ripgrep \
  fd-find \
  bat \
  tree \
  htop \
  cmake \
  meson \
  ninja-build \
  clang \
  clang-tools-extra \
  lldb \
  gh \
  lazygit

# -----------------------------
# Development toolchains
# -----------------------------
echo "[3/7] Installing development tools..."
sudo dnf groupinstall -y "Development Tools" "Development Libraries"

# -----------------------------
# Rust (rustup)
# -----------------------------
echo "[4/7] Setting up Rust..."
if ! command -v rustc &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
else
  echo "Rust already installed"
fi

# Ensure cargo is in PATH for this script
export PATH="$HOME/.cargo/bin:$PATH"

# -----------------------------
# Rust CLI tools
# -----------------------------
echo "[5/7] Installing Rust CLI tools..."
cargo install --locked zoxide starship 2>/dev/null || true

# -----------------------------
# Stow dotfiles
# -----------------------------
echo "[6/7] Symlinking dotfiles with GNU Stow..."

cd "$DOTFILES_DIR"

# Remove existing files that would conflict
for pkg in bash vim git gnome-terminal; do
    if [ -d "$pkg" ]; then
        # Get list of files that would be stowed
        stow -n -v "$pkg" 2>&1 | grep -oP '(?<==> ).*' | while read -r file; do
            target="$HOME/$file"
            if [ -e "$target" ] && [ ! -L "$target" ]; then
                echo "  Backing up existing file: $file"
                mv "$target" "${target}.backup-$(date +%Y%m%d-%H%M%S)"
            fi
        done
    fi
done

# Stow all packages
for pkg in bash vim git gnome-terminal; do
    if [ -d "$pkg" ]; then
        echo "  Stowing $pkg..."
        stow -v "$pkg"
    fi
done

# -----------------------------
# Post-setup configuration
# -----------------------------
echo "[7/7] Final configuration..."

# Initialize starship if installed
if command -v starship &>/dev/null; then
    echo "Starship prompt installed. It will activate on next shell start."
fi

# Initialize zoxide if installed
if command -v zoxide &>/dev/null; then
    echo "Zoxide installed. It will activate on next shell start."
fi

echo ""
echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Restart your shell or run: source ~/.bashrc"
echo "  2. Edit ~/.gitconfig to set your email/name"
echo "  3. Optional: Install fonts for starship prompt"
echo ""
echo "Backup files (if any) are saved with .backup-* suffix"
