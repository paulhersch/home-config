export PATH=$PATH:$HOME/.cargo/bin/:$HOME/.local/bin

autoload -Uz vcs_info

autoload -U compinit colors zcalc
compinit -d
colors
#
# 	ZSH-SETTINGS
#
HISTFILE=~/.config/zsh/zhistory
HISTSIZE=10000
SAVEHIST=10000

setopt correct                                                  # autocorrect
setopt extendedglob                                             # Extended globbing
setopt nocaseglob                                               # Case insensitive globbing
setopt nobeep
setopt appendhistory
setopt histignorealldups
setopt prompt_subst 						# To use local Vars in prompt
setopt autocd

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
zstyle ':completion:*' cache-path ~/.cache/zsh
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':vcs_info:git:*' formats '%b'
WORDCHARS=${WORDCHARS//\/[&.;]}                                 # Don't consider certain characters part of the word

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
bindkey '^H' backward-kill-word # CTRL+Backspace bind

#
#	ALIASES
#

alias cl="clear"

#the funny
fortune -s | cowsay -f eyes

#Prompt (fuck p10k)
precmd() {
	LAST_CMD=$(print -P "%(0?.%F{2}%K{8}%f.%F{1}%K{8}%f)") # green = last cmd exit 0
	vcs_info
	GIT_STS=$( [ ! -z $vcs_info_msg_0_ ] && print -P "on  ${vcs_info_msg_0_}")
	print -P "\n${LAST_CMD} %~ %F{4}${GIT_STS}%f%k%F{8}%f "
} #this prints stuff over the prompt
PROMPT=$(print -P " %F{5}%f ")
