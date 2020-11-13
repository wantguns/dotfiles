# WantGuns' Dotfiles for Desktops

These are my curated dots which I picked over in an year or so.
My workflow is heavily based on writing, tmux and nvim usually on random
VPSs.

## Prerequisite Packages

```sh
sudo pacman -S git neovim ripgrep nodejs fzf tmux npm
```

## Install

I am using the infamous hackernews' comment involving a bare git
repository.

```sh
git clone --bare https://github.com/wantguns/dotfiles $HOME/.dots
```

Checkout the repository at $HOME

```sh
# This alias is already declared in the zshrc for future purposes
alias config='/usr/bin/git --git-dir=$HOME/.dots/ --work-tree=$HOME -b pc --recurse-submodules'
config checkout
config submodule update
```

Stop showing untracked files for our repository for saner version
controlling.

```sh
config config --local status.showUntrackedFiles no
```

Finally, change your shell

```sh
chsh -S $(which zsh)
```

Remove the install guide if you want
```sh
rm ~/readme.md
```

# References
[HN comment](https://news.ycombinator.com/item?id=11071754)
[Atlassian Guide](https://www.atlassian.com/git/tutorials/dotfiles)
