#!/usr/bin/zsh
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

# Set up fzf key bindings and fuzzy completion
if [[ ! "$PATH" == *${HOME}/.fzf/bin* ]]; then
  PATH="${PATH}:${HOME}/.fzf/bin"
fi

if typeset -f zinit >/dev/null; then
  zinit wait"1" lucid depth=1 load light-mode for \
    wookayin/fzf-fasd

  # Binary release in archive, from GitHub-releases page.
  # After automatic unpacking it provides program "fzf".
  zinit ice from"gh-r" as"program"
  zinit light junegunn/fzf
  zinit pack"default+keys" for fzf
fi

if [[ -f "${HOME}/.fzf.zsh" ]]; then
  # shellcheck source=/dev/null
  source "${HOME}/.fzf.zsh"
fi
