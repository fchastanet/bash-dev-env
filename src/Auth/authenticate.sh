#!/usr/bin/env bash

# @description Authenticate the user
# @noargs
# @exitcode 0 If successful
# @exitcode 1 If failed
Auth::authenticate() {
  # @embed "${FRAMEWORK_ROOT_DIR}/src/UI/talk.ps1" as talkScript
  # shellcheck disable=SC2154
  cp "${embed_file_talkScript}" "${embed_file_talkScript}.ps1"
  UI::talkToUser "Please on Bash Dev env installation, your input may be required" \
    "${embed_file_talkScript}.ps1"
  # try to login
  if ! Retry::parameterized 3 0 \
    "AWS Authentication, please provide your credentials ..." \
    saml2aws login -p "${AWS_PROFILE}" --disable-keychain; then
    Log::displayError "Failed to connect to aws"
    return 1
  fi
  Log::displaySuccess "Aws connection succeeds"
}
