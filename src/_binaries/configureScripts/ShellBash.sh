#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/ShellBash
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/ShellBash/.bash_completion" as bash_completion
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/ShellBash/.bash_navigation" as bash_navigation
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/ShellBash/.bash_profile" as bash_profile
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/ShellBash/.bash_prompt" as bash_prompt
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/ShellBash/.bash_logout" as bash_logout
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/ShellBash/.bashrc" as bashrc
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/ShellBash/.profile" as profile

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

declare -a filesToInstall=(
  bash_completion
  bash_navigation
  bash_profile
  bash_prompt
  bash_logout
  bashrc
  profile
)

scriptName() {
  echo "ShellBash"
}

helpDescription() {
  echo "ShellBash"
}

dependencies() {
  echo ShellCommon
  echo Fasd
  echo Fzf
  echo Kubectx
  echo Kubeps1
}

helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

fortunes() {
  local currentUserShell
  currentUserShell="$(grep "^${USERNAME}:" /etc/passwd | awk -F ":" '{print $7}')"
  if [[ "${currentUserShell}" = "/usr/bin/bash" ]]; then
    if command -v zsh &>/dev/null; then
      fortunes+=("Bash is set as default shell, you can switch to zsh using 'chsh -s /usr/bin/zsh'")
    fi
  fi
}

install() {
  Linux::Apt::update
  Linux::Apt::install \
    bash-completion
}

testInstall() {
  Assert::fileExists /etc/profile.d/bash_completion.sh root root || return 1
}

configure() {
  if [[ "${PREFERRED_SHELL}" = "ShellBash" ]]; then
    CURRENT_USER_SHELL="$(grep "^${USERNAME}:" /etc/passwd | awk -F ":" '{print $7}')"
    if [[ "${CURRENT_USER_SHELL}" != "/bin/bash" ]]; then
      usermod --shell /bin/bash "${USERNAME}"
      Log::displayHelp "You have to log in/log out to make bash by default"
    fi
    if command -v zsh &>/dev/null; then
      Log::displayHelp "Bash is set as default shell, you can switch back to zsh using 'chsh -s /usr/bin/zsh'"
    fi
  fi

  curl -o "${USER_HOME}/.git-prompt.sh" \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh || return 1

  Conf::installFromEmbed "ShellBash" "${filesToInstall[@]}" || return 1
}

testConfigure() {
  local -i failures=0
  Assert::fileExists "${USER_HOME}/.git-prompt.sh" || ((++failures))
  Conf::installFromEmbedCheck "${filesToInstall[@]}" || ((failures = failures + $?))
  grep -E -q 'fasd_cache="\$\{HOME\}/\.fasd-init-bash"' "${USER_HOME}/.bashrc" || {
    Log::displayError "${USER_HOME}/.bashrc doesn't seem to have been updated"
    ((++failures))
  }

  return "${failures}"
}
