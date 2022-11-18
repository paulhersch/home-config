export PATH=$PATH:$HOME/.cargo/bin/:$HOME/.local/bin

autoload -Uz vcs_info

autoload -U compinit colors zcalc
compinit -d
colors
#
# 	ZSH-SETTINGS
#
HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000

setopt correct                                                  # autocorrect
setopt extendedglob                                             # Extended globbing
setopt nocaseglob                                               # Case insensitive globbing
setopt nobeep
setopt appendhistory
setopt histignorealldups
setopt prompt_subst 											# To use local Vars in prompt
setopt autocd

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
zstyle ':completion:*' cache-path ~/.cache/zsh
zstyle ':completion:*' accept-exact '*(N)'

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' actionformats "|%a"
zstyle ':vcs_info:git:*' stagedstr "+"
zstyle ':vcs_info:git:*' unstagedstr "?"
zstyle ':vcs_info:git:*' formats '%F{5} %b%a %F{1}%u%c%f'
WORDCHARS=${WORDCHARS//\/[&.;,|]}                              # Don't consider certain characters part of the word

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-R

#
#	PLUGINS
#

source ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#
# 	BINDS
#

bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

bindkey '^H' backward-kill-word # CTRL + BSPC
bindkey '5~' kill-word # CTRL + DEL
bindkey '5D' backward-word #st compat
bindkey '5C' forward-word #st compat
bindkey ';5D' backward-word
bindkey ';5C' forward-word

#
#	ALIASES & CUSTOM FUNCTIONS
#

alias ls="exa"
alias tree="exa --tree"
alias cl="clear"
alias git-update="git fetch --recurse-submodules=no --progress --prune ${1}"
alias docker-nix="docker -H unix:///run/user/1001/docker.sock"

texwithbiber () {
    lualatex "$1" && biber "$1" && lualatex "$1"
}

findnixpackage () {
	echo "/"$(ls -la $(which "$1") | cut -d ">" -f 2 | cut -d "/" -f 2,3,4)
}

fortune -s | cowsay -f eyes

local printBranchDiff() {
	local git_out=$(git rev-list --left-right --count origin/${1}..${1})
	local behind=$(echo $git_out | cut -f 1)
	local ahead=$(echo $git_out | cut -f 2)
	[ $behind -gt 0 ] && behind="$behind" || behind=""
	[ $ahead -gt 0 ] && ahead="$ahead" || ahead=""
	print "${behind}${ahead}"
}

precmd() {
	local _LAST_CMD=$(print -P "%(0?.%F{2}▪.%F{1}▪)%f")
	vcs_info
	local _GIT=""
	if [ ! -z $vcs_info_msg_0_ ]; then
		local _GIT=$(print "on %B${vcs_info_msg_0_} %F{1}$(printBranchDiff $(git symbolic-ref --short HEAD))%f%b")
	fi
	local _STS="%F{4}%B%1~%f%b ${_GIT}"
#	local _SPACING
#	(( _SPACING = ${COLUMNS} + 7 - ${#${_STS}} )) #the length counting seems to be off by 7 each time
#	local _FILL="\${(l.${_SPACING}..-.)}"
	print -P "\n${_LAST_CMD} ${_STS}"
}
PROMPT="%F{5}❯%f "
