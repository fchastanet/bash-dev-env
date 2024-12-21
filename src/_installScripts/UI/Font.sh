#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/UI/Font.ps1" as fontScript
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/UI/.Xresources" as xResources

fontBeforeParseCallback() {
  Git::requireGitCommand
}

helpDescription() {
  echo "$(scriptName) - installs mesloLGS_NF font in windows"
}

fortunes() {
  if Assert::wsl; then
    if ! ls "${WINDOWS_PROFILE_DIR}/AppData/Local/Microsoft/Windows/Fonts/mesloLGS_NF"*.ttf &>/dev/null; then
      echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- The font ${__HELP_EXAMPLE}Meslo LG S${__RESET_COLOR} does not seem to be installed, use ${__HELP_EXAMPLE}installAndConfigure Font${__RESET_COLOR} to get better terminal results."
      echo "%"
    fi
  fi
}

# jscpd:ignore-start
dependencies() { :; }
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
isInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
isTestInstallImplemented() { :; }
# jscpd:ignore-end

install() {
  if ! Assert::wsl; then
    Log::displaySkipped "Font installs only on wsl"
    return 0
  fi

  SUDO=sudo GIT_CLONE_OPTIONS="--depth=1 --branch assets" Git::cloneOrPullIfNoChanges \
    "/opt/IlanCosman-tide-fonts" \
    "https://github.com/IlanCosman/tide.git"

  local fontDir
  Linux::Wsl::cachedWslpath2 fontDir -w "${TMPDIR:-/tmp}/Font.ps1"
  local windowsTempDir
  Linux::Wsl::cachedWslpath2 windowsTempDir -w "${tempFolder}"
  (
    # shellcheck disable=SC2154
    cp "${embed_file_fontScript}" "${TMPDIR:-/tmp}/Font.ps1"
    local tempFolder
    tempFolder="$(mktemp -p "${TMPDIR:-/tmp}" -d)"
    chmod 777 "${tempFolder}"
    # Copy and rename files in one step
    local file
    for file in "/opt/IlanCosman-tide-fonts/fonts/mesloLGS_NF"*.ttf; do
      local filename="${file##*/}"     # Remove path
      local newName="${filename//_/ }" # Replace underscores with spaces
      cp "${file}" "${tempFolder}/${newName}"
    done
    cd "${tempFolder}" || exit 1
    powershell.exe -ExecutionPolicy Bypass -NoProfile \
      -Command "${fontDir}" \
      -verbose "${windowsTempDir}"
  )
}

testInstall() {
  local -i failures=0

  USERNAME="" USERGROUP="" Assert::fileExists /opt/IlanCosman-tide-fonts/fonts/mesloLGS_NF_regular.ttf || ((++failures))

  local localAppData
  Linux::Wsl::cachedWslpathFromWslVar2 localAppData LOCALAPPDATA
  local fontPath="${localAppData}/Microsoft/Windows/Fonts"
  USERNAME="" USERGROUP="" Assert::fileExists "${fontPath}/mesloLGS NF regular.ttf" || {
    ((++failures))
    Log::displayError "Font 'mesloLGS NF regular.ttf' not installed in windows folder: ${fontPath}"
  }
  return "${failures}"
}

configure() {
  # shellcheck disable=SC2154
  Install::file \
    "${embed_file_xResources}" \
    "${HOME}/.Xresources"
}

testConfigure() {
  Assert::fileExists "${HOME}/.Xresources" || ((++failures))
}
