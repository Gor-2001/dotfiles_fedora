# Fedora 43 Dotfiles

Personal development environment configuration for Fedora 43.

## Features

- **Shell**: Bash with a single-line starship prompt, zoxide for smart directory jumping
- **Modern CLI tools**: eza (ls replacement), bat (cat replacement), ripgrep, fd
- **Development**: Full C/C++ toolchain (clang, gcc, cmake, meson), Rust toolchain
- **Git**: Configured with useful aliases and settings
- **GNOME Terminal**: 120x30, GitHub Dark-inspired palette, transparency, thin i-beam cursor
- **Vim**: Basic configuration with sensible defaults
- **Debloat**: Removes default GNOME/Fedora apps you likely won't use (LibreOffice, Contacts, Maps, Weather, Tour, Simple Scan, Malcontent Control, Characters, Fedora Media Writer, Video Player, Camera, Help, Clocks, System Monitor, Boxes, Calendar, Software, Connections)
- **Apps**: Telegram Desktop via Flatpak

## Quick Start

On a fresh Fedora 43 installation:

```bash
git clone https://github.com/Gor-2001/dotfiles_fedora.git ~/dotfiles_fedora
cd ~/dotfiles_fedora
./setup.sh
```

The script will:
1. Fix the Armenian keyboard layout (if present)
2. Configure passwordless poweroff/reboot/suspend
3. Update system packages
4. Install development tools and dependencies
5. Remove default app bloat (LibreOffice, Contacts, Maps, Weather, Tour, Simple Scan, Malcontent, Characters, Fedora Media Writer)
6. Set up Rust toolchain
7. Install modern CLI tools (starship, eza, bat, zoxide)
8. Install extra GUI apps (Telegram Desktop via Flatpak)
9. Symlink all dotfiles to your home directory, backing up any existing configuration files, and create `~/Documents/Repos`
10. Configure GNOME Terminal

## What's Included

### System Packages
- Core development tools (git, vim, neovim)
- Build essentials (cmake, meson, ninja, clang, gcc)
- CLI utilities (fzf, ripgrep, fd-find, tree, htop, btop)
- Version control tools (gh)
- Debugging tools (gdb, lldb, valgrind)

### Rust-based CLI Tools
- **starship**: Fast, customizable shell prompt
- **eza**: Modern replacement for ls with icons
- **bat**: Cat clone with syntax highlighting
- **zoxide**: Smarter cd that learns your habits

### Dotfiles
- `.bashrc`: Bash configuration with custom functions and aliases
- `.bash_aliases`: Additional shell aliases
- `.gitconfig`: Git configuration with useful aliases
- `.vimrc`: Vim configuration
- `.gnome-terminal-settings`: Terminal appearance and behavior
- `.config/starship.toml`: Single-line prompt (directory, git branch/status, character — no line break)

### Removed by default
`setup.sh` uninstalls these Fedora Workstation defaults since they're unlikely to be used on a dev machine: the full LibreOffice suite, GNOME Contacts, Maps, Weather, Tour, Simple Scan, the Parental Controls app (`malcontent-control` — the underlying `malcontent` library stays, since `gnome-control-center` depends on it), GNOME Characters, Fedora Media Writer, Video Player (`showtime`), Camera (`snapshot`), Help (`yelp`), Clocks, System Monitor (redundant with htop/btop), Boxes, Calendar, Software (the GUI app store — dnf/flatpak still work from the CLI), and Connections (RDP/VNC client). Disks, Fonts, Logs, and Decibels (audio player) are kept. Edit the `BLOAT_PACKAGES` array in `setup.sh` if you want a different set.

## Bash Features

### Custom Functions
- `t [depth]`: Tree view with depth limit (default: 2)
- `b [level]`: SSH to OverTheWire Bandit challenges
- `gc [user/repo|repo]`: Quick git clone from GitHub

### Modern Aliases
- `ls`, `ll`, `la`: Enhanced with eza and icons
- `lt`: Tree view using eza
- `cat`: Syntax-highlighted with bat
- `nf`: Run fastfetch

### Git Aliases
- `git adog`: Pretty log graph (last 5 commits)
- `git st`: Short status
- `git cm`: Quick commit with message
- `git co/cob`: Checkout/create branch
- See `.gitconfig` for full list

## Manual Steps After Setup

1. **Restart your terminal** or run:
   ```bash
   source ~/.bashrc
   ```

2. **Install Nerd Font** (optional, for starship icons):
   - Download from https://www.nerdfonts.com/
   - Recommended: JetBrains Mono Nerd Font
   - Set in GNOME Terminal preferences

3. **Verify installations**:
   ```bash
   starship --version
   eza --version
   bat --version
   zoxide --version
   ```

## Customization

### Git Configuration
The `.gitconfig` includes your email and name. Update if needed:
```bash
git config --global user.email "your.email@example.com"
git config --global user.name "Your Name"
```

### GNOME Terminal
Current settings use:
- Size: 120x30
- Font: JetBrains Mono 13
- Theme: Dark, 20% transparent, thin i-beam cursor
- Color scheme: GitHub Dark-inspired, high-contrast bright variants

To export your current settings:
```bash
dconf dump /org/gnome/terminal/ > .gnome-terminal-settings
```

### Starship Prompt
`.config/starship.toml` overrides the default format to stay on one line (no `$line_break` before the prompt character). Edit it directly to add more modules or change colors — see https://starship.rs/config/.

## Structure

```
dotfiles_fedora/
├── .bashrc              # Main bash configuration
├── .bash_aliases        # Shell aliases
├── .gitconfig          # Git settings and aliases
├── .vimrc              # Vim configuration
├── .vim/               # Vim runtime files
├── .config/
│   └── starship.toml   # Single-line prompt config
├── .gnome-terminal-settings  # Terminal theme
├── setup.sh            # Automated setup script
└── README.md           # This file
```

## Troubleshooting

### Starship not showing icons
Install a Nerd Font and set it in your terminal preferences.

### Cargo tools not found after installation
Add to your current session:
```bash
source ~/.cargo/env
```

### GNOME Terminal settings not applied
Manually load:
```bash
dconf load /org/gnome/terminal/ < .gnome-terminal-settings
```

### Permission denied on setup.sh
Make executable:
```bash
chmod +x setup.sh
```

## Backup

The setup script automatically backs up existing configuration files to:
```
~/.dotfiles_backup_YYYYMMDD_HHMMSS/
```

## License

MIT License - Feel free to use and modify for your own setup.
