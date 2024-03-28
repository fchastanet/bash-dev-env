#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Saml2Aws
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Saml2Aws"
}

helpDescription() {
  echo "Saml2Aws"
}

dependencies() {
  echo "AwsCli"
}

listVariables() {
  echo "AWS_AUTHENTICATOR"
  echo "CAN_TALK_DURING_INSTALLATION"
  echo "AWS_APP_ID"
  echo "AWS_PROFILE"
  echo "AWS_USER_MAIL"
  echo "AWS_DEFAULT_REGION"
  echo "AWS_TEST_SECRET_ID"
  echo "AWS_DEFAULT_DOCKER_REGISTRY_ID"
}

fortunes() {
  if [[ "${AWS_AUTHENTICATOR:-Saml2Aws}" = "Saml2Aws" ]]; then
    fortunes+=("use aws-login alias to log to aws using saml2aws (see https://github.com/Versent/saml2aws)")
    if ! command -v saml2aws &>/dev/null; then
      fortunes+=("\ninstall it using 'installAndConfigure Saml2Aws")
    fi
  fi
}

helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  # @see https://github.com/fchastanet/my-documents/blob/master/HowTo/Saml2Aws.md
  # shellcheck disable=SC2317
  saml2awsInstallCallback() {
    sudo tar xzvf "$1" -C /usr/local/bin saml2aws
    sudo chmod +x /usr/local/bin/saml2aws
    hash -r
  }
  export -f saml2awsInstallCallback
  # shellcheck disable=SC2154
  SUDO=sudo Github::upgradeRelease \
    /usr/local/bin/saml2aws \
    "https://github.com/Versent/saml2aws/releases/download/v@latestVersion@/saml2aws_@latestVersion@_linux_amd64.tar.gz" \
    "--version" \
    "Version::getCommandVersionFromPlainText" \
    saml2awsInstallCallback \
    "Version::parse"
}

testInstall() {
  Version::checkMinimal "saml2aws" --version "2.36.10" || return 1
}

configure() { :; }
testConfigure() { :; }
