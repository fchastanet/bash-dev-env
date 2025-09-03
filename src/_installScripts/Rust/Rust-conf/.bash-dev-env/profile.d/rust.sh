#!/usr/bin/env bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

[[ :${PATH}: =~ (^|:)${HOME}/.cargo/bin(:|$) ]] || PATH=${HOME}/.cargo/bin:${PATH}
