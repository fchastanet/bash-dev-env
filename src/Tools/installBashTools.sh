#!/usr/bin/env bash

# @description install bash-tools
Tools::installBashTools() {
  # shellcheck disable=SC2317
  function installBashTools() {
    (
      cd "${USER_HOME}/fchastanet/bash-tools" || return 1
      ./install.sh
    )
  }

  Git::cloneOrPullIfNoChanges \
    "${USER_HOME}/fchastanet/bash-tools" \
    "https://github.com/fchastanet/bash-tools.git" \
    installBashTools
}
