#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/PlantUml
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "PlantUml"
}

helpDescription() {
  echo "PlantUml"
}

dependencies() {
  echo "Java"
}

helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

plantumlVersion() {
  java -jar /opt/java/plantuml.jar -version | head -1 | Version::parse
}

install() {
  Linux::Apt::update
  Linux::Apt::install \
    graphviz

  Log::displayInfo "install Plantuml"

  SUDO=sudo Github::upgradeRelease \
    "/opt/java/plantuml.jar" \
    "https://github.com/plantuml/plantuml/releases/download/v@latestVersion@/plantuml-@latestVersion@.jar" \
    -version \
    plantumlVersion \
    "" \
    Version::parse
}

testInstall() {
  Version::checkMinimal "plantumlVersion" -version "1.2023.10" cat || return 1
}

configure() { :; }
testConfigure() { :; }
