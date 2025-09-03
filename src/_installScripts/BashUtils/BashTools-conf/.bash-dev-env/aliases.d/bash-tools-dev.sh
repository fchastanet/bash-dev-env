#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

alias bats='vendor/bats/bin/bats'
alias batsP='vendor/bats/bin/bats -j 30'
alias batsX='bats -x --print-output-on-failure'
alias batsXX='bats -x --print-output-on-failure --no-tempdir-cleanup'

function updateBashToolsTag() {
  local tag="$1"
  git tag "${tag}" --delete
  git push origin --delete "${tag}"
  git tag "${tag}" --force
  git push --force-with-lease --no-verify --tags
}
alias updateBashToolsTag='updateBashToolsTag'

function _bashCode() {
  code "${HOME}/fchastanet/bash-tools" &
  code "${HOME}/fchastanet/bash-dev-env/vendor/bash-tools-framework" &
  code "${HOME}/fchastanet/bash-compiler" &
  code "${HOME}/fchastanet/bash-dev-env" &
  cd "${HOME}/fchastanet/bash-dev-env" || return 1
}
alias bash-code='_bashCode'

function _compileBashTools() {
  (
    cd "${HOME}/fchastanet/bash-compiler" || exit 1
    go run ./cmd/bash-compiler -r "${HOME}/fchastanet/bash-tools" "$@"
  )
}
alias compile-bash-tools='_compileBashTools'

function _compileBashToolsFramework() {
  (
    cd "${HOME}/fchastanet/bash-compiler" || exit 1
    go run ./cmd/bash-compiler -r "${HOME}/fchastanet/bash-tools/vendor/bash-tools-framework" "$@"
  )
}
alias compile-bash-tools-framework='_compileBashToolsFramework'

function _compileBashDevEnv() {
  (
    cd "${HOME}/fchastanet/bash-compiler" || exit 1
    go run ./cmd/bash-compiler -r "${HOME}/fchastanet/bash-dev-env" "$@"
  )
}
alias compile-bash-dev-env='_compileBashDevEnv'
