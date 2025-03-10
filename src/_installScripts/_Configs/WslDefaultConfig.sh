#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/_Configs/WslDefaultConfig-conf" as wsl_conf

wslBeforeParseCallback() {
  Git::requireGitCommand
  Linux::requireSudoCommand
}

helpDescription() {
  echo "Wsl default configuration"
}

# jscpd:ignore-start
dependencies() { :; }
fortunes() { :; }
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
install() { :; }
testInstall() { :; }
# jscpd:ignore-end

computeMaxVhdSize() {
  local -i maxVhdSize minVhdSize
  local baseMntC maxHostDiskSize
  # shellcheck disable=SC1003
  baseMntC="$(mount | grep 'path=C:\\' | awk -F ' ' '{print $3}')"
  maxHostDiskSize="$(df -B 1 --output=size "${baseMntC}" | tail -n 1)"
  maxVhdSize=$((maxHostDiskSize / 3))

  # Ensure maxVhdSize is at least 150MB
  minVhdSize=$((150 * 1024 * 1024))
  if ((maxVhdSize < minVhdSize)); then
    maxVhdSize=${minVhdSize}
  fi

  # Round maxVhdSize to nearest multiple of 1024
  maxVhdSize=$(((maxVhdSize + 1023) / 1024 * 1024))

  echo "${maxVhdSize}"
}

configure() {
  sudo hostnamectl set-hostname "${DISTRO_HOSTNAME}"
  UI::warnUser
  SUDO=sudo Dns::addHost "${DISTRO_HOSTNAME}"
  if ! Assert::wsl; then
    Log::displaySkipped "Rest of configure skipped as not in WSL"
    return 0
  fi
  local configDir
  # shellcheck disable=SC2154
  configDir="$(Conf::getOverriddenDir "${embed_dir_wsl_conf}" "$(fullScriptOverrideDir)")"

  # shellcheck disable=SC2317
  updateWslConfig() {
    local targetFile="${2}"
    sed -i -E \
      -e "s/^memory=.*\$/memory=${WSLCONFIG_MAX_MEMORY:-8GB}/g" \
      -e "s/^swap=.*\$/swap=${WSLCONFIG_SWAP:-2GB}/g" \
      "${targetFile}"
    if [[ "${WSLCONFIG_COMPUTE_MAX_VHD_SIZE}" = "1" ]]; then
      sed -i -E \
        -e "s/^maxVhdSize=.*\$/maxVhdSize=$(computeMaxVhdSize)/g" \
        "${targetFile}"
    else
      sed -i -E \
        -e "s/^maxVhdSize=.*\$//g" \
        "${targetFile}"
    fi
  }
  CHANGE_WINDOWS_FILES="${CHANGE_WINDOWS_FILES:-1}" OVERWRITE_CONFIG_FILES=0 Install::file \
    "${configDir}/.wslconfig" \
    "${WINDOWS_PROFILE_DIR}/.wslconfig" \
    "${USERNAME}" "${USERGROUP}" \
    updateWslConfig

  SUDO=sudo OVERWRITE_CONFIG_FILES=0 Install::file \
    "${configDir}/wsl.conf" "/etc/wsl.conf" root root "Install::setUserRootCallback"

  CHANGE_WINDOWS_FILES="${CHANGE_WINDOWS_FILES:-1}" OVERWRITE_CONFIG_FILES=0 Install::file \
    "${configDir}/settings.json" \
    "$(Conf::getWindowsTerminalPath)/LocalState/settings.json"
}

testConfigure() {
  local -i failures=0
  if [[ "$(hostnamectl | grep 'hostname' | awk -F ': ' '{print $2}')" != "${DISTRO_HOSTNAME}" ]]; then
    Log::displayError "Hostname ${DISTRO_HOSTNAME} has not been set on this distro"
    ((++failures))
  fi
  if ! Dns::checkHostname "${DISTRO_HOSTNAME}"; then
    Log::displayError "Hostname ${DISTRO_HOSTNAME} is not reachable"
    ((++failures))
  fi
  if ! Assert::wsl; then
    return 0
  fi
  if ! USERNAME="" USERGROUP="" Assert::fileExists "/etc/wsl.conf"; then
    ((++failures))
    if ! grep -q -E "^root = /mnt/$" "/etc/wsl.conf"; then
      Log::displayError "/etc/wsl.conf does not contains root = /mnt/ instruction"
      ((++failures))
    fi
  fi

  if [[ "${CHANGE_WINDOWS_FILES:-1}" = "1" ]]; then
    if ! USERNAME="" USERGROUP="" Assert::fileExists "${WINDOWS_PROFILE_DIR}/.wslconfig"; then
      Log::displayError "${WINDOWS_PROFILE_DIR}/.wslconfig does not exists"
      ((++failures))
    fi
    local terminalConfSettingsPath
    terminalConfSettingsPath="$(Conf::getWindowsTerminalPath)/LocalState/settings.json"
    if ! USERNAME="" USERGROUP="" Assert::fileExists "${terminalConfSettingsPath}"; then
      Log::displayError "${terminalConfSettingsPath} does not exists"
      ((++failures))
    fi
  fi

  return "${failures}"
}
