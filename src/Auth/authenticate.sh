#!/usr/bin/env bash

# @description Authenticate the user
# @noargs
# @exitcode 0 If successful
# @exitcode 1 If failed
Auth::authenticate() {
  UI::warnUser
  # try to login
  if [[ "${USE_AWS_CONFIGURE_SSO:-1}" = "1" ]]; then
    Log::displayInfo "Trying to connect to aws"
    if ! Retry::parameterized 3 0 \
      "AWS Authentication, please provide your credentials ..." \
      aws configure sso; then
      Log::displayError "Failed to connect to aws"
      return 1
    fi
    Log::displaySuccess "Aws connection succeeds"
  else
    if ! Retry::parameterized 3 0 \
      "AWS Authentication, please provide your credentials ..." \
      saml2aws login -p "${AWS_PROFILE}" --disable-keychain; then
      Log::displayError "Failed to connect to aws"
      return 1
    fi
    Log::displaySuccess "Aws connection succeeds"
  fi
}
