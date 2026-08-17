# Fedora 44 Dotfiles

Personal development environment configuration for Fedora 44.

## Features

- **Shell**: Bash with a single-line starship prompt, zoxide for smart directory jumping
- **Modern CLI tools**: eza (ls replacement), bat (cat replacement), ripgrep, fd
- **Development**: Full C/C++ toolchain (clang, gcc, cmake, meson), Rust toolchain
- **Git**: Configured with useful aliases and settings
- **Ptyxis terminal**: 150x40 default window size (theme/font/palette configured manually via Ptyxis Preferences)
- **Vim**: Basic configuration with sensible defaults
- **Debloat**: Removes default GNOME/Fedora apps you likely won't use (LibreOffice, Contacts, Maps, Weather, Tour, Simple Scan, Malcontent Control, Characters, Fedora Media Writer, Video Player, Camera, Help, Clocks, System Monitor, Boxes, Calendar, Software, Connections)
- **Apps**: Telegram Desktop via Flatpak

## Quick Start

On a fresh Fedora 44 installation:

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
5. Remove default app bloat (see "Removed by default" below)
6. Set up Rust toolchain
7. Install modern CLI tools (starship, eza, bat, zoxide)
8. Install extra GUI apps (Telegram Desktop via Flatpak)
9. Install text-to-speech (edge-tts, via pipx)
10. Symlink all dotfiles to your home directory, backing up any existing configuration files, and create `~/Documents/Repos`
11. Configure Ptyxis terminaldsdsd 

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
- `.config/starship.toml`: Single-line prompt (directory, git branch/status, character — no line break)
- `.config/Code/User/settings.json`: VS Code integrated terminal colors, matching the Nord palette

Ptyxis (the default Fedora terminal app) isn't configured via a dotfile — `setup.sh` sets its default window size directly with `gsettings` since its dconf keys are keyed by a per-install random profile UUID. Theme/font/palette are left to Ptyxis' own Preferences UI.

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

   `setup.sh` already downloads the patched JetBrainsMono Nerd Font from [ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts) and sets it as the Ptyxis font, so starship's icons work out of the box — no manual font step needed.

2. **Verify installations**:
   ```bash
   starship --version
   eza --version
   bat --version
   zoxide --version
   edge-tts --version
   ```

## Customization

### Git Configuration
The `.gitconfig` includes your email and name. Update if needed:
```bash
git config --global user.email "your.email@example.com"
git config --global user.name "Your Name"
```

### Ptyxis Terminal
`setup.sh` only sets the default window size (150x40). Everything else — palette, opacity, font, cursor shape — is configured by hand in Ptyxis → Preferences, since Ptyxis ships dozens of built-in named palettes (Nord, Dracula, Gruvbox, Catppuccin Mocha, Tokyo Night, Solarized, and many more from [Gogh](https://github.com/Gogh-Co/Gogh)) that are easiest to browse and pick from the Appearance tab directly.

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
│   ├── starship.toml   # Single-line prompt config
│   └── Code/User/settings.json  # VS Code integrated terminal colors (Nord)
├── setup.sh            # Automated setup script (also sets Ptyxis default window size)
└── README.md           # This file
```

## Troubleshooting

### Starship not showing icons
`setup.sh` installs the JetBrainsMono Nerd Font and sets it automatically. If icons are still missing, confirm it's actually selected in Ptyxis → Preferences → Profile → Font, and that `fc-list | grep "JetBrainsMono Nerd Font"` shows it installed.

### Cargo tools not found after installation
Add to your current session:
```bash
source ~/.cargo/env
```

### Ptyxis settings not applied
Re-run just that part of `setup.sh`, or apply manually:
```bash
gsettings set org.gnome.Ptyxis default-columns 150
gsettings set org.gnome.Ptyxis default-rows 40
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
