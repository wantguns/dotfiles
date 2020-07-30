# WantGuns' Dotfiles

These are my curated dots which I picked over in an year or so.
My workflow is heavily based on writing, tmux and nvim usually on random VPSs.


## Install

This is tested only on __Ubuntu 20.04 LTS__. I would not recommend trying this on any other distro.

```bash
sudo apt update && sudo apt install git mosh
git clone https://github.com/WantGuns/dotfiles --recurse-submodules .config
```

Since these dots are based on my usernames and for some reasons config files won't support environment variables, you will have to change the usernames in the configuration files by yourself.

```bash
grep -r "wantguns" .config
```
After changing the username, let the install script run.

```bash
source .config/install.sh
```

Log out and log back in. You will be welcomed by zsh, inside the `primary` tmux session.
Everytime you access the terminal, you will be welcomed by the same tmux session, removing the room of cluttered tmux sessions.

That's about it.
