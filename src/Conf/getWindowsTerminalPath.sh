#!/usr/bin/env bash

# @description Get the path to the windows terminal
# @noargs
# @stdout The path to the windows terminal
Conf::getWindowsTerminalPath() {
  # cspell:ignore wekyb, bbwe
  echo "${WINDOWS_PROFILE_DIR}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe"
}
