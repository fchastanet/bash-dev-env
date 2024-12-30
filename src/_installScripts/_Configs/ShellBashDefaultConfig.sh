#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/_Configs/ShellBashDefaultConfig-conf" as conf_dir
# @embed "${BASH_DEV_ENV_ROOT_DIR}/bin/findConfigFiles" as findConfigFiles
# @embed "${BASH_DEV_ENV_ROOT_DIR}/bin/fixWslDate" as fixWslDate

helpDescription() {
  echo "Default configuration for bash"
}

dependencies() {
  echo "installScripts/Bat"
  echo "installScripts/Fasd"
  # font needed for displaying bash prompt
  echo "installScripts/Font"
  echo "installScripts/Fzf"
  echo "installScripts/Vim"
}

fortunes() {
  if [[ "${USER_SHELL}" = "/usr/bin/bash" ]]; then
    if command -v zsh &>/dev/null; then
      echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}Bash${__RESET_COLOR} is set as default shell, you can switch to zsh using ${__HELP_EXAMPLE}chsh -s /usr/bin/zsh${__RESET_COLOR}."
      echo "%"
    fi
  fi
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
  Linux::Apt::installIfNecessary --no-install-recommends \
    bash-completion
}

testInstall() {
  Assert::fileExists /etc/profile.d/bash_completion.sh root root || return 1
}

configure() {
  if [[ "${PREFERRED_SHELL}" = "ShellBash" ]]; then
    if [[ "${USER_SHELL}" != "/usr/bin/bash" ]]; then
      usermod --shell /usr/bin/bash "${USERNAME}"
      USER_SHELL="/usr/bin/bash"
      Log::displayHelp "You have to log in/log out to make bash by default"
    fi
    if command -v zsh &>/dev/null; then
      Log::displayHelp "Bash is set as default shell, you can switch back to zsh using 'chsh -s /usr/bin/zsh'"
    fi
  fi

  mkdir -p "${HOME}/.bash-dev-env/interactive.d" || return 1
  Retry::default curl -o "${HOME}/.bash-dev-env/interactive.d/git-prompt.sh" \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh || return 1
  chmod +x "${HOME}/.bash-dev-env/interactive.d/git-prompt.sh"

  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"

  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".vscode"

  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    "home" \
    "${HOME}"

  local configDir
  # shellcheck disable=SC2154
  configDir="$(Conf::getOverriddenDir "${embed_dir_conf_dir}" "${CONF_OVERRIDE_DIR}/$(scriptName)")"

  SUDO=sudo Install::file \
    "${configDir}/home/.vimrc" "/root/.vimrc" root root
  SUDO=sudo Install::file \
    "${configDir}/home/.inputrc" "/root/.inputrc" root root
  # shellcheck disable=SC2154
  OVERWRITE_CONFIG_FILES=1 Install::file \
    "${embed_file_findConfigFiles}" \
    "${HOME}/.bash-dev-env/findConfigFiles"
  # shellcheck disable=SC2154
  OVERWRITE_CONFIG_FILES=1 Install::file \
    "${embed_file_fixWslDate}" \
    "${HOME}/.bash-dev-env/fixWslDate"
  Log::displayInfo "Creating sudoer file for fixWslDate command ..."
  local sudoerFile="/etc/sudoers.d/bash-dev-env-fixWslDate-no-password"
  echo "${USERNAME} ALL=(ALL) NOPASSWD: ${HOME}/.bash-dev-env/fixWslDate" |
    sudo tee "${sudoerFile}" >/dev/null
  sudo chmod 0440 "${sudoerFile}"

  Log::displayInfo "disable bell"
  sudo sed -i -e 's/;set bell-style none/set bell-style none/g' /etc/inputrc
}

testConfigure() {
  local -i failures=0
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/git-prompt.sh" || ((++failures))

  Assert::fileExists "${HOME}/.bash_logout" || ((++failures))
  Assert::fileExists "${HOME}/.bashrc" || ((++failures))
  Assert::fileExists "${HOME}/.dir_colors" || ((++failures))
  Assert::fileExists "${HOME}/.inputrc" || ((++failures))
  Assert::fileExists "${HOME}/.profile" || ((++failures))
  Assert::fileExists "${HOME}/.vimrc" || ((++failures))

  SUDO=sudo Assert::fileExists /root/.vimrc root root || ((++failures))
  SUDO=sudo Assert::fileExists /root/.inputrc root root || ((++failures))

  Assert::fileExists "${HOME}/.bash-dev-env/findConfigFiles" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/colors.sh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/filesDirectory.sh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/miscellaneous.sh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/ssh.sh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/xserver.sh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/DISCLAIMER.md" || ((++failures))

  Assert::fileExists "${HOME}/.bash-dev-env/completions.d/makeTargets.bash" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/completions.d/DISCLAIMER.md" || ((++failures))

  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/zzz_bash_prompt.bash" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/bash_navigation.bash" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/dir_colors.bash" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/DISCLAIMER.md" || ((++failures))

  Assert::fileExists "${HOME}/.bash-dev-env/profile.d/DISCLAIMER.md" || ((++failures))

  Assert::fileExists "${HOME}/.vscode/argv.json" || ((++failures))
  Assert::fileExists "${HOME}/.vscode/settings.json" || ((++failures))

  # check font in windows terminal configuration
  local terminalConfSettingsPath
  terminalConfSettingsPath="$(Conf::getWindowsTerminalPath)/LocalState/settings.json"
  if [[ -f "${terminalConfSettingsPath}" ]]; then
    if ! grep -q '"face": "MesloLGS NF"' "${terminalConfSettingsPath}"; then
      local terminalConfSettingsWPath
      Linux::Wsl::cachedWslpath2 terminalConfSettingsWPath -w "${terminalConfSettingsPath}"
      Log::displayHelp "Please change your terminal settings(${terminalConfSettingsWPath}) to use font 'MesloLGS NF' for wsl profile"
    fi
  else
    Log::displayHelp "File ${terminalConfSettingsPath} does not exist - please use windows terminal for better shell display results"
  fi

  return "${failures}"
}
