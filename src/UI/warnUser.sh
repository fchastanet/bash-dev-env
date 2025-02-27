#!/usr/bin/env bash

# @description Warn the user that the script is about to ask for input
UI::warnUser() {
  # @embed "${FRAMEWORK_ROOT_DIR}/src/UI/talk.ps1" as talkScript
  # shellcheck disable=SC2154
  cp "${embed_file_talkScript}" "${embed_file_talkScript}.ps1"
  UI::talkToUser "Please on Bash Dev env installation, your input may be required" \
    "${embed_file_talkScript}.ps1"
}
