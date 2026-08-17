# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# -----------------------------
# History configuration
# -----------------------------
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

# -----------------------------
# Color support
# -----------------------------
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Custom functions
# -----------------------------
# Tree with depth limit
t() {
    tree . -L "${1:-2}"
}

# OverTheWire Bandit SSH
b() {
    ssh -p 2220 "bandit$1@bandit.labs.overthewire.org"
}

# Git clone shorthand
gc() {
    if [[ $1 == *"/"* ]]; then
        # Full username/repo format
        git clone "git@github.com:$1.git"
    else
        # Just repo name, use configured username from git
        local username=$(git config --get user.name)
        if [ -z "$username" ]; then
            echo "Error: No git username configured"
            return 1
        fi
        git clone "git@github.com:$username/$1.git"
    fi
}

# List all repos (orgs first, then personal)
gra() {
    gh org list | while read org; do
        echo ""
        gh repo list "$org" --limit 1000
    done
    echo ""
    echo "=== Personal Repos ==="
    gh repo list --limit 1000
}

# List only personal repos
grp() {
    gh repo list --limit 1000
}

# List only org repos
gro() {
    gh org list | while read org; do
        echo ""
        gh repo list "$org" --limit 1000
    done
}

# -----------------------------
# Load aliases
# -----------------------------
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.config/shell/aliases.sh ]; then
    . ~/.config/shell/aliases.sh
fi

# -----------------------------
# Bash completion
# -----------------------------
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# -----------------------------
# PATH configuration
# -----------------------------
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin"

# -----------------------------
# Editor
# -----------------------------
export EDITOR=vim
export VISUAL=vim

# -----------------------------
# fzf configuration (Fedora paths)
# -----------------------------
if command -v fzf &>/dev/null; then
    # Fedora fzf paths
    [ -f /usr/share/fzf/shell/key-bindings.bash ] && source /usr/share/fzf/shell/key-bindings.bash
    [ -f /usr/share/bash-completion/completions/fzf ] && source /usr/share/bash-completion/completions/fzf

    # Use fd if available, otherwise fall back to find
    if command -v fdfind &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
    elif command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi

    export FZF_DEFAULT_OPTS='
      --height 40%
      --layout=default
      --border
      --preview-window=right:50%
    '

    # Use bat for preview if available
    if command -v bat &>/dev/null; then
        export FZF_CTRL_T_OPTS='--preview "bat --style=numbers --color=always {} 2> /dev/null | head -200"'
    fi
    
    export FZF_CTRL_R_OPTS="--no-sort --exact"

    # Custom history search (removes duplicates)
    __fzf_history__() {
      local output
      output=$(
        history | tac | sed 's/ *[0-9]* *//' | 
        awk '!seen[$0]++' |
        fzf $FZF_DEFAULT_OPTS $FZF_CTRL_R_OPTS --query="$READLINE_LINE"
      )
      READLINE_LINE="$output"
      READLINE_POINT=${#READLINE_LINE}
    }

    bind -x '"\e[A": __fzf_history__'
    bind -x '"\C-r": __fzf_history__'
fi


# Cargo environment
# -----------------------------
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Starship prompt
# -----------------------------
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# Zoxide (smarter cd)
# -----------------------------
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi

# Modern CLI tool aliases
# -----------------------------
if command -v eza &>/dev/null; then
    alias ls='eza --icons'
    alias ll='eza -la --icons'
    alias lt='eza --tree --level=2 --icons'
fi

set bell-style none

if command -v bat &>/dev/null; then
    alias cat='bat'
fi

if command -v fastfetch &>/dev/null; then
    alias nf='fastfetch'
    # Show system info automatically when a new terminal opens
    fastfetch
fi

# Text-to-speech (edge-tts natural voice)
# -----------------------------
if command -v edge-tts &>/dev/null && command -v ffplay &>/dev/null; then
    # Read text aloud: `say "hello there"` or `echo hello | say`
    say() {
        local voice="${TTS_VOICE:-en-US-AvaNeural}"
        local text="$*"
        [ -z "$text" ] && text=$(cat)
        local tmpfile
        tmpfile=$(mktemp --suffix=.mp3)
        edge-tts --voice "$voice" --text "$text" --write-media "$tmpfile" >/dev/null 2>&1 \
            && ffplay -nodisp -autoexit -loglevel quiet "$tmpfile"
        rm -f "$tmpfile"
    }

    # Read the clipboard aloud (copy text from a website, then run `sayclip`)
    sayclip() {
        if command -v wl-paste &>/dev/null; then
            wl-paste | say
        elif command -v xclip &>/dev/null; then
            xclip -selection clipboard -o | say
        else
            echo "No clipboard tool found (wl-paste/xclip)"
            return 1
        fi
    }
fi
