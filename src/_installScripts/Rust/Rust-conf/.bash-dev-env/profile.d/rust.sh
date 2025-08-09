#!/usr/bin/env bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

[[ :${PATH}: =~ (^|:)${HOME}/.cargo/bin(:|$) ]] || PATH=${HOME}/.cargo/bin:${PATH}
if [[ -f "${HOME}/.cargo/env" ]]; then
  # shellcheck source=/dev/null
  source "${HOME}/.cargo/env"
fi
