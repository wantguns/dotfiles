# ABOUT: ZSHRC
# AUTHOR: WantGuns <mail@wantguns.dev>

# Prompt
autoload -Uz promptinit
promptinit
PROMPT='%B%n%b%(?.. %F{red}%?): ' # boldface username
RPROMPT='%F{white}%~' # current directory

# Plugins
source $ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZDOTDIR/plugins/zsh-sudo/sudo.plugin.zsh

# exports
export EDITOR=nvim

# helper functions
mcd() {
    mkdir -p "$1"
    cd "$1"
}

# aliases
alias grep='rg'
alias vim='nvim'
alias cfgz='nvim ~/.config/zsh/.zshrc'
alias cfgt='nvim ~/.config/tmux/tmux.conf'
alias cfgn='nvim ~/.config/nvim/init.vim'
alias srcz='source ~/.config/zsh/.zshrc'
alias ixio="curl -F 'f:1=<-' ix.io"
alias ls='ls --color=auto'
alias gsudo='sudo git -c "include.path='"${XDG_CONFIG_DIR:-$HOME/.config}/git/config\""
alias tmux='tmux -f "$XDG_CONFIG_HOME"/tmux/tmux.conf' # y u do dis tmux
alias config='/usr/bin/git --git-dir=$HOME/.dots/ --work-tree=$HOME/.config'
