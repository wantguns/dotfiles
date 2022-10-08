# ABOUT: ZSHRC
# AUTHOR: WantGuns <mail@wantguns.dev>

# p10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Sane Defaults

# Completions
autoload -U compinit
compinit -C

# Arrow key menu for completions
zstyle ':completion:*' menu select

# Case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Include hidden files
setopt globdots

# Autocomplete command line switches for aliases
setopt completealiases

# History
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.local/zsh/zsh_history
setopt inc_append_history
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# Automatically use cd when paths are entered without cd
setopt autocd

# Understand comments
setopt interactivecomments

# Source Keybindings
source $ZDOTDIR/keybindings.zsh

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Plugins
source $ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZDOTDIR/plugins/zsh-sudo/sudo.plugin.zsh

# FZF
export FZF_DEFAULT_OPTS='
    --layout=reverse --height 50%
'

# exports
export EDITOR=nvim
export PATH="$PATH:$HOME/.local/scripts"
export PATH="$PATH:$HOME/.local/bin"

# use dialog boxes with cron and at 
# xhost local:wantguns > /dev/null

# helper functions
mcd() { mkdir -p "$1"; cd "$1" }

paste_beta() {
    curl \
        -Ls -o /dev/null \
        -w %{url_effective} \
        --data-binary @${1:-/dev/stdin} \
        https://betabin.wantguns.dev | tee >(xclip -selection clipboard)
}

paste() {
    curl --request POST \
              -Ls -o /dev/null \
              -w %{url_effective} \
              --data-binary @${1:-/dev/stdin} \
              --url https://betabin.wantguns.dev 

    # echo "$redir_link" | tee >(xclip -selection clipboard)
}

paste_old() {
    # edit some stuff
    local file=${1:-/dev/stdin}
    curl --data-binary @${file} https://bin.wantguns.dev | tee >(xclip -selection clipboard)
}

sharkbait() { ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l root -i ~/.ssh/sb/id_ed25519 lavender $@ }

f() {
    # fzf into .config
    find ~/.local/scripts ~/.config | fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' | xargs -r "$EDITOR"
}

d() {
    # fzf into ~/dev
    cd $(find -L ~/dev -type d 2>/dev/null | fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}')
}

# aliases
# alias grep='rg'
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
# alias ssh='SSH_AUTH_SOCK= ssh -i ~/.ssh/gallifrey'

# Less Colors
export LESS_TERMCAP_mb=$'\e[6m'             # begin blinking
export LESS_TERMCAP_md=$'\e[34m'            # begin bold
export LESS_TERMCAP_us=$'\e[4;32m'          # begin underline
export LESS_TERMCAP_so=$'\e[01;33;03;40m'   # begin standout-mode - info box
export LESS_TERMCAP_me=$'\e[m'              # end mode
export LESS_TERMCAP_ue=$'\e[m'              # end underline
export LESS_TERMCAP_se=$'\e[m'              # end standout-mode

# Set man-page width
export MANWIDTH=80
export MANOPT='--nh --nj'

# Use bat for coloured man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p --theme gruvbox-dark'"

# GPG: switch to basics for Ad-Hoc purposes
export GPG_TTY=$(tty)

# Android Dev
CCACHE_EXEC=/usr/bin/ccache
USE_CCACHE=1
CCACHE_COMPRESS=1

# Prompt
source ~/.config/p10k/powerlevel10k.zsh-theme
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
