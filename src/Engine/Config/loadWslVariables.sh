#!/bin/bash

# @description load wsl env variables
# @set BASE_MNT_C
# @set WINDOWS_DIR
# @set WINDOWS_PROFILE_DIR
# @set LOCAL_APP_DATA
# @set WINDOW_PATH
# @set WSL_EXE_BIN
# @set IPCONFIG_BIN
# @set POWERSHELL_BIN
# @env WSL_EXE_BIN
# @env IPCONFIG_BIN
# @env POWERSHELL_BIN
Engine::Config::loadWslVariables() {
  if ! Assert::wsl; then
    # skip
    return 0
  fi
  # shellcheck disable=SC1003
  BASE_MNT_C="$(mount | grep 'path=C:\\' | awk -F ' ' '{print $3}')"
  export BASE_MNT_C

  WINDOWS_DIR="$(Linux::Wsl::cachedWslpathFromWslVar SystemRoot)"
  WINDOWS_DIR="${WINDOWS_DIR:-${BASE_MNT_C}/Windows}"
  export WINDOWS_DIR

  WINDOWS_PROFILE_DIR="$(Linux::Wsl::cachedWslpathFromWslVar USERPROFILE)"
  WINDOWS_PROFILE_DIR="${WINDOWS_PROFILE_DIR:-${BASE_MNT_C}/Users/$(id -un)}"
  export WINDOWS_PROFILE_DIR

  LOCAL_APP_DATA="$(Linux::Wsl::cachedWslpathFromWslVar LOCALAPPDATA | tr -d '\n\r')"
  export LOCAL_APP_DATA

  # WINDOW_PATH
  WINDOW_PATH="$(Linux::Wsl::cachedWslvar PATH)"
  WINDOW_PATH="${WINDOW_PATH//;/:}"
  WINDOW_PATH="${WINDOW_PATH//\\//}"
  WINDOW_PATH="${WINDOW_PATH//C:/${BASE_MNT_C}}"

  deduceBin() {
    local var="$1"
    local expectedFullPath="$2"
    local expectedBin="$3"
    if [[ -z "${!var+xxx}" ]]; then
      eval "${var}=${expectedFullPath}"
      if ! command -v "${!var}" >/dev/null 2>&1; then
        eval "${var}=$(command -v "${expectedBin}" 2>/dev/null)"
      fi
    fi
    if [[ -z "${!var:-}" ]] || ! command -v "${!var}" >/dev/null 2>&1; then
      Log::fatal "variable ${var} - command ${expectedBin} not found"
    fi
    # shellcheck disable=SC2163
    export "${var}"
  }

  checkBinary() {
    local var="$1"
    if [[ -z "${var}" || ! -x "${!var}" ]]; then
      Log::displayError "variable ${var} - binary '${!var}' does not exist or not executable"
      ((errorCount++))
    fi
  }

  local errorCount=0
  # IPCONFIG_BIN - which ipconfig.exe does not work when executed as root
  deduceBin IPCONFIG_BIN "${WINDOWS_DIR}/System32/ipconfig.exe" "ipconfig.exe"
  checkBinary IPCONFIG_BIN

  deduceBin WSL_EXE_BIN "${WINDOWS_DIR}/System32/wsl.exe" "wsl.exe"
  checkBinary WSL_EXE_BIN

  deduceBin POWERSHELL_BIN "${WINDOWS_DIR}/System32/WindowsPowerShell/v1.0/powershell.exe" "powershell.exe"
  checkBinary POWERSHELL_BIN

  return "${errorCount}"
}
