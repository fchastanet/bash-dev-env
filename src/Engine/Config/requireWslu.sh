#!/bin/bash

# @description install apt wslu if necessary providing wslvar, wslpath
Engine::Config::requireWslu() {
  if [[ "${LOAD_WSLU:-1}" = "0" ]]; then
    return 0
  fi
  if ! command -v wslvar &>/dev/null; then
    Log::displayInfo "Installing pre-requisite Wslu : wslvar, wslpath, ... commands"
    Linux::Apt::installIfNecessary --no-install-recommends wslu

    # Fix WSL2 interop issue
    # @see https://github.com/microsoft/WSL/issues/7181
    sudo systemctl mask systemd-binfmt.service
    sudo update-binfmts --enable
  fi
}
