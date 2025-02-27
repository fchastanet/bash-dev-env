#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/BashUtils/Tig-conf" as conf_dir

helpDescription() {
  echo "$(scriptName) - text-mode interface for Git"
}

helpLongDescription() {
  helpDescription
  echo "Tig is an ncurses-based text-mode interface for git."
  echo "It functions mainly as a Git repository browser, but"
  echo "can also assist in staging changes for commit at chunk"
  echo "level and act as a pager for output from various Git commands."
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- use ${__HELP_EXAMPLE}tig${__RESET_COLOR} command to browse git repository's logs."
  echo "%"
}

# jscpd:ignore-start
dependencies() { :; }
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  Linux::Apt::installIfNecessary --no-install-recommends \
    tig
}

testInstall() {
  Assert::commandExists tig
}

configure() {
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "$(fullScriptOverrideDir)" \
    "home" \
    "${HOME}"
}

testConfigure() {
  local -i failures=0
  Assert::fileExists "${HOME}/.config/tig/config" || ((++failures))
  Assert::fileExists "${HOME}/.tigrc" || ((++failures))
  return "${failures}"
}
