#!/bin/bash

# @description if .env does not exist, initialize it with .env.template
Engine::Config::createEnvFileFromTemplate() {
  local envFile="$1"
  local envFileTemplate="$2"

  if [[ ! -f "${envFile}" ]]; then
    echo "${envFileTemplate}" >"${envFile}"
    Log::displayError "a default env file has been created, please edit ${envFile}"
    return 1
  fi
}
