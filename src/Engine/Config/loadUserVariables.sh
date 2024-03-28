#!/bin/bash

# @description deduce USER_HOME, USER_ID, USERGROUP_ID and USERGROUP from USERNAME
# @env USERNAME String the name of the user
# @set USER_ID String
# @set USERGROUP String
# @set USERGROUP_ID String
# @set USER_HOME String
Engine::Config::loadUserVariables() {
  # deduce user home and group
  # shellcheck disable=SC2153
  USER_ID="$(getent passwd "${USERNAME}" | cut -d: -f3)"
  USERGROUP_ID="$(getent passwd "${USERNAME}" | cut -d: -f4)"
  USERGROUP="$(getent group "${USERGROUP_ID}" | cut -d: -f1)"
  USER_HOME="$(getent passwd "${USERNAME}" | cut -d: -f6)"

  if [[ -z "${USERGROUP}" || -z "${USER_HOME}" ]]; then
    Log::displayError "USERNAME - unable to deduce USERGROUP, USER_HOME from USERNAME"
    return 1
  fi

  export USER_HOME
  export USER_ID
  export USERGROUP_ID
  export USERGROUP
}
