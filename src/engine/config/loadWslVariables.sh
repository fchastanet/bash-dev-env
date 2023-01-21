#!/bin/bash

engine::config::loadWslVariables() {
  if ! Assert::wsl; then
    # skip
    return 0
  fi

  # shellcheck disable=SC1003
  BASE_MNT_C="$(mount | grep 'path=C:\\' | awk -F ' ' '{print $3}')"

  # TODO default value if not found or wslpath not working
  WINDOWS_DIR="$(Wsl::cachedWslpathFromWslVar SystemRoot "${WINDOWS_DIR:-${BASE_MNT_C}/Windows}")"
  export WINDOWS_DIR

  WINDOWS_PROFILE_DIR="$(Wsl::cachedWslpathFromWslVar USERPROFILE "${WINDOWS_PROFILE_DIR:-${BASE_MNT_C}/Users/$(id -un)}")"
  export WINDOWS_PROFILE_DIR

  # POWERSHELL_BIN
  if [[ -z "${POWERSHELL_BIN+xxx}" ]]; then
    POWERSHELL_BIN="${WINDOWS_DIR}/System32/WindowsPowerShell/v1.0/powershell.exe"
    if ! command -v "${POWERSHELL_BIN}" >/dev/null 2>&1; then
      POWERSHELL_BIN="$(command -v powershell.exe 2>/dev/null)"
    fi
  fi
  if ! command -v "${POWERSHELL_BIN}" >/dev/null 2>&1; then
    Log::fatal "command powershell.exe not found"
  fi
  export POWERSHELL_BIN

  # Deduce wsl.exe path
  if [[ -z "${WSL_EXE_BIN+xxx}" ]]; then
    WSL_EXE_BIN="${WINDOWS_DIR}/system32/wsl.exe"
    if ! command -v "${WSL_EXE_BIN}" >/dev/null 2>&1; then
      WSL_EXE_BIN="$(command -v wsl.exe 2>/dev/null)"
    fi
  fi
  if ! command -v "${WSL_EXE_BIN}" >/dev/null 2>&1; then
    Log::fatal "command wsl.exe not found"
  fi
  export WSL_EXE_BIN

  # IPCONFIG_BIN - which ipconfig.exe does not work when executed as root
  if [[ -z "${IPCONFIG_BIN+xxx}" ]]; then
    IPCONFIG_BIN="${WINDOWS_DIR}/system32/ipconfig.exe"
    if ! command -v "${IPCONFIG_BIN}" >/dev/null 2>&1; then
      IPCONFIG_BIN="$(command -v ipconfig.exe 2>/dev/null)"
    fi
  fi
  if ! command -v "${IPCONFIG_BIN}" >/dev/null 2>&1; then
    Log::fatal "command ipconfig.exe not found"
  fi
  export IPCONFIG_BIN
}
