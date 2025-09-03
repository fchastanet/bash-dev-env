#!/usr/bin/env zsh

bindkey "^[[1;5D" backward-word                    # Ctrl+Left Arrow
bindkey "^[[1;5C" forward-word                     # Ctrl+Right Arrow
bindkey "^[[1;3D" dirhistory_zle_dirhistory_back   # Alt+Left Arrow
bindkey "^[[1;3C" dirhistory_zle_dirhistory_forward # Alt+Right Arrow
