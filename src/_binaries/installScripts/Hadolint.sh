#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Hadolint
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Hadolint"
}

helpDescription() {
  echo "Hadolint"
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
  SUDO=sudo Github::upgradeRelease \
    "/usr/local/bin/hadolint" \
    "https://github.com/hadolint/hadolint/releases/download/@latestVersion@/hadolint-Linux-x86_64" \
    --version \
    "Version::getCommandVersionFromPlainText" \
    "" \
    Version::parse
}

testInstall() {
  Version::checkMinimal "hadolint" --version "2.12.0" || return 1
}

configure() { :; }
testConfigure() { :; }
