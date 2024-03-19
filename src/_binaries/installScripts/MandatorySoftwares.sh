#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/MandatorySoftwares
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "MandatorySoftwares"
}

helpDescription() {
  echo "MandatorySoftwares"
}

helpVariables() {
  true
}

listVariables() {
  true
}

defaultVariables() {
  true
}

checkVariables() {
  true
}

fortunes() {
  return 0
}

dependencies() {
  return 0
}

breakOnConfigFailure() {
  return 1
}

breakOnTestFailure() {
  return 1
}

install() {
  return 0
}

configure() {
  return 0
}

testInstall() {
  return 0
}

testConfigure() {
  return 0
}