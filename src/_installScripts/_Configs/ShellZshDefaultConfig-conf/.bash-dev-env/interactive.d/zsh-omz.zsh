#!/usr/bin/env zsh

if [[
  "${ZSH_PREFERRED_THEME:-${ZSH_DEFAULT_THEME}}" = "powerlevel10k/powerlevel10k"
  || "${ZSH_PREFERRED_THEME:-${ZSH_DEFAULT_THEME}}" = "sindresorhus/pure"
]]; then
  return 0
fi

# Save aliases
backupAliases="$(alias)"

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 14

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	# zsh-syntax-highlighting
	zsh-autosuggestions
  ssh-agent
	git
	docker-compose
	docker
	dirhistory
	kubectl
	kube-ps1
)

RPROMPT='$(kube_ps1)'

if [[ -f $ZSH/oh-my-zsh.sh ]]; then
  source $ZSH/oh-my-zsh.sh
fi

# remove all aliases added by oh-my-zsh plugins
unalias -a

# restore saved aliases
source <(echo "${backupAliases}")
