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
# jscpd:ignore-end

install() {
  if ! command -v code &>/dev/null; then
    Log::displaySkipped "You must install vscode in windows before running that script"
    return 0
  fi
  # vscode is preinstalled
  Log::displayInfo "Make vscode download vscode server"
  code --help >/dev/null
}

testInstall() {
  if ! command -v code &>/dev/null; then
    Log::displaySkipped "You must install vscode in windows before running that script"
    return 0
  fi
  Assert::commandExists code
}

installVsCodeExtension() {
  local extensions=("$@")
  local -i batchSize=10
  local -i total=${#extensions[@]}
  local -i i=0

  while (( i < total )); do
    local batch=("${extensions[@]:${i}:${batchSize}}")
    local -a cmd=(code)
    for extension in "${batch[@]}"; do
      cmd+=(--install-extension "${extension}")
    done
    Log::displayInfo "Installing VSCode extensions: ${batch[*]} (batch ${i}-$((i + batchSize)) of ${total})"
    if Retry::default "${cmd[@]}"; then
      Log::displaySuccess "VSCode extensions '${extension}' successfully installed"
    else
      Log::displayError "Something went wrong while installing '${extension}' VS code extension"
    fi
    ((i += batchSize))
  done
}

configure() {
  if ! command -v code &>/dev/null; then
    Log::displaySkipped "You must install vscode in windows before running that script"
    return 0
  fi
  local installedExtensions
  installedExtensions="$(code --list-extensions | tr '[:upper:]' '[:lower:]' | sort)"

  local extensions extensionsCount
  # shellcheck disable=SC2154
  extensions="$(awk \
    '!/^#/{for(i=1;i<=NF;i++)if($i!="")names[$i]++}END{for(n in names)print n}' \
    "${embed_dir_conf_dir}/vscode-extensions-by-profile"/*.md | \
    tr '[:upper:]' '[:lower:]' | \
    sort \
  )"
  extensionsCount="$(echo "${extensions}" | grep -c -v -e '^$')" || true

  local diffInstalledExtensions diffInstalledExtensionsCount
  diffInstalledExtensions="$(comm -12 <(echo "${installedExtensions}") <(echo "${extensions}"))"
  diffInstalledExtensionsCount="$(echo "${diffInstalledExtensions}" | grep -c -v -e '^$')" || true
  if (( diffInstalledExtensionsCount > 0 )); then
    Log::displayInfo "${diffInstalledExtensionsCount}/${extensionsCount} extensions already installed:"
    echo "${diffInstalledExtensions}" | paste -s -d, -
  fi

  # Get extensions to install
  local -a toInstallArray
  mapfile -t toInstallArray < <(
    comm -13 <(echo "${installedExtensions}") <(echo "${extensions}")
  )
  installVsCodeExtension "${toInstallArray[@]}"

  local vsCodeSettingsDir
  if Assert::wsl; then
    # ability to mount wsl folder inside windows visual studio code
    Retry::default installVsCodeExtension "ms-vscode-remote.remote-wsl"
    vsCodeSettingsDir="${HOME}/.vscode-server/data/Machine"
  else
    vsCodeSettingsDir="${HOME}/.config/Code/User"
  fi

  BACKUP_BEFORE_INSTALL=1 Install::file \
    "${embed_dir_conf_dir}/keybindings.json" "${vsCodeSettingsDir}/keybindings.json"
  BACKUP_BEFORE_INSTALL=1 Install::file \
    "${embed_dir_conf_dir}/settings.json" "${vsCodeSettingsDir}/settings.json"

  sed -i -E \
    "s/\"jenkins.pipeline.linter.connector.user\": \"[^\"]*\",/\"jenkins.pipeline.linter.connector.user\": \"${LDAP_LOGIN}\",/g" \
    "${vsCodeSettingsDir}/settings.json"
}

testConfigure() {
  if ! command -v code &>/dev/null; then
    Log::displaySkipped "You must install vscode in windows before running that script"
    return 0
  fi
  local -i failures=0

  local vsCodeSettingsDir
  if Assert::wsl; then
    vsCodeSettingsDir="${HOME}/.vscode-server/data/Machine"
  else
    vsCodeSettingsDir="${HOME}/.config/Code/User"
  fi
  Assert::fileExists "${vsCodeSettingsDir}/keybindings.json" || ((++failures))
  Assert::fileExists "${vsCodeSettingsDir}/settings.json" || ((++failures))

  exit "${failures}"
}
