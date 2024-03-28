#!/bin/bash

# @description check Conf::installFromEmbed result
# @arg $@ list of files to install
# @exitcode 1 if embedded file not found
Conf::installFromEmbedCheck() {
  local -a files=("$@")
  local -i failures=0
  for file in "${files[@]}"; do
    Assert::fileExists "${USER_HOME}/.${file}" "${USERNAME}" "${USERGROUP}" || {
      ((++failures))
    }
  done
  return "${failures}"
}
