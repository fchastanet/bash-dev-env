#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Go
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Go"
}

helpDescription() {
  echo "Go"
}

dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  # shellcheck disable=SC2317
  updateGo() {
    (
      cd /opt/update-golang || exit 1
      Retry::default sudo curl \
        -o hash.txt https://raw.githubusercontent.com/udhos/update-golang/master/update-golang.sh.sha256
      sha256sum -c hash.txt || {
        Log::displayError "update-golang sha checksum doesn't match"
      }
      sudo rm -f hash.txt
      Log::displayInfo "Install/update go ..."
      sudo ./update-golang.sh
      sudo ln -sf /usr/local/go/bin/go /usr/local/bin/go
      sudo ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt
    )
  }
  SUDO=sudo Git::cloneOrPullIfNoChanges \
    "/opt/update-golang" \
    "https://github.com/udhos/update-golang" \
    updateGo \
    updateGo
}

testInstall() {
  Version::checkMinimal "go" "version" "1.22.1" || return 1
}

configure() { :; }
testConfigure() { :; }
