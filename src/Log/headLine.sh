#!/usr/bin/env bash

# @description Display given text on full line with TEST_COLOR style
# @arg $1 text:String text to display
Log::headLine() {
  local text="$1"
  local message
  message="$(UI::textLine "${text}" " ")"
  echo -e "${__TEST_COLOR}${message}${__RESET_COLOR}"
}
