#!/usr/bin/env zsh

if typeset -f zinit >/dev/null; then
  # Scripts built at install (there's single default make target, "install",
  # and it constructs scripts by `cat'ing a few files). The make'' ice could also be:
  # `make"install PREFIX=$ZPFX"`, if "install" wouldn't be the only default target.
  zi ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
  zi light tj/git-extras
fi

eval "$(gh copilot alias -- zsh)"
