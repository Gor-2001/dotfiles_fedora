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
eval "$(starship init bash)"
eval "$(zoxide init bash)"

eval "$(starship init bash)"
alias ls='eza --icons'
alias ll='eza -l --icons'
alias cat='bat'

# Custom prompt and aliases
eval "$(starship init bash)"
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias cat='bat'
alias nf='fastfetch'
