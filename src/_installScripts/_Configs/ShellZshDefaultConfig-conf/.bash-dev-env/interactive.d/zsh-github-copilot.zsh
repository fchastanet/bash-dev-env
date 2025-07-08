#!/usr/bin/env zsh

if typeset -f zinit >/dev/null; then
  zinit light loiccoyle/zsh-github-copilot
  bindkey '^[|' zsh_gh_copilot_explain  # bind Alt+shift+\ to explain
  bindkey '^[\' zsh_gh_copilot_suggest  # bind Alt+\ to suggest
fi
