#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Font
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/installScripts/Font.ps1" as fontScript

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Font"
}

helpDescription() {
  echo "Font"
}

dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

fortunes() {
  if Assert::wsl; then
    if ! ls "${WINDOWS_PROFILE_DIR}/AppData/Local/Microsoft/Windows/Fonts/mesloLGS_NF"*.ttf &>/dev/null; then
      fortunes+=("Font 'Meslo LG S' does not seem to be installed, use 'install Font' to get better terminal results")
    fi
  fi
}

install() {
  if ! Assert::wsl; then
    Log::displaySkipped "Font installs only on wsl"
    return 0
  fi

  # shellcheck disable=SC2317
  changeBranchOnSuccess() {
    (
      cd /opt/IlanCosman-tide-fonts || return 1
      sudo git checkout assets
    )
  }

  SUDO=sudo Git::cloneOrPullIfNoChanges \
    "/opt/IlanCosman-tide-fonts" \
    "https://github.com/IlanCosman/tide.git" \
    changeBranchOnSuccess \
    changeBranchOnSuccess

  (
    # shellcheck disable=SC2154
    cp "${embed_file_fontScript}" "${TMPDIR:-/tmp}/Font.ps1"
    local tempFolder
    tempFolder="$(mktemp -p "${TMPDIR:-/tmp}" -d)"
    chmod 777 "${tempFolder}"
    cp "/opt/IlanCosman-tide-fonts/fonts/mesloLGS_NF"*.ttf "${tempFolder}"
    cd "${tempFolder}" || exit 1
    powershell.exe -ExecutionPolicy Bypass -NoProfile \
      -Command "$(Linux::Wsl::cachedWslpath -w "${TMPDIR:-/tmp}/Font.ps1")" \
      -verbose "$(Linux::Wsl::cachedWslpath -w "${tempFolder}")"
  )
}

testInstall() {
  local -i failures=0

  Assert::fileExists /opt/IlanCosman-tide-fonts/fonts/mesloLGS_NF_regular.ttf root root || ((++failures))
  
  local localAppData
  localAppData="$(Linux::Wsl::cachedWslpathFromWslVar LOCALAPPDATA)"
  Assert::fileExists "${localAppData}/Microsoft/Windows/Fonts/mesloLGS_NF_regular.ttf" || {
    ((++failures))
    Log::displayError "Font mesloLGS_NF_regular.ttf not installed in windows folder: ${localAppData}/Microsoft/Windows/Fonts"
  }
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
