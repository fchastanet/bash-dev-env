#!/usr/bin/env bash

engine::config::loadOsRelease() {
  if [[ ! -f /etc/os-release ]]; then
    Log::displayError "file /etc/os-release does not exists"
    return 1
  fi
  # This will load environment variables ID, VERSION_CODENAME
  source /etc/os-release
  export NAME
  export VERSION
  export ID
  export ID_LIKE
  export PRETTY_NAME
  export VERSION_ID
  export HOME_URL
  export SUPPORT_URL
  export BUG_REPORT_URL
  export PRIVACY_POLICY_URL
  export VERSION_CODENAME
  export UBUNTU_CODENAME
}
