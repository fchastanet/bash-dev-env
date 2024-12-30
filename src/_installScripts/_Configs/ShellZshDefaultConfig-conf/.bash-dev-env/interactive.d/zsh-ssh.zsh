#!/usr/bin/zsh
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

zstyle :omz:plugins:ssh-agent agent-forwarding on
zstyle :omz:plugins:ssh-agent identities ~/.config/ssh/{id_rsa,id_rsa2,id_github}
zstyle :omz:plugins:ssh-agent lazy yes
zstyle :omz:plugins:ssh-agent agent-forwarding yes

if [[ "${ZSH_PREFERRED_THEME:-${ZSH_DEFAULT_THEME}}" = "powerlevel10k/powerlevel10k" ]]; then
  # Powerline10k has an instant prompt setting that doesn't like
  # when this plugin writes to the console.
  zstyle :omz:plugins:ssh-agent quiet yes
  zstyle :omz:plugins:ssh-agent lazy yes
fi

if typeset -f zinit >/dev/null; then
  zinit wait lucid depth=1 load light-mode for \
    OMZP::ssh
fi
