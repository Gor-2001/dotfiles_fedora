#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "========================================="
echo "   Fedora 43 Development Environment"
echo "========================================="
echo "Dotfiles directory: $DOTFILES_DIR"
echo ""

# -----------------------------
# Check Fedora version
# -----------------------------
if ! command -v dnf &>/dev/null; then
    echo "Error: This script is designed for Fedora (dnf not found)"
    exit 1
fi

fedora_version=$(rpm -E %fedora)
echo "Detected Fedora version: $fedora_version"
if [ "$fedora_version" != "43" ]; then
    echo "Warning: This script is tested on Fedora 43, you're running $fedora_version"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# -----------------------------
# Armenian keyboard fix
# -----------------------------
echo "[1/8] Applying Armenian keyboard layout fix..."
if [ -f /usr/share/X11/xkb/symbols/am ]; then
    sudo sed -i '80s/Armenian_ra,\s*Armenian_RA/Armenian_re, Armenian_RE/' /usr/share/X11/xkb/symbols/am
    sudo sed -i '89s/Armenian_re,\s*Armenian_RE/Armenian_ra, Armenian_RA/' /usr/share/X11/xkb/symbols/am
    echo "  ✓ Armenian keyboard layout fixed"
else
    echo "  ⚠ Armenian keyboard file not found, skipping"
fi

# -----------------------------
# Sudoers configuration
# -----------------------------
echo "[2/8] Configuring passwordless power commands..."
echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/poweroff, /usr/bin/reboot, /usr/bin/systemctl suspend" | sudo tee /etc/sudoers.d/nopasswd-power > /dev/null
sudo chmod 440 /etc/sudoers.d/nopasswd-power
echo "  ✓ Passwordless poweroff/reboot/suspend enabled"

# -----------------------------
# System update
# -----------------------------
echo "[3/8] Updating system..."
sudo dnf update -y

# -----------------------------
# Core packages
# -----------------------------
echo "[4/8] Installing core packages..."
sudo dnf install -y \
    git \
    vim \
    neovim \
    fzf \
    ripgrep \
    fd-find \
    tree \
    htop \
    btop \
    cmake \
    meson \
    ninja-build \
    clang \
    clang-tools-extra \
    lldb \
    gdb \
    valgrind \
    gh \
    tmux \
    curl \
    wget \
    unzip \
    tar \
    fastfetch


# ----------------------------
# Rust toolchain
# -----------------------------
echo "[5/7] Setting up Rust..."
if ! command -v rustc &>/dev/null; then
    echo "  Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
    source "$HOME/.cargo/env"
    echo "  ✓ Rust installed"
else
    echo "  ✓ Rust already installed ($(rustc --version))"
fi

# Ensure cargo is in PATH
export PATH="$HOME/.cargo/bin:$PATH"

# -----------------------------
# Rust CLI tools
# -----------------------------
echo "[6/7] Installing Rust-based CLI tools..."

install_cargo_tool() {
    local tool=$1
    if ! command -v "$tool" &>/dev/null; then
        echo "  Installing $tool..."
        cargo install --locked "$tool"
    else
        echo "  ✓ $tool already installed"
    fi
}

install_cargo_tool zoxide
install_cargo_tool eza
install_cargo_tool bat

# Starship (has its own installer)
if ! command -v starship &>/dev/null; then
    echo "  Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    echo "  ✓ Starship installed"
else
    echo "  ✓ Starship already installed"
fi

# -----------------------------
# Symlink dotfiles
# -----------------------------
echo "[7/7] Symlinking dotfiles..."

# Create backup directory if needed
mkdir -p "$BACKUP_DIR"

# Function to safely symlink files
safe_symlink() {
    local source="$1"
    local target="$2"
    
    # Skip if source doesn't exist
    if [ ! -f "$source" ]; then
        echo "  ⚠ Source file not found: $source"
        return
    fi
    
    # Create target directory if needed
    local target_dir=$(dirname "$target")
    mkdir -p "$target_dir"
    
    # Backup existing file if it exists and is not a symlink to our dotfile
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "  Backing up: $(basename $target)"
        mv "$target" "$BACKUP_DIR/"
    elif [ -L "$target" ]; then
        # Remove existing symlink
        rm "$target"
    fi
    
    # Create symlink
    ln -sf "$source" "$target"
    echo "  ✓ Linked: $(basename $target)"
}

# Symlink dotfiles
safe_symlink "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
safe_symlink "$DOTFILES_DIR/.bash_aliases" "$HOME/.bash_aliases"
safe_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
safe_symlink "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"

# Symlink vim directory if it exists
if [ -d "$DOTFILES_DIR/.vim" ]; then
    if [ -d "$HOME/.vim" ] && [ ! -L "$HOME/.vim" ]; then
        echo "  Backing up: .vim directory"
        mv "$HOME/.vim" "$BACKUP_DIR/"
    fi
    ln -sfn "$DOTFILES_DIR/.vim" "$HOME/.vim"
    echo "  ✓ Linked: .vim directory"
fi

# -----------------------------
# GNOME Terminal configuration
# -----------------------------
echo ""
echo "Configuring GNOME Terminal..."
if [ -f "$DOTFILES_DIR/.gnome-terminal-settings" ]; then
    # Load the dconf settings
    dconf load /org/gnome/terminal/ < "$DOTFILES_DIR/.gnome-terminal-settings"
    echo "  ✓ GNOME Terminal settings applied"
else
    echo "  ⚠ GNOME Terminal settings file not found"
fi

# -----------------------------
# Cleanup
# -----------------------------
if [ -d "$BACKUP_DIR" ] && [ -z "$(ls -A $BACKUP_DIR)" ]; then
    rmdir "$BACKUP_DIR"
    echo "No backups needed"
else
    echo "Backups saved to: $BACKUP_DIR"
fi

# -----------------------------
# Summary
# -----------------------------
echo ""
echo "========================================="
echo "   Setup Complete!"
echo "========================================="
echo ""
echo "✓ System packages installed"
echo "✓ Rust toolchain configured"
echo "✓ CLI tools installed (eza, bat, zoxide, starship)"
echo "✓ Dotfiles symlinked"
echo "✓ GNOME Terminal configured"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.bashrc"
echo "  2. Verify git config: git config --list"
echo "  3. Optional: Install Nerd Fonts for starship icons"
echo "     → https://www.nerdfonts.com/font-downloads"
echo ""
echo "Installed tools:"
echo "  • starship  - $(command -v starship &>/dev/null && starship --version || echo 'not found')"
echo "  • eza       - $(command -v eza &>/dev/null && eza --version | head -1 || echo 'not found')"
echo "  • bat       - $(command -v bat &>/dev/null && bat --version || echo 'not found')"
echo "  • zoxide    - $(command -v zoxide &>/dev/null && zoxide --version || echo 'not found')"
echo ""
