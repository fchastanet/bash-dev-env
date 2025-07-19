#!/usr/bin/env zsh

###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

if typeset -f zinit >/dev/null; then
  zinit wait"1" lucid depth=1 load light-mode for \
    agkozak/zsh-z
fi
