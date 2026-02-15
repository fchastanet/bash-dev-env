#!/bin/bash

# @description ability to test a docker container and checking provided url respond
# @arg $1 dir:String
# @arg $2 host:String
# @arg $3 containerName:String
# @arg $4 title:String
# @arg $5 testUrl:String
Docker::testContainer() {
  local dir="$1"
  local host="$2"
  local containerName="$3"
  local title="$4"
  local testUrl="$5"

  Assert::dirExists "${dir}" || ((++failures))
  Assert::etcHost "${host}" || ((++failures))

  # if it was up before launching this script, no need to launch it and do not stop it
  local containerWasUp
  containerWasUp="$(docker container inspect -f '{{"{{"}}.State.Status{{"}}"}}' "${containerName}" || true)"

  (
    cd "${dir}" || exit 1
    # shellcheck disable=SC2317,SC2329
    cleanOnExit() {
      if [[ "${containerWasUp}" != "running" ]]; then
        Log::displayInfo "Shutting down ${title} ..."
        docker-compose down
      fi
    }
    trap cleanOnExit EXIT INT ABRT TERM
    if [[ "${containerWasUp}" != "running" ]]; then
      Log::displayInfo "Launching ${title} ..."
      docker-compose up -d --build
    fi
    Retry::parameterized 40 5 "Try to contact ${title} ..." curl \
      --silent -o /dev/null --fail -L \
      --connect-timeout 5 --max-time 10 "${testUrl}" || {
      docker-compose logs "${containerName}"
      Log::displayError "${title} initialization has failed, check above logs"
      exit 1
    }
    Log::displaySuccess "${title} tested successfully"
  )
}
