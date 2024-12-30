#!/usr/bin/env bash

helpDescription() {
  echo "AwsCli"
}

dependencies() {
  echo "installScripts/Saml2Aws"
  echo "installScripts/Xvfb"
}

fortunes() {
  if ! command -v aws &>/dev/null; then
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- command ${__HELP_EXAMPLE}aws${__RESET_COLOR} not installed - install it using ${__HELP_EXAMPLE}installAndConfigure AwsCli${__RESET_COLOR}."
    echo "%"
  fi
}

# jscpd:ignore-start
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
configure() { :; }
testConfigure() { :; }
# jscpd:ignore-end

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
  Version::checkMinimal "aws" --version "2.22.22" || return 1
}
