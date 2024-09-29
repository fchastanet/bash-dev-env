#!/usr/bin/env bash

helpDescription() {
  echo "$(scriptName) - Installs useful dependencies using sdkman."
}

helpLongDescription() {
  helpDescription
  echo "The Software Development Kit Manager (sdkman)."
  echo "- gradle"
}

dependencies() {
  echo "installScripts/JavaSdkManager"
}

# jscpd:ignore-start
fortunes() { :; }
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
configure() { :; }
testConfigure() { :; }
isInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
isTestInstallImplemented() { :; }
# jscpd:ignore-end

install() {
  # shellcheck source=/dev/null
  source "${HOME}/.sdkman/bin/sdkman-init.sh"
  sdk install gradle </dev/null # </dev/null simulates non interactive mode => answers yes
}

testInstall() {
  (
    local -i failures=0
    # shellcheck source=/dev/null
    source "${HOME}/.sdkman/bin/sdkman-init.sh"
    Version::checkMinimal "gradle" --version "8.7" || ((++failures))
    return "${failures}"
  ) || return "$?"
}
