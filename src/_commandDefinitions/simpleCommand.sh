#!/bin/bash

# shellcheck disable=SC2329
optionHelpCallback() {
  "{{ .Data.binData.commands.default.functionName }}Help"
  exit 0
}

copyrightCallback() {
  #{{- $copyrightBeginYear := .RootData.binData.commands.default.copyrightBeginYear | default "$(date +%Y)" }}
  # shellcheck disable=SC2155,SC2154,SC2250
  echo "Copyright (c) {{ $copyrightBeginYear }}-now Francois Chastanet"
}

Env::requireLoad() {
  export REQUIRE_FUNCTION_ENV_REQUIRE_LOAD_LOADED=1
}

UI::requireTheme() {
  export REQUIRE_FUNCTION_UI_REQUIRE_THEME_LOADED=1
}

Log::requireLoad() {
  export REQUIRE_FUNCTION_LOG_REQUIRE_LOAD_LOADED=1
}

# shellcheck disable=SC2329
defaultBeforeParseCallback() {
  Env::requireLoad
  UI::requireTheme
  Log::requireLoad
}

# shellcheck disable=SC2329
beforeParseCallback() {
  defaultBeforeParseCallback
}

# shellcheck disable=SC2329
defaultAfterParseCallback() {
  :
}

# shellcheck disable=SC2329
afterParseCallback() {
  defaultAfterParseCallback
}

# shellcheck disable=SC2317 # if function is overridden
optionVersionCallback() {
  # shellcheck disable=SC2154
  echo "${SCRIPT_NAME} version {{ .RootData.binData.commands.default.version }}"
  exit 0
}
