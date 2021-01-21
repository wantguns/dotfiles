# ABOUT: ZSHRC
# AUTHOR: WantGuns <mail@wantguns.dev>

# Persist History
HISTFILE=~/.local/zsh/zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Plugins
source $ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZDOTDIR/plugins/zsh-sudo/sudo.plugin.zsh

# exports
export EDITOR=nvim
export PATH="$PATH:$HOME/.local/scripts"

# helper functions
mcd() {
    mkdir -p "$1"
    cd "$1"
}

paste() {
    local file=${1:-/dev/stdin}
    curl --data-binary @${file} https://bin.wantguns.dev | tee >(xclip -selection clipboard)
}

# aliases
alias grep='rg'
alias vim='nvim'
alias cfgz='nvim ~/.config/zsh/.zshrc'
alias cfgt='nvim ~/.config/tmux/tmux.conf'
alias cfgn='nvim ~/.config/nvim/init.vim'
alias srcz='source ~/.config/zsh/.zshrc'
alias ls='ls --color=auto'
alias gsudo='sudo git -c "include.path='"${XDG_CONFIG_DIR:-$HOME/.config}/git/config\""
alias tmux='tmux -f "$XDG_CONFIG_HOME"/tmux/tmux.conf' # y u do dis tmux
alias config='/usr/bin/git --git-dir=$HOME/.dots/ --work-tree=$HOME'
alias vm='sudo virsh'
alias gallifrey='ssh root@g.wantguns.dev -p 4081'

# Command completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select

# Source Keybindings
source $ZDOTDIR/keybindings.zsh

# Prompt
autoload -Uz promptinit
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
setopt inc_append_history
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
promptinit
PROMPT='%F{yellow}[%m] %B%F{cyan}%n%b% %F{magenta}${vcs_info_msg_0_}%(?.. %F{red}%?):%E ' # boldface username
RPROMPT='%F{white}%~' # current directory

# git prompt 
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '!'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' formats ' %b%u%c'
