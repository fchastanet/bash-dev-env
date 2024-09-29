#!/usr/bin/env bash

# shellcheck disable=SC2034
declare commandFunctionName="installScriptCommand"

defaultBeforeParseCallback() {
  Env::requireLoad
  UI::requireTheme
  Log::requireLoad
  Linux::requireUbuntu
  Linux::Wsl::requireWsl
  InstallScripts::isInterfaceMandatoryFunctionImplemented
}

scriptName() {
  echo "{{ .Data.binData.commands.default.commandName }}"
}

beforeParseCallback() {
  defaultBeforeParseCallback
}

commandHelpFunction() {
  echo "Available commands:"
  echo ""
}

listOrNone() {
  local string="$1"
  if [[ -z "${string:-}" ]]; then
    echo -e "${__HELP_EXAMPLE}None${__HELP_NORMAL}" | sed 's/^/    /'
  else
    echo -ne "${__HELP_OPTION_COLOR}"
    echo -e "${string}" | sed 's/^/    - /'
    echo -ne "${__HELP_NORMAL}"
  fi
}

helpDescriptionFunction() {
  helpDescription
  echo
}

helpLongDescription() {
  helpDescription
}

helpLongDescriptionFunction() {
  helpLongDescription | sed 's/^/  /'
  echo
  echo -e "  ${__HELP_TITLE}List of needed variables:${__HELP_NORMAL}"
  listOrNone "$(listVariables)"
  echo
  local variables
  variables="$(helpVariables)"
  if [[ -n "${variables}" ]]; then
    echo -e "${variables}" | sed 's/^/    /'
    echo
  fi
  echo -e "  ${__HELP_TITLE}List of dependencies:${__HELP_NORMAL}"
  listOrNone "$(dependencies)"
}

isInstallImplemented() {
  ! InstallScripts::scriptFunctionEmpty install
}

isTestInstallImplemented() {
  ! InstallScripts::scriptFunctionEmpty testInstall
}

isConfigureImplemented() {
  ! InstallScripts::scriptFunctionEmpty configure
}

isTestConfigureImplemented() {
  ! InstallScripts::scriptFunctionEmpty testConfigure
}

fullScriptName() {
  File::relativeToDir "${REAL_SCRIPT_FILE}" "${BASH_DEV_ENV_ROOT_DIR}"
}

argsInstallScriptCommandCallback() {
  if [[ -n "${command}" ]]; then
    case "${command}" in
      isInterfaceImplemented)
        InstallScripts::isInterfaceMandatoryFunctionImplemented
        exit $?
        ;;
      install | testInstall | configure | testConfigure)
        afterParseCallback
        ;;
      *) ;;
    esac
    "${command}"
    exit $?
  fi
}
