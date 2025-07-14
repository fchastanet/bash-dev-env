#!/usr/bin/env zsh

if typeset -f zinit >/dev/null; then
  # Scripts built at install (there's single default make target, "install",
  # and it constructs scripts by `cat'ing a few files). The make'' ice could also be:
  # `make"install PREFIX=$ZPFX"`, if "install" wouldn't be the only default target.
  zinit lucid wait'0a' for \
    as"program" \
    pick"$ZPFX/bin/git-*" \
    src"etc/git-extras-completion.zsh" \
    make"PREFIX=$ZPFX" \
    tj/git-extras
fi

eval "$(gh copilot alias -- zsh)"
