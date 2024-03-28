#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/MandatorySoftwares
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/home/.bash-dev-env" as bashDevEnv
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/etc/cron.d/bash-dev-env-upgrade" as upgradeCronTab

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "MandatorySoftwares"
}

helpDescription() {
  echo "MandatorySoftwares"
}

dependencies() {
  echo "WslConfig"
}

fortunes() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  Linux::Apt::update
  # configure language support
  Linux::Apt::install \
    language-selector-common
  # shellcheck disable=SC2046
  Linux::Apt::install \
    tzdata \
    $(check-language-support)

  PACKAGES=(
    build-essential
    cron
    curl
    dos2unix
    jq
    mysql-client
    # net-tools to get netstat
    net-tools
    parallel
    putty-tools
    pv
    # add add-apt-repository
    software-properties-common
    unzip
    vim
    vim-gui-common
    vim-runtime
    wget
  )
  Linux::Apt::install "${PACKAGES[@]}"
}

testInstall() {
  local -i failures=0

  Assert::commandExists "nc" || ((++failures))
  Assert::commandExists "dos2unix" || ((++failures))
  Assert::commandExists "jq" || ((++failures))
  Assert::commandExists "make" || ((++failures))
  Assert::commandExists "unzip" || ((++failures))
  if ! PAGER=/usr/bin/cat dpkg -l cron &>/dev/null; then
    Log::displayError "cron is not installed"
    ((++failures))
  fi

  return "${failures}"
}

configureUpdateCron() {
  Log::displayInfo "Install upgrade cron"
  if [[ -z "${PROFILE}" ]]; then
    Log::displayHelp "Please provide a profile to the install command in order to activate automatic upgrade"
  else
    # shellcheck disable=SC2317
    updateCronUpgrade() {
      local -a cmd=(
        CAN_TALK_DURING_INSTALLATION=0
        INSTALL_INTERACTIVE=0
        sudo 
        -i -n
        -u "${USERNAME}"
        "${BASH_DEV_ENV_ROOT_DIR}/install" 
        -p "${PROFILE}" 
        --skip-configure --skip-test
      )
      sudo sed -i -E -e "s#@COMMAND@#(cd '${BASH_DEV_ENV_ROOT_DIR}' \&\& ${cmd[*]} \&>'${BASH_DEV_ENV_ROOT_DIR}/logs/upgrade-job.log')#" "/etc/cron.d/bash-dev-env-upgrade"
      SUDO=sudo Install::setUserRightsCallback "$@"
    }

    local file
    # shellcheck disable=SC2154
    file="$(Conf::dynamicConfFile "/etc/cron.d/bash-dev-env-upgrade" "${embed_file_upgradeCronTab}")" || return 1
    SUDO=sudo OVERWRITE_CONFIG_FILES=1 BACKUP_BEFORE_INSTALL=0 Install::file \
      "${file}" "/etc/cron.d/bash-dev-env-upgrade" root root updateCronUpgrade
    sudo chmod +x "/etc/cron.d/bash-dev-env-upgrade"
  fi
}

configure() {
  Engine::Config::installBashDevEnv
  configureUpdateCron
  # remove parallel nagware
  mkdir -p "${USER_HOME}/.parallel"
  touch "${USER_HOME}/.parallel/will-cite"
}

testConfigure() {
  local -i failures=0

  Assert::fileExists "${USER_HOME}/.bash-dev-env" || ((++failures))
  SUDO=sudo Assert::fileExists "/root/.bash-dev-env" "root" "root" || ((++failures))
  Log::displayInfo "checking BASH_DEV_ENV_ROOT_DIR variable replaced in ${USER_HOME}/.bash-dev-env"
  if ! grep -q -P "BASH_DEV_ENV_ROOT_DIR=${BASH_DEV_ENV_ROOT_DIR}" "${USER_HOME}/.bash-dev-env"; then
    Log::displayError "Variable 'BASH_DEV_ENV_ROOT_DIR' has not been replaced in file ${USER_HOME}/.bash-dev-env"
    ((++failures))
  fi

  Log::displayInfo "checking WINDOWS_PROFILE_DIR replaced in ${USER_HOME}/.bash-dev-env"
  if ! grep -q -P "WINDOWS_PROFILE_DIR=${WINDOWS_PROFILE_DIR}" "${USER_HOME}/.bash-dev-env"; then
    Log::displayError "Variable 'WINDOWS_PROFILE_DIR' has not been replaced in file ${USER_HOME}/.bash-dev-env"
    ((++failures))
  fi

  if [[ -n "${PROFILE}" ]]; then
    Log::displayInfo "checking Upgrade cron configuration"
    Assert::fileExecutable "/etc/cron.d/bash-dev-env-upgrade" "root" "root" || ((++failures))
    if ! grep -q -E -e "install -p ${PROFILE}" /etc/cron.d/bash-dev-env-upgrade; then
      ((failures++))
      Log::displayError "File /etc/cron.d/bash-dev-env-upgrade content invalid"
    fi
  fi
  return "${failures}"
}
