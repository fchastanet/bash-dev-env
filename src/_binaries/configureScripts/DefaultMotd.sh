#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/DefaultMotd
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/etc/update-motd.d/00-wsl-header" as motd00
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/etc/update-motd.d/01-wsl-sysinfo" as motd01
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/etc/update-motd.d/03-wsl-automatic-upgrade" as motd03
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/etc/cron.daily/motd" as dailyMotd

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "DefaultMotd"
}

helpDescription() {
  echo "DefaultMotd"
}

dependencies() {
  echo "Motd"
}

fortunes() {
  if [[ "${SHOW_MOTD}" = "1" ]]; then
    fortunes+=("You can set SHOW_MOTD to 0 in '${BASH_DEV_ENV_ROOT_DIR}/.env' to hide motd")
  else
    fortunes+=("You can set SHOW_MOTD to 1 in '${BASH_DEV_ENV_ROOT_DIR}/.env' to display motd")
  fi
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
  local fileToInstall
  # shellcheck disable=SC2154
  fileToInstall="$(Conf::dynamicConfFile "etc/update-motd.d/00-wsl-header" "${embed_file_motd00}")" || return 1
  SUDO=sudo OVERWRITE_CONFIG_FILES=1 Install::file \
    "${fileToInstall}" "/etc/update-motd.d/00-wsl-header" \
    "root" "root" \
    Install::setRootExecutableCallback || return 1

  # shellcheck disable=SC2154
  fileToInstall="$(Conf::dynamicConfFile "etc/update-motd.d/01-wsl-sysinfo" "${embed_file_motd01}")" || return 1
  SUDO=sudo OVERWRITE_CONFIG_FILES=1 Install::file \
    "${fileToInstall}" "/etc/update-motd.d/01-wsl-sysinfo" \
    "root" "root" \
    Install::setRootExecutableCallback || return 1

  # shellcheck disable=SC2154
  fileToInstall="$(Conf::dynamicConfFile "etc/update-motd.d/03-wsl-automatic-upgrade" "${embed_file_motd03}")" || return 1
  SUDO=sudo OVERWRITE_CONFIG_FILES=1 Install::file \
    "${fileToInstall}" "/etc/update-motd.d/03-wsl-automatic-upgrade" \
    "root" "root" \
    Install::setRootExecutableCallback || return 1

  # shellcheck disable=SC2154
  fileToInstall="$(Conf::dynamicConfFile "etc/cron.daily/motd" "${embed_file_dailyMotd}")" || return 1
  BACKUP_BEFORE_INSTALL=0 SUDO=sudo OVERWRITE_CONFIG_FILES=1 Install::file \
    "${fileToInstall}" "/etc/cron.daily/motd" \
    "root" "root" \
    Install::setRootExecutableCallback || return 1

  # disable some parts
  sudo chmod 600 /etc/update-motd.d/00-header
  sudo chmod 600 /etc/update-motd.d/10-help-text
  if [[ -f /usr/share/landscape/landscape-sysinfo.wrapper ]]; then
    sudo chmod 600 /usr/share/landscape/landscape-sysinfo.wrapper
  fi

  # update motd cache
  sudo update-motd >/dev/null

}

testConfigure() {
  local -i failures=0
  Assert::fileExecutable "/etc/update-motd.d/00-wsl-header" "root" "root" || ((++failures))
  Assert::fileExecutable "/etc/update-motd.d/01-wsl-sysinfo" "root" "root" || ((++failures))
  Assert::fileExecutable "/etc/update-motd.d/03-wsl-automatic-upgrade" "root" "root" || ((++failures))
  Assert::fileNotExecutable "/etc/update-motd.d/10-help-text" "root" "root" || ((++failures))
  Assert::fileNotExecutable "/etc/update-motd.d/00-header" "root" "root" || ((++failures))

  Assert::fileExecutable "/etc/cron.daily/motd" "root" "root" || ((++failures))

  if ! sudo update-motd >/dev/null; then
    Log::displayWarning "motd not working"
    ((++failures))
  fi
  if [[ -z "$(sudo update-motd)" ]]; then
    Log::displayWarning "motd is empty"
    ((++failures))
  fi
  return "${failures}"
}
