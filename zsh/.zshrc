export ZSH="$HOME/.config/oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    extract
    sudo
)

source $ZSH/oh-my-zsh.sh

# exports
export EDITOR=nvim
## rootless docker
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock


# tmux at startups
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux new-session -A -s primary
fi

# helper functions
mcd() {
    mkdir -p "$1"
    cd "$1"
}

# aliases
alias grep='rg'
alias bat='batcat'
alias vim='nvim'
alias n='nvim'
alias cfgz='nvim ~/.config/zsh/.zshrc'
alias cfgt='nvim ~/.config/tmux/tmux.conf'
alias cfgn='nvim ~/.config/nvim/init.vim'
alias srcz='source ~/.config/zsh/.zshrc'
alias ixio="curl -F 'f:1=<-' ix.io"
