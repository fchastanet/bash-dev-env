#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Fzf
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Fzf"
}

helpDescription() {
  echo "Fzf"
}

dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

fortunes() {
  if command -v bat &>/dev/null; then
    fortunes+=("Fzf -- bat - Use bat command to pre-visualize one or multiple files")
  fi

  if command -v fzf &>/dev/null; then
    fortunes+=("Fzf -- fzf - Use CTRL-T - Paste the selected file path(s) into the command line")
    fortunes+=("Fzf -- fzf - Use CTRL-R - search command line from zsh/bash history")
    fortunes+=("Fzf -- fzf - Use ALT-C - easily select sub directory of current directory")
  fi

  if command -v fd &>/dev/null; then
    fortunes+=("Fzf -- fd -- fd is a program to find entries in your filesystem. It is a simple, fast and user-friendly alternative to find. While it does not aim to support all of find's powerful functionality, it provides sensible (opinionated) defaults for a majority of use cases. - https://github.com/sharkdp/fd")
  fi

}

install() {
  Linux::Apt::update
  Linux::Apt::install \
    tree # tree command is used by some fzf key binding

  Log::displayInfo "install fzf"
  SUDO=sudo Git::cloneOrPullIfNoChanges \
    "/opt/fzf" \
    "https://github.com/junegunn/fzf.git"

  sudo /opt/fzf/install --bin
  sudo ln -sf /opt/fzf/bin/fzf /usr/local/bin/fzf

  # shellcheck disable=SC2317
  function installDeb() {
    sudo dpkg -i "$1"
  }
  export -f installDeb

  # shellcheck disable=SC2154
  SUDO=sudo Github::upgradeRelease \
    "/usr/bin/fd" \
    "https://github.com/sharkdp/fd/releases/download/v@latestVersion@/fd_@latestVersion@_amd64.deb" \
    --version \
    Version::getCommandVersionFromPlainText \
    installDeb \
    Version::parse

  SUDO=sudo Github::upgradeRelease \
    "/usr/bin/bat" \
    "https://github.com/sharkdp/bat/releases/download/v@latestVersion@/bat_@latestVersion@_amd64.deb" \
    --version \
    Version::getCommandVersionFromPlainText \
    installDeb \
    Version::parse
}

testInstall() {
  local -i failures=0
  Version::checkMinimal "fd" --version "8.4.0" || ((++failures))
  Version::checkMinimal "fzf" --version "0.44.1" || ((++failures))
  Version::checkMinimal "bat" --version "0.22.1" || ((++failures))

  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
