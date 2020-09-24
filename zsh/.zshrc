export ZSH="$HOME/.config/oh-my-zsh"

ZSH_THEME="typewritten"

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
## typewritten
export TYPEWRITTEN_PROMPT_LAYOUT="pure"
export TYPEWRITTEN_SYMBOL="->"
export TYPEWITTEN_CURSOR="underscore"

# tmux at startups
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux new-session -A -s primary
fi

# helper functions
mcd() {
    mkdir -p "$1"
    cd "$1"
}

sena() {
    sudo systemctl enable "$1"
}

sdis() {
    sudo systemctl disable "$1"
}

sres() {
    sudo systemctl restart "$1"
}

srel() {
    sudo systemctl reload "$1"
}

sstp() {
    sudo systemctl stop "$1"
}

ssta() {
    sudo systemctl start "$1"
}

sstt() {
    sudo systemctl status "$1"
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
alias gsudo='sudo git -c "include.path='"${XDG_CONFIG_DIR:-$HOME/.config}/git/config\""
