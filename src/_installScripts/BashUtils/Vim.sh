#!/usr/bin/env bash

helpDescription() {
  echo "$(scriptName) - the ubiquitous text editor"
}

helpLongDescription() {
  helpDescription
  echo "Vim is a highly configurable text editor built to make creating and changing"
  echo "any kind of text very efficient. It is included as 'vi' with most UNIX systems"
  echo "and with Apple OS X."
  echo "Vim is rock stable and is continuously being developed to become even better."
  echo "Among its features are:"
  echo
  echo "  - persistent, multi-level undo tree"
  echo "  - extensive plugin system"
  echo "  - support for hundreds of programming languages and file formats"
  echo "  - powerful search and replace"
  echo "  - integrates with many tools"
}

# jscpd:ignore-start
dependencies() { :; }
fortunes() { :; }
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
isInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
isTestInstallImplemented() { :; }
configure() { :; }
testConfigure() { :; }
# jscpd:ignore-end

install() {
  Linux::Apt::installIfNecessary --no-install-recommends \
    vim \
    vim-gui-common \
    vim-runtime

  curl -fLo "${HOME}/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  sudo mkdir -p /root/.vim/autoload
  sudo cp "${HOME}/.vim/autoload/plug.vim" /root/.vim/autoload/plug.vim
}

testInstall() {
  local failures=0
  Assert::commandExists vi || ((++failures))
  Assert::commandExists vim || ((++failures))
  Assert::fileExists "${HOME}/.vim/autoload/plug.vim" || ((++failures))
  SUDO=sudo Assert::fileExists "/root/.vim/autoload/plug.vim" root root || ((++failures))
  return "${failures}"
}
