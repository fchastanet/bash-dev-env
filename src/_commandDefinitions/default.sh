#!/bin/bash

# shellcheck disable=SC2329
optionHelpCallback() {
  "{{ .Data.binData.commands.default.functionName }}Help"
  exit 0
}

# shellcheck disable=SC2329
defaultBeforeParseCallback() {
  Env::requireLoad
  UI::requireTheme
  Log::requireLoad
  Linux::requireUbuntu
  Linux::Wsl::requireWsl
}

# shellcheck disable=SC2329
beforeParseCallback() {
  defaultBeforeParseCallback
}

# shellcheck disable=SC2329
defaultAfterParseCallback() {
  Engine::Config::loadConfig
}

# shellcheck disable=SC2329
afterParseCallback() {
  defaultAfterParseCallback
}
