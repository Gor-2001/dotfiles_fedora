# Directory navigation
alias cwd='cd ~/Documents/Repos'
alias in='code .'

alias scr='sudo ddcutil setvcp 10 '
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Process search and kill aliases
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias psf='pgrep -a'
alias kp='killall -i'
alias kpf='killall -9'
alias k9='kill -9'

# Network
alias ts='tailscale status'

# CMake shortcuts
alias cmb='cmake --build build'
alias cmc='rm -rf build && cmake -S . -B build'
alias cmd='rm -rf build && cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug'
alias cmr='rm -rf build && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release'
alias cmrn='rm -rf build && cmake -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo'

# System operations
alias pow='sudo poweroff'
alias slp='sudo systemctl suspend'
alias res='sudo reboot'
alias cls='clear'
alias cl='clear'
alias c='clear'

# Rust
alias cnew='cargo new'
alias cc='cargo check'
alias crun='cargo run'
alias cdb='cargo build'
alias crl='cargo build --release'
alias cdoc='cargo doc --open'
alias ct='cargo test'
alias cw='cargo watch -x check -x test -x run'

# Python
alias av='source venv/bin/activate'
alias dv='deactivate'
alias jup='~/.venvs/jupyter_env/bin/jupyter lab'

# Gaming mode (NVIDIA optimus)
alias agm='
mode=$(prime-select query 2>/dev/null);
if [ $? -ne 0 ]; then
  echo "Error: prime-select not available";
elif [ "$mode" = "nvidia" ]; then
  echo "Gaming mode already ON (NVIDIA GPU)";
else
  sudo prime-select nvidia && echo "Gaming mode ON (NVIDIA GPU)" && echo "Reboot required";
fi
'

alias dgm='
mode=$(prime-select query 2>/dev/null);
if [ $? -ne 0 ]; then
  echo "Error: prime-select not available";
elif [ "$mode" = "on-demand" ] || [ "$mode" = "intel" ]; then
  echo "Gaming mode already OFF (power-saving)";
else
  sudo prime-select on-demand && echo "Gaming mode OFF (on-demand)" && echo "Reboot required";
fi
'

# Quick edit configs
alias vimrc='vim ~/.vimrc'
alias bashrc='vim ~/.bashrc'
alias aliases='vim ~/.bash_aliases'
