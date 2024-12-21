#!/usr/bin/env bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

[[ :${PATH}: =~ (^|:)${HOME}/.local/bin(:|$) ]] || PATH=${HOME}/.local/bin:${PATH}
[[ :${PATH}: =~ (^|:)${HOME}/.gvm/go/bin(:|$) ]] || PATH=${HOME}/.gvm/go/bin:${PATH}

export GOBIN="${HOME}/.gvm/go/bin"
export GOPROXY=https://proxy.golang.org
export GOSUMDB=sum.golang.org
