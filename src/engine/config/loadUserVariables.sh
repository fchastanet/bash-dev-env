#!/bin/bash

engine::config::loadUserVariables() {
  # deduce user home and group
  # shellcheck disable=SC2153
  USER_HOME="$(getent passwd "${USER_NAME}" | cut -d: -f6)"
  USER_ID="$(getent passwd "${USER_NAME}" | cut -d: -f3)"
  USER_GROUP_ID="$(getent passwd "${USER_NAME}" | cut -d: -f4)"
  USER_GROUP="$(getent group "${USER_GROUP_ID}" | cut -d: -f1)"

  if [[ -z "${USER_GROUP}" || -z "${USER_HOME}" ]]; then
    Log::displayError "USER_NAME - unable to deduce USER_GROUP, USER_HOME from USER_NAME"
    return 1
  fi

  export USER_HOME
  export USER_ID
  export USER_GROUP_ID
  export USER_GROUP
}
