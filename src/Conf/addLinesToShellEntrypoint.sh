#!/bin/bash

# @description depending shell proposes to
# add following lines to shell entrypoint script
# @env SHELL String the shell type (bash, zsh, other)
Conf::addLinesToShellEntrypoint() {
  local currentShell
  currentShell="$(readlink /proc/$$/exe)"
  if [[ "${currentShell}" = "/usr/bin/bash" ]]; then
    Log::displayInfo "Please add these lines at the end of your ~/.bashrc"
  elif [[ "${currentShell}" = "/usr/bin/zsh" ]]; then
    Log::displayInfo "Please add these lines at the end of your ~/.zshrc"
  else
    Log::displayInfo "Please add these lines at the end of your shell entrypoint (${SHELL})"
  fi
}
