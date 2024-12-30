#!/usr/bin/env zsh
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################
if ! typeset -f zinit >/dev/null; then
  return 0
fi

if [[ "${ZSH_PREFERRED_THEME:-${ZSH_DEFAULT_THEME}}" != "sindresorhus/pure" ]]; then
  return 0
fi

# Load pure theme
# A glance at the new for-syntax – load all of the above
# plugins with a single command. For more information see:
# https://zdharma-continuum.github.io/zinit/wiki/For-Syntax/
zinit wait'!' lucid depth=1 load nocd for \
  light-mode zsh-users/zsh-autosuggestions \
  light-mode zdharma-continuum/history-search-multi-word \
  light-mode pick"async.zsh" src"pure.zsh" sindresorhus/pure
