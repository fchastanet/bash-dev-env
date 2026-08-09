#!/usr/bin/env bash

helpDescription() {
  echo "Static checker for GitHub Actions workflow files"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- the following linter is available: ${__HELP_EXAMPLE}actionlint${__RESET_COLOR}"
  echo "%"
}

actionlintInstallCallback() {
  sudo tar xzvf "$1" -C /usr/local/bin actionlint
  sudo chmod +x /usr/local/bin/actionlint
  hash -r
  sudo rm -f "$1"
}

install() {
  SUDO=sudo INSTALL_CALLBACK=actionlintInstallCallback Github::upgradeRelease \
    /usr/local/bin/actionlint \
    "https://github.com/rhysd/actionlint/releases/download/v@latestVersion@/actionlint_@latestVersion@_linux_amd64.tar.gz"
}

testInstall() {
  Version::checkMinimal "actionlint" --version "1.7.12" || return 1
}
