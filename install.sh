#!/bin/bash

die () {
    echo "Failed to configure some stuff"
    exit
}

sudo apt update && sudo apt upgrade -y

sudo apt install zsh tmux neovim fzf make -y    || die

# install ripgrep
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb
sudo dpkg -i ripgrep_11.0.2_amd64.deb
rm -rf ripgrep_11.0.2_amd64.deb

# install docker and friends
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce docker-compose -y

# install croc
curl https://getcroc.schollz.com | bash

# install rclone
curl https://rclone.org/install.sh | sudo bash

## switch to zsh and configure it
chsh -s $(which zsh)
