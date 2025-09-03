#!/usr/bin/env zsh

if typeset -f zinit >/dev/null; then
  export ZSH_GH_COPILOT_NO_CHECK=1
  zinit light loiccoyle/zsh-github-copilot
  # bind Alt+shift+: to explain
  bindkey '^[/' zsh_gh_copilot_explain
  # bind Alt+: to suggest
  bindkey '^[:' zsh_gh_copilot_suggest
fi
