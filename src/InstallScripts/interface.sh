#!/bin/bash

# @description List the functions needed to implement an install script
# @stdout one function name by line
InstallScripts::interface() {
  echo scriptName
  echo helpDescription
  echo helpVariables
  echo listVariables
  echo defaultVariables
  echo checkVariables
  echo fortunes
  echo dependencies
  echo breakOnConfigFailure
  echo breakOnTestFailure
  echo install
  echo configure
  echo testInstall
  echo testConfigure
}
