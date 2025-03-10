#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/_Configs/FortunesForProfile-conf" as conf_dir

helpDescription() {
  echo "installs fortune software and generate fortunes"
}

helpLongDescription() {
  helpDescription
  echo "The fortunes generated are based on scripts selected in bash-dev-env"
}

dependencies() {
  echo "installScripts/Anacron"
}

fortunes() {
  if [[ "${SHOW_FORTUNES}" = "1" ]]; then
    # shellcheck disable=SC2016
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- You can set ${__HELP_EXAMPLE}SHOW_FORTUNES${__RESET_COLOR} to ${__HELP_EXAMPLE}0${__RESET_COLOR} in ${__HELP_EXAMPLE}${BASH_DEV_ENV_ROOT_DIR}/.env${__RESET_COLOR} to hide fortunes."
    echo "%"
  fi
}

listVariables() {
  echo "PROFILE"
}

helpVariables() {
  echo "${__HELP_EXAMPLE}PROFILE${__HELP_NORMAL}"
  echo "  The profile selected when calling the install command"
}

# jscpd:ignore-start
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  Linux::Apt::installIfNecessary --no-install-recommends \
    cowsay \
    lolcat \
    fortune-mod
}

testInstall() {
  Assert::commandExists fortune
  Assert::commandExists lolcat
  Assert::commandExists cowsay
}

configure() {
  Log::displayInfo "prepare fortunes database file"
  sudo touch /etc/fortune-help-commands
  sudo chown "${USERNAME}:${USERGROUP}" /etc/fortune-help-commands

  Log::displayInfo "Install cron to update fortunes"
  if [[ -z "${PROFILE}" ]]; then
    Log::displayHelp "Please provide a profile to the install command in order to activate automatic fortune generation"
  else
    local -a cmd=(
      sudo -E -n -u "${USERNAME}" bash -l
      "${BASH_DEV_ENV_ROOT_DIR}/bin/fortune"
      -p "${PROFILE}"
    )
    SUDO=sudo Conf::createCron \
      "/etc/cron.daily/bash-dev-env-fortune" \
      fortune-job.log \
      "${cmd[@]}"

    # generate /etc/fortune-help-commands and /etc/fortune-help-commands.dat
    SKIP_REQUIRES=1 "${cmd[@]}" || {
      Log::displayError "fortunes generation failure"
      return 1
    }
  fi

  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "$(fullScriptOverrideDir)" \
    ".bash-dev-env"
}

testConfigure() {
  local -i failures=0
  Assert::fileExists /etc/fortune-help-commands || ((++failures))
  if [[ -n "${PROFILE}" ]]; then
    Log::displayInfo "checking Fortune cron configuration"
    Assert::fileExecutable "/etc/cron.daily/bash-dev-env-fortune" "root" "root" || ((++failures))
    if ! grep -q -E -e "fortune -p ${PROFILE}" /etc/cron.daily/bash-dev-env-fortune; then
      ((failures++))
      Log::displayError "File /etc/cron.daily/bash-dev-env-fortune content invalid"
    fi
  fi
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/displayFortunes.sh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/displayFortunes.zsh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/displayFortunes.bash" || ((++failures))
  return "${failures}"
}
