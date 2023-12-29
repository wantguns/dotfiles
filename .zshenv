export ZDOTDIR="/Users/wantguns/.config/zsh"

# XDG Base Dirs
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share

SHELL_SESSIONS_DISABLE=1
eval "$(/opt/homebrew/bin/brew shellenv)"
. "$HOME/.cargo/env"

