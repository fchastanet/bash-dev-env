#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/AwsCli
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "AwsCli"
}

helpDescription() {
  echo "AwsCli"
}

dependencies() {
  echo "Xvsb"
}

helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

fortunes() {
  if ! command -v aws &>/dev/null; then
    echo "aws -- AwsCli not installed - install it using '${BASH_DEV_ENV_ROOT_DIR}/installScripts/AwsCli'"
  fi
}

install() {
  # install aws-cli
  if [[ -f "/usr/local/bin/aws" && -z "$(find /usr/local/bin/aws -mtime +6)" ]]; then
    Log::displaySkipped "aws-cli installed as binary not older than 6 days"
    exit 0
  fi

  (
    cd /tmp || exit 1
    rm -Rf ./aws
    Retry::default curl \
      --fail \
      -o "awscli.zip" \
      "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    unzip -o awscli.zip >/dev/null
    if [[ -f /usr/local/bin/aws ]]; then
      sudo ./aws/install --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin --update
    else
      sudo ./aws/install --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin
    fi
    rm -Rf ./aws
    rm -f awscli.zip
  )
}

testInstall() {
  Version::checkMinimal "aws" --version "2.13.32" || return 1
}

configure() { :; }
testConfigure() { :; }
