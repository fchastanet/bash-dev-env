#!/usr/bin/env bash

helpDescription() {
  echo "Composer dependencies mainly code checkers"
}

helpLongDescription() {
  helpDescription
  echo "$(scriptName) -- the following php linters are available: "
  echo -e "  - ${__HELP_EXAMPLE}phpmd${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}phpcs${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}php-cs-fixer${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}phpstan${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}psalm${__RESET_COLOR}"
}

dependencies() {
  echo "installScripts/Composer"
}

fortunes() {
  helpLongDescription
  echo "%"
}

# jscpd:ignore-start
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
  Log::displayInfo "Installing composer dependencies"
  composer global require --dev --no-interaction \
    'squizlabs/php_codesniffer=*' \
    'phpmd/phpmd=*' \
    'friendsofphp/php-cs-fixer=*' \
    'phpstan/phpstan=*' \
    'vimeo/psalm=*'
  composer global update
}

testInstall() {
  # composer dependencies
  # shellcheck source=src/_installScripts/Php/Composer-conf/.bash-dev-env/profile.d/composer_path.sh
  source "${HOME}/.bash-dev-env/profile.d/composer_path.sh" || {
    Log::displayError "Composer script failed to install '${HOME}/.bash-dev-env/profile.d/composer_path.sh'"
    ((++failures))
  }
  Version::checkMinimal "phpcs" --version "3.10.3" || ((++failures))
  Version::checkMinimal "phpmd" --version "2.15.0" || ((++failures))
  Version::checkMinimal "php-cs-fixer" --version "3.64.0" || ((++failures))
  Version::checkMinimal "phpstan" --version "1.12.4" || ((++failures))
  Version::checkMinimal "psalm" --version "5.26.1" || ((++failures))

  return "${failures}"
}
