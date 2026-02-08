# Fedora Dotfiles

Personal dotfiles for Fedora development environment, managed with GNU Stow.

## Features

- **Bash**: Custom prompt with git branch, fzf integration, starship support
- **Vim**: Sensible defaults, whitespace visualization
- **Git**: Useful aliases and improved log formatting
- **Tools**: Configurations for modern CLI tools (fzf, bat, fd, ripgrep)

## Prerequisites

Fedora Linux with `sudo` access.

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

The script will:
1. Update system packages
2. Install development tools (gcc, clang, cmake, rust toolchain)
3. Install CLI utilities (fzf, ripgrep, bat, etc.)
4. Symlink dotfiles using GNU Stow
5. Set up shell integrations (starship, zoxide)

## Manual Installation

If you prefer to install components separately:

```bash
# Install GNU Stow
sudo dnf install stow

# Stow individual packages
cd ~/dotfiles
stow bash
stow vim
stow git
stow gnome-terminal
```

## Structure

```
dotfiles/
├── bash/
│   ├── .bashrc
│   └── .bash_aliases
├── vim/
│   ├── .vimrc
│   └── .vim/
├── git/
│   └── .gitconfig
├── gnome-terminal/
│   └── .gnome-terminal-settings
└── setup.sh
```

Each directory is a "Stow package" that mirrors your home directory structure.

## Configuration

After installation:

1. Edit `~/.gitconfig` to set your email and name:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

2. Restart your shell or source the config:
   ```bash
   source ~/.bashrc
   ```

3. Optional: Install a Nerd Font for starship prompt icons

## Key Aliases

### System
- `pow` - Poweroff
- `slp` - Suspend
- `res` - Reboot
- `c`/`cl`/`cls` - Clear screen

### Navigation
- `cwd` - Jump to ~/Documents/Repos
- `llp` - List current and parent directory

### CMake
- `cmc` - Clean configure
- `cmd` - Configure debug build
- `cmr` - Configure release build
- `cmb` - Build

### Rust
- `cc` - cargo check
- `crun` - cargo run
- `cdb` - cargo build
- `crl` - cargo build --release
- `ct` - cargo test
- `cw` - cargo watch

### Git
- `lgit` - Launch lazygit
- `git adog` - Pretty log with graph
- `git st` - Short status
- `gc <repo>` - Quick clone from your account
- `gra` - List all repos (orgs + personal)
- `grp` - List personal repos
- `gro` - List org repos

### Python
- `av` - Activate venv
- `dv` - Deactivate venv
- `jup` - Launch Jupyter lab

### Gaming (NVIDIA Optimus)
- `agm` - Activate gaming mode (switch to NVIDIA)
- `dgm` - Deactivate gaming mode (switch to on-demand)

## Functions

- `t [depth]` - Tree with depth limit (default: 2)
- `b [level]` - SSH to OverTheWire Bandit level
- `gc [user/]repo` - Clone repo (uses your username if not specified)

## Tools Installed

### Development
- gcc, g++, clang, lldb
- cmake, meson, ninja
- rust (via rustup)
- git, gh (GitHub CLI)
- lazygit

### CLI Utilities
- fzf (fuzzy finder)
- ripgrep (fast grep)
- fd (fast find)
- bat (cat with syntax highlighting)
- zoxide (smarter cd)
- starship (cross-shell prompt)
- tree, htop

## Uninstalling

To remove symlinks:

```bash
cd ~/dotfiles
stow -D bash vim git gnome-terminal
```

To remove packages:

```bash
sudo dnf remove <package-names>
```

## Updating

```bash
cd ~/dotfiles
git pull
stow --restow bash vim git gnome-terminal
```

## Customization

- Edit `bash/.bashrc` for shell behavior
- Edit `bash/.bash_aliases` for custom aliases
- Edit `vim/.vimrc` for vim settings
- Edit `git/.gitconfig` for git configuration

Changes take effect immediately for new shells, or run `source ~/.bashrc`.

## Troubleshooting

### Stow conflicts
If Stow reports conflicts with existing files:

```bash
# Backup existing files
mv ~/.bashrc ~/.bashrc.backup
mv ~/.vimrc ~/.vimrc.backup

# Then restow
stow bash vim
```

### fzf not working
Ensure fzf shell integration is sourced. The paths are set for Fedora:
- `/usr/share/fzf/shell/key-bindings.bash`
- `/usr/share/bash-completion/completions/fzf`

### Command not found after install
Make sure `~/.local/bin` and `~/.cargo/bin` are in your PATH:

```bash
echo $PATH | grep -E '\.local/bin|\.cargo/bin'
```

If missing, restart your shell or source `~/.bashrc`.
