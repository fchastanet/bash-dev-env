#!/usr/bin/env zsh

if typeset -f zinit >/dev/null; then
  mkdir -p "${ZSH_CACHE_DIR}/completions"
  touch "${ZSH_CACHE_DIR}/completions/_docker"
  zinit wait lucid depth=1 load light-mode for \
    make'alias alias=' as"completion" OMZP::docker \
    make'alias alias=' as"completion" OMZP::docker-compose

  # One other binary release, it needs renaming from `docker-compose-Linux-x86_64`.
  # This is done by ice-mod `mv'{from} -> {to}'. There are multiple packages per
  # single version, for OS X, Linux and Windows – so ice-mod `bpick' is used to
  # select Linux package – in this case this is actually not needed, Zinit will
  # grep operating system name and architecture automatically when there's no `bpick'.
  zi ice from"gh-r" as"program" mv"docker* -> docker-compose" bpick"*linux*"
  zi load docker/compose
fi
