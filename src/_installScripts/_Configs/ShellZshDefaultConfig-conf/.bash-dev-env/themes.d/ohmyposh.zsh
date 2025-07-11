#!/usr/bin/env zsh
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

if [[ "${ZSH_PREFERRED_THEME:-${ZSH_DEFAULT_THEME}}" != "ohmyposh" ]]; then
  return 0
fi

eval "$(oh-my-posh init zsh --config "${POSH_THEME_PATH:-${HOME}/.bash-dev-env/themes.d/ohmyposhThemes/jandedobbeleer.yaml}")"
