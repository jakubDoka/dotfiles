# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt beep extendedglob nomatch notify
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/mlokis/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# My config lines
alias v='nvim'
alias xcpy='xclip -selection c -i'
alias xpst='xclip -selection c -o'

## config preservation
alias gfg='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
gfgup() {
	gfg add $1
	gfg commit -m "${@:2}"
	gfg push > /dev/null
}

## path
padd() {
	path+=($1)
}

padd ~/.cargo/bin/

# End of my config
