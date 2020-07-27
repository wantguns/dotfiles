#!/bin/bash

die () {
    echo "Failed to configure some stuff"
    exit
}

sudo apt update && sudo apt upgrade
sudo add-apt-repository ppa:keithw/mosh-dev -y
sudo apt update

sudo apt install zsh tmux git neovim bat ripgrep mosh -y    || die

# XDG
sudo bash -c 'cat >> /etc/profile << EOF
export XDG_CONFIG_HOME="/home/wantguns/.config"
export XDG_CACHE_HOME="/home/wantguns/.cache"
export XDG_DATA_HOME="/home/wantguns/.local/share"
EOF'

source /etc/profile

# zsh initialization
sudo bash -c 'cat > /etc/zsh/zshenv << EOF
if [[ -z "$XDG_CONFIG_HOME" ]]
then
        export XDG_CONFIG_HOME="/home/wantguns/.config"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]
then
        export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi
EOF'

source /etc/zsh/zshenv

zsh

# oh-my-zsh
export ZSH="/home/wantguns/.config/oh-my-zsh/"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

## autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-autosuggestions

## syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

## powershell10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-/home/wantguns/.config/oh-my-zsh/custom}/themes/powerlevel10k

chsh -s $(which zsh)
