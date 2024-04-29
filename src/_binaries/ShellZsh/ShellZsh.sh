#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/ShellZsh
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/ShellZsh/conf" as conf_dir
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/bin/loadConfigFiles" as loadConfigFiles
# EMBED "${FRAMEWORK_ROOT_DIR}/src/UI/talk.ps1" as talkScript

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "ShellZsh"
}

helpDescription() {
  echo "Default Zsh configuration"
}

dependencies() {
  echo "installScripts/ShellBash"
}

listVariables() {
  echo "HOME"
  echo "USERNAME"
  echo "USERGROUP"
}

fortunes() {
  if [[ "${USER_SHELL}" = "/usr/bin/zsh" ]]; then
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- Zsh ref card manual ${__HELP_EXAMPLE}<http://www.bash2zsh.com/zsh_refcard/refcard.pdf>${__RESET_COLOR}."
    echo "%"
    if [[ "${ZSH_PREFERRED_THEME:-${ZSH_DEFAULT_THEME}}" != "powerlevel10k/powerlevel10k" ]]; then
      echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}Powerlevel10k${__RESET_COLOR} - use the command ${__HELP_EXAMPLE}p10k configure${__RESET_COLOR} to customize shell prompt."
      echo "%"
    fi
  else
    if command -v zsh &>/dev/null; then
      echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}${USER_SHELL}${__RESET_COLOR} is set as default shell, you can switch to zsh using ${__HELP_EXAMPLE}chsh -s /usr/bin/zsh${__RESET_COLOR}."
      echo "%"
    else
      echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}Zsh${__RESET_COLOR} is not set as your default shell, you can give it a try using ${__HELP_EXAMPLE}installAndConfigure ZshProfile${__RESET_COLOR}."
      echo "%"
    fi
  fi
}

# jscpd:ignore-start
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  local -a packages=(
    zsh
    # needed by some zinit packages
    subversion
  )
  Linux::Apt::installIfNecessary --no-install-recommends "${packages[@]}"

  Log::displayInfo "install plugin manager"
  if command -v zinit &>/dev/null; then
    zinit self-update
    zinit update --all --parallel
  else
    bash -c "$(
      NO_EDIT=1 NO_INPUT=1 curl \
        --fail --show-error --silent \
        --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh
    )"
  fi
}

assertZshFunctionExists() {
  local functionName="$1"
  zsh -i -c "typeset -f '${functionName}' &>/dev/null" || {
    Log::displayError "Zsh function ${functionName} does not exist"
    return 1
  }
}

testInstall() {
  local -i failures=0
  Assert::commandExists zsh || ((++failures))
  Assert::commandExists "svn" || ((++failures))
  assertZshFunctionExists zinit || ((++failures))
  return "${failures}"
}

configure() {
  if [[ "${PREFERRED_SHELL}" = "ShellZsh" ]]; then
    if [[ "${USER_SHELL}" != "/usr/bin/zsh" ]]; then
      sudo usermod --shell /usr/bin/zsh "${USERNAME}"
      USER_SHELL="/usr/bin/zsh"
      Log::displayHelp "You have to log in/log out to make zsh by default"
    fi
    Log::displayHelp "Zsh is set as default shell, you can switch back to bash using 'chsh -s /usr/bin/bash'"
  fi
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"

  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    "home" \
    "${HOME}"

  # shellcheck disable=SC2154
  OVERWRITE_CONFIG_FILES=1 Install::file \
    "${embed_file_loadConfigFiles}" \
    "${HOME}/.bash-dev-env/loadConfigFiles"
}

declare -a confFiles=(
  "${HOME}/.bash-dev-env/interactive.d/zsh-syntax-complete-suggest.zsh"
  "${HOME}/.bash-dev-env/interactive.d/zsh-beep.zsh"
  "${HOME}/.bash-dev-env/interactive.d/zsh-history.zsh"
  "${HOME}/.bash-dev-env/interactive.d/zsh-ls-colors.zsh"
  "${HOME}/.bash-dev-env/interactive.d/zsh-ssh.zsh"
  "${HOME}/.bash-dev-env/interactive.d/zsh-z.zsh"
  "${HOME}/.bash-dev-env/themes.d/powerlevel10k.zsh"
  "${HOME}/.bash-dev-env/themes.d/pure.zsh"
  "${HOME}/.bash-dev-env/themes.d/starship.zsh"
  "${HOME}/.bash-dev-env/loadConfigFiles"
  "${HOME}/.zshrc"
  "${HOME}/.zprofile"
  "${HOME}/.p10k.zsh"
)
testConfigure() {
  local -i failures=0
  local file
  for file in "${confFiles[@]}"; do
    Assert::fileExists "${file}" || ((++failures))
  done
  Log::displayInfo "Try to load .zshrc"
  (zsh -i -c 'echo "Hello Zsh"' || exit 1) || {
    Log::displayError "something goes bad while loading ~/.zshrc"
    ((++failures))
  }

  return "${failures}"
}
