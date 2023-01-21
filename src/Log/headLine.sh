#!/usr/bin/env bash

Log::headLine() {
  local type="$1"
  local message
  message="$(UI::textLine "${type}" " ")"
  echo -e "${__TEST_COLOR}${message}${__RESET_COLOR}"
}
