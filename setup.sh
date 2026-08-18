#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "========================================="
echo "   Fedora 44 Development Environment"
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
if [ "$fedora_version" != "44" ]; then
    echo "Warning: This script is tested on Fedora 44, you're running $fedora_version"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# -----------------------------
# Armenian keyboard fix
# -----------------------------
echo "[1/12] Applying Armenian keyboard layout fix..."
if [ -f /usr/share/X11/xkb/symbols/am ]; then
    sudo sed -i '80s/Armenian_ra,\s*Armenian_RA/Armenian_re, Armenian_RE/' /usr/share/X11/xkb/symbols/am
    sudo sed -i '89s/Armenian_re,\s*Armenian_RE/Armenian_ra, Armenian_RA/' /usr/share/X11/xkb/symbols/am
    echo "  ✓ Armenian keyboard layout fixed"
else
    echo "  ⚠ Armenian keyboard file not found, skipping"
fi

# Add Armenian phonetic as an input source alongside US (switch with Super+Space)
if command -v gsettings &>/dev/null; then
    current_sources=$(gsettings get org.gnome.desktop.input-sources sources)
    if [[ "$current_sources" != *"'am+phonetic'"* ]]; then
        gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'am+phonetic')]"
        echo "  ✓ Armenian (phonetic) input source added"
    else
        echo "  ✓ Armenian (phonetic) input source already configured"
    fi

    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:none']"
    echo "  ✓ Caps Lock disabled"
fi

# -----------------------------
# Sudoers configuration
# -----------------------------
echo "[2/12] Configuring passwordless power commands..."
echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/poweroff, /usr/bin/reboot, /usr/bin/systemctl suspend, /usr/bin/ddcutil" | sudo tee /etc/sudoers.d/nopasswd-power > /dev/null
sudo chmod 440 /etc/sudoers.d/nopasswd-power
echo "  ✓ Passwordless poweroff/reboot/suspend/ddcutil (scr) enabled"

# -----------------------------
# System update
# -----------------------------
echo "[3/12] Updating system..."
sudo dnf update -y

# -----------------------------
# Core packages
# -----------------------------
echo "[4/12] Installing core packages..."
sudo dnf install -y \
    git \
    vim \
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
    fastfetch \
    flatpak \
    ddcutil \
    openssl-devel \
    doxygen

# -----------------------------
# Remove default app bloat
# -----------------------------
echo "[5/12] Removing unwanted default applications..."
BLOAT_PACKAGES=(
    'libreoffice*'
    gnome-contacts
    gnome-maps
    gnome-weather
    gnome-tour
    simple-scan
    malcontent-control
    gnome-characters
    mediawriter
    showtime
    snapshot
    yelp
    gnome-clocks
    gnome-system-monitor
    gnome-boxes
    gnome-calendar
    gnome-software
    gnome-connections
)
sudo dnf remove -y "${BLOAT_PACKAGES[@]}" || echo "  ⚠ Some packages were already absent, continuing"

# -----------------------------
# Rust toolchain
# -----------------------------
echo "[6/12] Setting up Rust..."
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
echo "[7/12] Installing Rust-based CLI tools..."

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
# Extra GUI apps (Flatpak)
# -----------------------------
echo "[8/12] Installing extra GUI apps..."
if command -v flatpak &>/dev/null; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub org.telegram.desktop
    echo "  ✓ Telegram Desktop installed"
else
    echo "  ⚠ flatpak not found, skipping Telegram Desktop"
fi

# -----------------------------
# Text-to-speech (edge-tts)
# -----------------------------
echo "[9/12] Installing text-to-speech (edge-tts)..."
if ! command -v pipx &>/dev/null; then
    sudo dnf install -y pipx
fi
if command -v pipx &>/dev/null; then
    if ! command -v edge-tts &>/dev/null; then
        pipx install edge-tts
        pipx ensurepath
        echo "  ✓ edge-tts installed (use 'say' / 'sayclip' after restarting your shell)"
    else
        echo "  ✓ edge-tts already installed"
    fi
else
    echo "  ⚠ pipx not available, skipping edge-tts"
fi

# -----------------------------
# JetBrainsMono Nerd Font
# -----------------------------
# Fedora only packages the plain (non-patched) JetBrains Mono, which has no
# icon glyphs. starship/fastfetch icons need the patched Nerd Font variant,
# which isn't in the Fedora repos, so grab it from the upstream release.
echo "[10/12] Installing JetBrainsMono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
if fc-list | grep -q "JetBrainsMono Nerd Font Mono"; then
    echo "  ✓ JetBrainsMono Nerd Font already installed"
else
    TMP_FONT_ZIP=$(mktemp --suffix=.zip)
    if curl -sL -f -o "$TMP_FONT_ZIP" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"; then
        mkdir -p "$FONT_DIR"
        unzip -o -q "$TMP_FONT_ZIP" "JetBrainsMonoNerdFontMono-*.ttf" -d "$FONT_DIR"
        fc-cache -f "$FONT_DIR" >/dev/null
        echo "  ✓ JetBrainsMono Nerd Font installed"
    else
        echo "  ⚠ Failed to download JetBrainsMono Nerd Font, skipping"
    fi
    rm -f "$TMP_FONT_ZIP"
fi

# -----------------------------
# Symlink dotfiles
# -----------------------------
echo "[11/12] Symlinking dotfiles..."

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
safe_symlink "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
safe_symlink "$DOTFILES_DIR/.config/Code/User/settings.json" "$HOME/.config/Code/User/settings.json"

# Common directories
mkdir -p "$HOME/Documents/Repos"
echo "  ✓ Created ~/Documents/Repos"

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
# Ptyxis terminal configuration
# -----------------------------
# Fedora Workstation ships Ptyxis (not classic GNOME Terminal) by default.
# Its dconf schema keys live under a per-install random profile UUID, so we
# configure it via gsettings against the current default profile rather than
# dumping/loading a fixed dconf blob.
echo ""
echo "[12/12] Configuring Ptyxis terminal..."
if command -v gsettings &>/dev/null && gsettings list-schemas | grep -q '^org.gnome.Ptyxis$'; then
    gsettings set org.gnome.Ptyxis default-columns 150
    gsettings set org.gnome.Ptyxis default-rows 40
    echo "  ✓ Ptyxis configured: 150x40 default size"
else
    echo "  ⚠ Ptyxis not found, skipping terminal configuration"
fi

# -----------------------------
# Wallpaper
# -----------------------------
if [ -f "$DOTFILES_DIR/Fedora_43_default_wallpaper.png" ]; then
    gsettings set org.gnome.desktop.background picture-uri "file://$DOTFILES_DIR/Fedora_43_default_wallpaper.png"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$DOTFILES_DIR/Fedora_43_default_wallpaper.png"
    gsettings set org.gnome.desktop.background picture-options 'zoom'
    gsettings set org.gnome.desktop.screensaver picture-uri "file://$DOTFILES_DIR/Fedora_43_default_wallpaper.png"
    gsettings set org.gnome.desktop.screensaver picture-options 'zoom'
    echo "  ✓ Wallpaper and lock screen set"
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
echo "✓ Default app bloat removed"
echo "✓ Rust toolchain configured"
echo "✓ CLI tools installed (eza, bat, zoxide, starship)"
echo "✓ Telegram Desktop installed"
echo "✓ Text-to-speech installed (edge-tts — use 'say'/'sayclip')"
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
