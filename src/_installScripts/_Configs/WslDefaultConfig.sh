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
  minVhdSize=$((150*1024*1024))
  if (( maxVhdSize < minVhdSize )); then
    maxVhdSize=${minVhdSize}
  fi

  # Round maxVhdSize to nearest multiple of 1024
  maxVhdSize=$(( (maxVhdSize + 1023) / 1024 * 1024 ))

  echo "${maxVhdSize}"
}

configure() {
  sudo hostnamectl set-hostname "${DISTRO_HOSTNAME}"
  SUDO=sudo Dns::addHost "${DISTRO_HOSTNAME}"
  local fileToInstall
  if ! Assert::wsl; then
    Log::displaySkipped "Rest of configure skipped as not in WSL"
    return 0
  fi
  # shellcheck disable=SC2154
  fileToInstall="$(Conf::dynamicConfFile "${scriptName}/.wslconfig" "${embed_dir_wsl_conf}/.wslconfig")" || return 1
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
  CHANGE_WINDOWS_FILES=1 OVERWRITE_CONFIG_FILES=0 Install::file \
    "${fileToInstall}" \
    "${WINDOWS_PROFILE_DIR}/.wslconfig" \
    "${USERNAME}" "${USERGROUP}" \
    updateWslConfig

  # shellcheck disable=SC2154
  fileToInstall="$(Conf::dynamicConfFile "${scriptName}/wsl.conf" "${embed_dir_wsl_conf}/wsl.conf")" || return 1
  SUDO=sudo OVERWRITE_CONFIG_FILES=0 Install::file \
    "${fileToInstall}" "/etc/wsl.conf" root root "Install::setUserRootCallback"
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
  if ! Assert::fileExists "/etc/wsl.conf" "root" "root"; then
    ((++failures))
    if ! grep -q -E "^root = /mnt/$" "/etc/wsl.conf"; then
      Log::displayError "/etc/wsl.conf does not contains root = /mnt/ instruction"
      ((++failures))
    fi
  fi
  if ! Assert::fileExists "/etc/wsl.conf" "${USERNAME}" "${USERGROUP}"; then
    Log::displayError "/etc/wsl.conf does not exists"
    ((++failures))
  fi
  return "${failures}"
}
