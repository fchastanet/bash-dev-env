#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/GitConfig
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/GitConfig/.gitconfig" as gitconfig
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/GitConfig/.gitignore" as gitignore
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/GitConfig/.tigrc" as tigrc
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/GitConfig/.config/git" as dot_config_dir


declare -a filesToInstall=(
  gitconfig
  gitignore
  tigrc
)
.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "GitConfig"
}

helpDescription() {
  echo "GitConfig"
}

dependencies() { 
  echo "Tig"
}

fortunes() { 
  fortunes+=("GitConfig - default main branch is set to $(git config --global --get init.defaultBranch) set in your ~/.gitconfig")
}

helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
install() { :; }
testInstall() { :; }

configure() {
  OVERWRITE_CONFIG_FILES=0 Conf::installFromEmbed "GitConfig" "${filesToInstall[@]}" || return 1

  # updateGitConfig
  if [[ -n "${GIT_USERNAME}" ]]; then
    git config --global user.name "${GIT_USERNAME}"
  fi
  if [[ -n "${GIT_USER_MAIL}" ]]; then
    git config --global user.email "${GIT_USER_MAIL}"
  fi
  git config --global init.defaultBranch master
  git config --global core.excludesFile "${USER_HOME}/.gitignore"

  local baseDirToInstall dirToInstall
  # shellcheck disable=SC2154
  baseDirToInstall="$(Conf::dynamicConfDir "GitConfig/.config" "${dot_config_dir}")" || return 1
  dirToInstall="${baseDirToInstall}"
  if [[ ! -d "${baseDirToInstall}/git" ]]; then
    dirToInstall="${dot_config_dir}"
  fi
  OVERWRITE_CONFIG_FILES=0 Install::dir \
    "${dirToInstall}" "${USER_HOME}/.config" "git" || return 1

  dirToInstall="${baseDirToInstall}"
  if [[ ! -d "${baseDirToInstall}/tig" ]]; then
    dirToInstall="${dot_config_dir}"
  fi
  OVERWRITE_CONFIG_FILES=0 Install::dir \
    "${dirToInstall}" "${USER_HOME}/.config" "tig" || return 1

  if [[ -f "${BASE_MNT_C}/Program Files (x86)/Meld/Meld.exe" ]]; then
    git config --global diff.tool meld
    git config --global alias.dt 'difftool -d'
    sudo ln -sf "${BASE_MNT_C}/Program Files (x86)/Meld/Meld.exe" /usr/local/bin/meld
  else
    Log::displayHelp "GitConfig - windows meld is not installed, it could have been linked into wsl as git diff"
  fi

  # add github.com to the list of known hosts
  HOME="${USER_HOME}" Ssh::fixAuthenticityOfHostCantBeEstablished "github.com"
}

testConfigure() {
  local -i failures=0
  Assert::fileExists "${USER_HOME}/.gitconfig" || ((++failures))
  Assert::fileExists "${USER_HOME}/.config/git/ignore" || ((++failures))
  Assert::fileExists "${USER_HOME}/.config/tig/config" || ((++failures))

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
