#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/Java/JavaSdkManager-conf" as conf_dir

helpDescription() {
  echo "$(scriptName) - tool managing parallel versions of multiple Software Development Kits"
}

dependencies() {
  echo "installScripts/ShellBashDefaultConfig"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- you can use the command ${__HELP_EXAMPLE}sdk install java${__RESET_COLOR} to install latest jdk version."
  echo "%"
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- check ${__HELP_EXAMPLE}<https://sdkman.io/sdks>${__RESET_COLOR} to see the list of sdks like ${__HELP_EXAMPLE}scala${__RESET_COLOR}, ${__HELP_EXAMPLE}gradle${__RESET_COLOR}, ... that can be easily installed."
  echo '%'
}

# jscpd:ignore-start
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  Linux::Apt::installIfNecessary --no-install-recommends zip
  curl -s "https://get.sdkman.io?rcupdate=false" | bash
  (
    # shellcheck source=/dev/null
    source "${HOME}/.sdkman/bin/sdkman-init.sh"
    sdk selfupdate force
    yes | sdk install java || true # exit code of sdk is not reliable
    # exit code can be different than 0 when java already installed
    if ! command -v java &>/dev/null; then
      Log::displayError "java not installed, check above logs"
      return 1
    fi
  ) || {
    Log::displayError "Error while installing java"
    return 1
  }
}

testInstall() {
  (
    local -i failures=0
    # shellcheck source=/dev/null
    source "${HOME}/.sdkman/bin/sdkman-init.sh"

    Assert::commandExists "zip" || ((++failures))
    Version::checkMinimal "sdk" version "5.18.2" || ((++failures))
    Version::checkMinimal "java" --version "21.0.5" || ((++failures))
    return "${failures}"
  ) || return "$?"
}

configure() {
  ln -sf "${HOME}/.sdkman/bin/sdkman-init.sh" "${HOME}/.bash-dev-env/profile.d/sdkman-init.sh"
  chmod +x "${HOME}/.sdkman/bin/sdkman-init.sh"

  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "$(fullScriptOverrideDir)" \
    ".sdkman"
}

testConfigure() {
  Assert::fileExists "${HOME}/.bash-dev-env/profile.d/sdkman-init.sh"
  Assert::fileExists "${HOME}/.sdkman/etc/config"
}

cleanBeforeExport() {
  # shellcheck source=/dev/null
  source "${HOME}/.sdkman/bin/sdkman-init.sh"

  sdk flush
}

testCleanBeforeExport() {
  (
    local -i failures=0

    Assert::dirNotExists "${HOME}/.sdkman/var/tmp" || ((++failures))
    Assert::dirEmpty "${HOME}/.sdkman/var/metadata" || ((++failures))

    return "${failures}"
  ) || return "$?"
}
