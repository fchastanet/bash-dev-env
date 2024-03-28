#!/usr/bin/env bash

# @description load /etc/os-release file
# @set NAME
# @set VERSION
# @set ID
# @set ID_LIKE
# @set PRETTY_NAME
# @set VERSION_ID
# @set HOME_URL
# @set SUPPORT_URL
# @set BUG_REPORT_URL
# @set PRIVACY_POLICY_URL
# @set VERSION_CODENAME
# @set UBUNTU_CODENAME
Engine::Config::loadOsRelease() {
  if [[ ! -f /etc/os-release ]]; then
    Log::displayError "file /etc/os-release does not exists"
    return 1
  fi
  # This will load environment variables ID, VERSION_CODENAME, ...
  set -o allexport
  source /etc/os-release
  set +o allexport
}
