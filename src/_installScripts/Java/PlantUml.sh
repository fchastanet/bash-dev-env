#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/Java/PlantUml-conf" as conf_dir

plantUmlBeforeParseCallback() {
  Linux::requireJqCommand
}

helpDescription() {
  echo "PlantUml"
}

dependencies() {
  echo "installScripts/JavaSdkManager"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- run alias ${__HELP_EXAMPLE}plantumlServerStart${__RESET_COLOR} or ${__HELP_EXAMPLE}nohup java -jar /opt/java/plantuml.jar -picoweb &${__RESET_COLOR}"
  echo -e "can be used as plantuml local web server for Vscode plantuml plugin to generate plantuml diagrams."
  echo "%"
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- /opt/java/plantuml.jar now integrates elk and smetana layout engines"
  echo -e "Set ${__HELP_EXAMPLE}!pragma layout elk${__RESET_COLOR} in your puml file to render using elk layout"
  echo -e "Set ${__HELP_EXAMPLE}!pragma layout smetana${__RESET_COLOR} in your puml file to render using smetana layout"
  echo "%"
}

# jscpd:ignore-start
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
configure() { :; }
testConfigure() { :; }
# jscpd:ignore-end

plantumlVersionCallback() {
  # shellcheck source=/dev/null
  source "${HOME}/.sdkman/bin/sdkman-init.sh"
  java -jar /opt/java/plantuml.jar -version | head -1 | Version::parse
}

install() {
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "$(fullScriptOverrideDir)" \
    ".bash-dev-env"

  Linux::Apt::installIfNecessary --no-install-recommends \
    graphviz

  Log::displayInfo "install Plantuml"

  SUDO=sudo SOFT_VERSION_CALLBACK=plantumlVersionCallback Github::upgradeRelease \
    "/opt/java/plantuml.jar" \
    "https://github.com/plantuml/plantuml/releases/download/v@latestVersion@/plantuml-@latestVersion@.jar"
}

testInstall() {
  # ensure java binary is available
  # shellcheck source=/dev/null
  source "${HOME}/.sdkman/bin/sdkman-init.sh"
  Version::checkMinimal "plantumlVersionCallback" -version "1.2024.8" cat || return 1
  Assert::fileExists "/opt/java/plantuml.jar" || return 1
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/plantuml.sh" || return 1
}
