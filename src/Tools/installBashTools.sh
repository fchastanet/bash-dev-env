#!/usr/bin/env bash

# @description install bash-tools
Tools::installBashTools() {
  local targetDir="$1"
  # shellcheck disable=SC2317,SC2329
  function installBashTools() {
    (
      cd "${targetDir}" || return 1
      ./install
    )
  }
  Git::cloneOrPullIfNoChanges \
    "${targetDir}" \
    "https://github.com/fchastanet/bash-tools.git" \
    installBashTools
}
