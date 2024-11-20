#!/usr/bin/env bash

helpDescription() {
  echo "$(scriptName) - CLI tool which enables you to login to AWS."
}

helpLongDescription() {
  helpDescription
  echo "It retrieves AWS temporary credentials using a SAML IDP"
}

dependencies() {
  echo "installScripts/AwsCli"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- use ${__HELP_EXAMPLE}aws-login${__RESET_COLOR} alias "
  echo -e "to log to aws using saml2aws (see ${__HELP_EXAMPLE}<https://github.com/Versent/saml2aws>${__RESET_COLOR})."
  if ! command -v saml2aws &>/dev/null; then
    echo
    echo -e "install it using ${__HELP_EXAMPLE}installAndConfigure Saml2Aws${__RESET_COLOR}."
  fi
  echo "%"
}

# @see https://github.com/fchastanet/my-documents/blob/master/HowTo/Saml2Aws.md
saml2awsInstallCallback() {
  sudo tar xzvf "$1" -C /usr/local/bin saml2aws
  sudo chmod +x /usr/local/bin/saml2aws
  hash -r
  sudo rm -f "$1"
}

cleanBeforeExport() {
  rm -f "${HOME}/.saml2aws" || true
}

testCleanBeforeExport() {
  ((failures = 0)) || true
  Assert::fileNotExists "${HOME}/.saml2aws" || ((++failures))
  return "${failures}"
}

install() {
  SUDO=sudo INSTALL_CALLBACK=saml2awsInstallCallback Github::upgradeRelease \
    /usr/local/bin/saml2aws \
    "https://github.com/Versent/saml2aws/releases/download/v@latestVersion@/saml2aws_@latestVersion@_linux_amd64.tar.gz"
}

testInstall() {
  Version::checkMinimal "saml2aws" --version "2.36.10" || return 1
}
