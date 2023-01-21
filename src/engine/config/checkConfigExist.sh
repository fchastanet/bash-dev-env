#!/bin/bash

envTemplate="$(
  cat <<'EOF'
  .INCLUDE "${ROOT_DIR}/.env.template"
EOF
)"

engine::config::checkConfigExist() {
  local envFile="$1"

  if [[ ! -f "${envFile}" ]]; then
    echo "${envTemplate}" >"${envFile}"
    Log::displayError "a default env file has been created, please edit ${envFile}"
    return 1
  fi
}
