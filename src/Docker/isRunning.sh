#!/usr/bin/env bash

# @description check if docker is running
# @exitcode 0 if docker is running
Docker::isRunning() {
  if ! command -v docker &>/dev/null; then
    Log::displayError "Docker is not installed"
    return 1
  fi
  dockerIsStarted() {
    local dockerPs
    dockerPs="$(docker ps 2>&1 || true)"
    [[ ! "${dockerPs}" =~ "Cannot connect to the Docker daemon" ]]
  }
  Log::displayInfo "Checking if docker is started ..."
  if dockerIsStarted; then
    Log::displaySuccess "Docker connection success"
  else
    Log::displayError "Docker is not started"
    return 1
  fi
}
