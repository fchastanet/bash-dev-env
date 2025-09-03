#!/usr/bin/env bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

export GVM_ROOT="${HOME}/.gvm"
export GOBIN="${GVM_ROOT}/go/bin"
[[ :${PATH}: =~ (^|:)${HOME}/.local/bin(:|$) ]] || PATH=${HOME}/.local/bin:${PATH}
[[ :${PATH}: =~ (^|:)${GOBIN}(:|$) ]] || PATH=${GOBIN}:${PATH}

export GOPROXY=https://proxy.golang.org
export GOSUMDB=sum.golang.org
export PATH=${PATH}:/usr/local/go/bin
