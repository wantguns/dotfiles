#!/bin/bash

die () {
    echo "Failed to configure some stuff"
    exit
}

sudo apt update && sudo apt upgrade -y

sudo apt install zsh tmux neovim bat make -y    || die

# install ripgrep
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb
sudo dpkg -i ripgrep_11.0.2_amd64.deb
rm -rf ripgrep_11.0.2_amd64.deb

# XDG
sudo bash -c 'cat >> /etc/profile << EOF

export XDG_CONFIG_HOME="/home/wantguns/.config"
export XDG_CACHE_HOME="/home/wantguns/.cache"
export XDG_DATA_HOME="/home/wantguns/.local/share"
EOF'

source /etc/profile || die

# zsh initialization
sudo bash -c 'cat > /etc/zsh/zshenv << EOF
    export ZDOTDIR="/home/wantguns/.config/zsh"
EOF'

source /etc/zsh/zshenv || die

# tmux's team sucks ass for not using XDG base directories
ln -s ~/.config/tmux/tmux.conf ~/.tmux.conf 

# oh-my-zsh
## while installing oh-my-zsh, it will ask whether to make zsh your default shell. for that
echo "\n\033[1;33mCreate superuser's password\n"
sudo passwd
echo "\n\033[1;33mCreate wantguns' password\n"
sudo passwd wantguns

## install oh-my-zsh
export ZSH="/home/wantguns/.config/oh-my-zsh/"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

## autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-autosuggestions

## syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

## Typewritten
git clone https://github.com/reobin/typewritten.git ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/themes/typewritten
ln -s ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/themes/typewritten/typewritten.zsh-theme ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/themes/typewritten.zsh-theme
ln -s ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/themes/typewritten/async.zsh ${ZSH_CUSTOM:-~/.config/oh-my-zsh/custom}/themes/async

## switch to zsh and configure it
chsh -s $(which zsh)
