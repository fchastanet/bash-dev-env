#!/usr/bin/env bash

# @description Assert that a command version is greater than or equal to a minimal version
#
# @arg $1 command name
# @arg $2 command version
# @arg $3 minimal version
#
# @exitcode 0 if version is greater than or equal to minimal version, 1 if not
# @exitcode 2 if version is not valid
Assert::minimalVersion() {
  local commandName="$1"
  local version="$2"
  local minimalVersion="$3"

  Version::compare "${version}" "${minimalVersion}" || result=$?
  case "${result}" in
    1)
      Log::displayInfo "${commandName} version is ${version} greater than ${minimalVersion}"
      ;;
    2)
      Log::displayError "${commandName} minimal version is ${minimalVersion}, your version is ${version}"
      return 1
      ;;
    *)
      Log::displaySuccess "${commandName} version is matching exactly the expected minimal version ${version}"
      ;;
  esac
}
