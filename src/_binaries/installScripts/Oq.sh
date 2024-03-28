#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Oq
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Oq"
}

helpDescription() {
  echo "Oq"
}

dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

oqParseVersion() {
  grep "oq" | Version::parse
}

install() {
  # shellcheck disable=SC2317
  oqVersion() {
    local command="$1"
    local argVersion="${2:---version}"
    "${command}" "${argVersion}" 2>&1 | oqParseVersion
  }

  # shellcheck disable=SC2317
  SUDO=sudo Github::upgradeRelease \
    "/usr/local/bin/oq" \
    "https://github.com/Blacksmoke16/oq/releases/download/@latestVersion@/oq-@latestVersion@-$(uname -s)-$(uname -m)" \
    --version \
    "oqVersion" \
    "" \
    Version::parse
}

testInstall() {
  Version::checkMinimal "oq" --version "1.3.4" oqParseVersion || return 1
}

configure() { :; }
testConfigure() { :; }
