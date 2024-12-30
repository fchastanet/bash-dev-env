#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/_Configs/GitDefaultConfig-conf" as conf_dir

gitDefaultConfigBeforeParseCallback() {
  Ssh::requireSshKeygenCommand
  Ssh::requireSshKeyscanCommand
}

helpDescription() {
  echo "Default .gitconfig with aliases"
}

dependencies() {
  echo "installScripts/ShellBashDefaultConfig"
  echo "installScripts/Tig"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- default ${__HELP_EXAMPLE}main${__RESET_COLOR} branch is set to ${__HELP_EXAMPLE}$(git config --global --get init.defaultBranch)${__RESET_COLOR}, you can change it in your ${__HELP_EXAMPLE}~/.gitconfig${__RESET_COLOR}."
  echo "%"
}

listVariables() {
  echo "GIT_USERNAME"
  echo "GIT_USER_MAIL"
  echo "BASE_MNT_C"
}

# jscpd:ignore-start
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
install() { :; }
testInstall() { :; }
# jscpd:ignore-end

cleanBeforeExport() {
  git config --global --unset user.name || true
  git config --global --unset user.email || true
  rm -f "${HOME}/.gitconfig" || true
}

testCleanBeforeExport() {
  ((failures = 0)) || true
  if [[ -f "${HOME}/.gitconfig" ]]; then
    if git config --global --get user.name &>/dev/null; then
      Log::displayError "Export - .gitconfig user.name has not been removed"
      ((++failures))
    fi
    if git config --global --get user.email &>/dev/null; then
      Log::displayError "Export - .gitconfig user.email has not been removed"
      ((++failures))
    fi
  fi

  return "${failures}"
}

configure() {
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

  # updateGitDefaultConfig
  if [[ -n "${GIT_USERNAME}" ]]; then
    git config --global user.name "${GIT_USERNAME}"
  fi
  if [[ -n "${GIT_USER_MAIL}" ]]; then
    git config --global user.email "${GIT_USER_MAIL}"
  fi

  configureMeld() {
    local meldBinaryPath="$1"
    if [[ -f "${meldBinaryPath}" ]]; then
      if [[ "${GIT_MERGE_TOOL:-}" = "meld" ]]; then
        Log::displayInfo "Configuring meld as default diff tool"
        git config --global diff.tool meld
        git config --global difftool.prompt false
        # shellcheck disable=SC2016
        git config --global difftool.meld.cmd 'meld "$LOCAL" "$REMOTE"'
        git config --global alias.dt 'difftool -d'

        git config --global merge.tool meld
        git config --global mergetool.prompt false
        # shellcheck disable=SC2016
        git config --global mergetool.meld.cmd 'meld "$LOCAL" "$MERGED" "$REMOTE" --output "$MERGED"'
        git config --global alias.mt 'mergetool -d'
      fi
      sudo ln -sf "${meldBinaryPath}" /usr/local/bin/meld
      return 0
    fi
    return 1
  }
  configureMeld "${BASE_MNT_C:-/mnt/c}/Program Files (x86)/Meld/Meld.exe" ||
    configureMeld "${BASE_MNT_C:-/mnt/c}/Program Files/Meld/Meld.exe" ||
    Log::displayHelp "File ${BASE_MNT_C:-/mnt/c}/Program Files (x86)/Meld/Meld.exe does not exist - windows meld is not installed, it could have been linked into wsl as git diff"

  # add github.com to the list of known hosts
  HOME="${HOME}" Ssh::fixAuthenticityOfHostCantBeEstablished "github.com"
}

testConfigure() {
  local -i failures=0
  Assert::fileExists "${HOME}/.gitconfig" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/GitDefaultConfig/gitignore" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/git.sh" || ((++failures))
  local WINDOWS_MELD_PATH1="${BASE_MNT_C:-/mnt/c}/Program Files (x86)/Meld/Meld.exe"
  local WINDOWS_MELD_PATH2="${BASE_MNT_C:-/mnt/c}/Program Files/Meld/Meld.exe"
  if [[ -f "${WINDOWS_MELD_PATH1}" || -f "${WINDOWS_MELD_PATH2}" ]]; then
    Assert::symLinkValid /usr/local/bin/meld
  fi
  # git config
  local gitUserName
  gitUserName="$(git config --global --get user.name)"
  Log::displayInfo "check git user name validity '${gitUserName}'"
  if [[ -z "${gitUserName}" ]]; then
    Log::displayError "empty git user name"
    ((++failures))
  fi
  if [[ "${gitUserName}" != "${GIT_USERNAME}" ]]; then
    Log::displayWarning "git user name is not the same as GIT_USERNAME in ${BASH_DEV_ENV_ROOT_DIR}/.env"
  fi

  local gitEmail
  gitEmail="$(git config --global --get user.email)"
  Log::displayInfo "check git user email validity '${gitEmail}'"
  if [[ -z "${gitEmail}" ]]; then
    Log::displayError "empty git user email"
    ((++failures))
  fi
  if [[ "${gitEmail}" != "${GIT_USER_MAIL}" ]]; then
    Log::displayWarning "git user email is not the same as GIT_USER_MAIL in ${BASH_DEV_ENV_ROOT_DIR}/.env"
  fi

  return "${failures}"
}
