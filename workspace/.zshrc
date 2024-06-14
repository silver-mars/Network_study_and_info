# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=5000
setopt extendedglob nomatch
unsetopt autocd beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/rokujo_ichi/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

autoload -U colors && colors
PS1="%{$fg[green]%}%m@%n%{$fg[red]%}$ %{$fg[blue]%}%d %{$fg[yellow]%}>%{$reset_color%}"

# Aliases block
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -a'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
