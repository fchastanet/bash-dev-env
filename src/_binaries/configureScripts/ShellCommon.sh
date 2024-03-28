#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/ShellCommon
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/ShellCommon/.inputrc" as inputrc
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/ShellCommon/.dir_colors" as dir_colors
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/ShellCommon/.vimrc" as vimrc
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/ShellCommon/.Xresources" as xresources

declare -a filesToInstall=(
  inputrc
  dir_colors
  vimrc
  xresources
)

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "ShellCommon"
}

helpDescription() {
  echo "ShellCommon"
}

dependencies() {
  # font needed for displaying bash prompt
  echo Font
}

helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
install() { :; }
testInstall() { :; }

configure() {
  Conf::installFromEmbed "ShellCommon" "${filesToInstall[@]}" || return 1

  local fileToInstall
  # shellcheck disable=SC2154
  fileToInstall="$(Conf::dynamicConfFile "ShellCommon/.vimrc" "embed_file_vimrc")" || return 1
  SUDO=sudo Install::file \
    "${fileToInstall}" "/root/.vimrc" root root || return 1

  # disable bell
  sudo sed -i -e 's/;set bell-style none/set bell-style none/g' /etc/inputrc
}


testConfigure() {
  local -i failures=0
  Conf::installFromEmbedCheck "${filesToInstall[@]}" || ((failures = failures + $?))
  SUDO=sudo Assert::fileExists /root/.vimrc root root || ((++failures))

  # check font in windows terminal configuration
  local terminalConfFile
  # cspell:ignore wekyb, bbwe
  terminalConfFile="${WINDOWS_PROFILE_DIR}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
  if [[ -f "${terminalConfFile}" ]]; then
    if ! grep -q '"face": "MesloLGS NF"' "${terminalConfFile}"; then
      Log::displayHelp "Please change your terminal settings($(Linux::Wsl::cachedWslpath -w "${terminalConfFile}")) to use font 'MesloLGS NF' for wsl profile"
    fi
  else
    Log::displayHelp "please use windows terminal for better shell display results"
  fi

  return "${failures}"
}
