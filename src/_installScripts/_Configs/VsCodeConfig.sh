#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/_Configs/VsCodeConfig-conf" as conf_dir

helpDescription() {
  echo "VsCode default configuration"
}

dependencies() {
  # needs nodes with hjson package
  echo "installScripts/NodeDependencies"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- code -- will launch visual studio code."
  echo "%"
}

# jscpd:ignore-start
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
isInstallImplemented() { :; }
isTestInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
# jscpd:ignore-end

install() {
  if ! command -v code &>/dev/null; then
    Log::displaySkipped "You must install vscode in windows before running that script"
    return 0
  fi
  # vscode is preinstalled
  Log::displayInfo "Make vscode download vscode server"
  code --help
}

testInstall() {
  if ! command -v code &>/dev/null; then
    Log::displaySkipped "You must install vscode in windows before running that script"
    return 0
  fi
  Assert::commandExists code
}

installVsCodeExtension() {
  local extension="$1"
  local help="${2:-}"
  if code --list-extensions | grep -iq "${extension}"; then
    Log::displayInfo "VSCode extension ${help}'${extension}' already installed"
  else
    # install given extension
    if code --install-extension "${extension}" --verysilent; then
      Log::displaySuccess "VSCode extension ${help}'${extension}' successfully installed"
    else
      Log::displayError "Something went wrong while installing ${help}'${extension}' VS code extension"
    fi
  fi
}

configure() {
  if ! command -v code &>/dev/null; then
    Log::displaySkipped "You must install vscode in windows before running that script"
    return 0
  fi
  if Assert::wsl; then
    # ability to mount wsl folder inside windows visual studio code
    Retry::default installVsCodeExtension "ms-vscode-remote.remote-wsl"
    VS_CODE_SETTINGS_DIR="${USERHOME}/.vscode-server/data/Machine"
  else
    VS_CODE_SETTINGS_DIR="${USERHOME}/.config/Code/User"
  fi

  installFile "${CONF_DIR}/.vscode" "${VS_CODE_SETTINGS_DIR}" "settings.json"

  sed -i -E \
    "s/\"jenkins.pipeline.linter.connector.user\": \"[^\"]*\",/\"jenkins.pipeline.linter.connector.user\": \"${LDAP_LOGIN}\",/g" \
    "${VS_CODE_SETTINGS_DIR}/settings.json"

  EXTENSIONS="$(node "${CURRENT_DIR}/js/listVsCodeSettingsPlugins.js" \
    "${CONF_DIR}/.vscode/settings.json" \
    'extension-profiles.profiles' | tr '[:upper:]' '[:lower:]' | sort)" || {
    exitCode="$?"
    Log::displaySkipped "No extension to install found"
    exit "${exitCode}"
  }

  INSTALLED_EXTENSIONS="$(code --list-extensions | tr '[:upper:]' '[:lower:]' | sort)"
  EXTENSIONS_COUNT="$(echo "${EXTENSIONS}" | grep -c -v -e '^$')" || true

  DIFF_NOT_INSTALLED_EXTENSIONS="$(comm -13 <(echo "${INSTALLED_EXTENSIONS}") <(echo "${EXTENSIONS}"))"

  DIFF_INSTALLED_EXTENSIONS="$(comm -12 <(echo "${INSTALLED_EXTENSIONS}") <(echo "${EXTENSIONS}"))"
  DIFF_INSTALLED_EXTENSIONS_COUNT="$(echo "${DIFF_INSTALLED_EXTENSIONS}" | grep -c -v -e '^$')" || true

  Log::displayInfo "${DIFF_INSTALLED_EXTENSIONS_COUNT}/${EXTENSIONS_COUNT} Extensions already installed:"
  echo "${DIFF_INSTALLED_EXTENSIONS}" | paste -s -d, -

  EXTENSIONS_COUNT="$(echo "${DIFF_NOT_INSTALLED_EXTENSIONS}" | grep -c -v -e '^$')" || true
  if ((EXTENSIONS_COUNT > 0)); then
    Log::displayInfo "Installing ${EXTENSIONS_COUNT} VsCode extensions ..."
    ((i = 1))
    while IFS= read -r extension; do
      [[ -n "${extension}" ]] || break
      Retry::default installVsCodeExtension "${extension}" "(${i}/${EXTENSIONS_COUNT}) "
      ((i++))
    done <<<"${DIFF_NOT_INSTALLED_EXTENSIONS}"
  fi
}

testConfigure() {
  if ! command -v code &>/dev/null; then
    Log::displaySkipped "You must install vscode in windows before running that script"
    return 0
  fi
  local -i failures=0

  if Assert::wsl; then
    VS_CODE_SETTINGS_DIR="${USERHOME}/.vscode-server/data/Machine"
  else
    VS_CODE_SETTINGS_DIR="${USERHOME}/.config/Code/User"
  fi

  if [[ -f "${VS_CODE_SETTINGS_DIR}/settings.json" ]]; then
    if ! node "${CURRENT_DIR}/js/checkVsCodeSettings.js" \
      "${VS_CODE_SETTINGS_DIR}/settings.json" \
      'extension-profiles.profiles'; then
      Log::displayError "VS Code settings has not been updated correctly"
      ((++failures))
    fi
  else
    Log::displayError "File ${VS_CODE_SETTINGS_DIR}/settings.json does not exist"
    ((++failures))
  fi

  exit "${failures}"
}
