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
isInstallImplemented() { :; }
isTestInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
# jscpd:ignore-end

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

  if [[ -f "${BASE_MNT_C:-/mnt/c}/Program Files (x86)/Meld/Meld.exe" ]]; then
    Log::displayInfo "Configuring meld as default diff tool"
    git config --global diff.tool meld
    git config --global alias.dt 'difftool -d'
    sudo ln -sf "${BASE_MNT_C:-/mnt/c}/Program Files (x86)/Meld/Meld.exe" /usr/local/bin/meld
  else
    Log::displayHelp "File ${BASE_MNT_C:-/mnt/c}/Program Files (x86)/Meld/Meld.exe does not exist - windows meld is not installed, it could have been linked into wsl as git diff"
  fi

  # add github.com to the list of known hosts
  HOME="${HOME}" Ssh::fixAuthenticityOfHostCantBeEstablished "github.com"
}

testConfigure() {
  local -i failures=0
  Assert::fileExists "${HOME}/.gitconfig" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/GitDefaultConfig/gitignore" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/git.sh" || ((++failures))
  Assert::fileExists "${HOME}/.config/tig/config" || ((++failures))
  Assert::fileExists "${HOME}/.tigrc" || ((++failures))

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