#!/bin/bash

generateSoftwaresList() {
  local directory="$1"
  local relativeDir="$2"
  local description list softName

  list="$(
    Conf::list "${directory}" "" "" "-type f" "" |
      grep -v -E '^(_.*|MandatorySoftwares)$' || true
  )"
  local -i maxLineLength
  maxLineLength="$(wc -L <<<"${list}")"
  ((maxLineLength += 1 + ${#relativeDir}))
  while read -r soft; do
    softName="${soft}"
    description="$(SKIP_REQUIRES=1 "${directory}/${soft}" helpDescription 2>/dev/null)"
    if [[ -z "${description}" ]]; then
      description="<No description available>"
    fi
    description="$(printf -- '_%.0s' $(seq "$((maxLineLength - ${#softName} - 1 - ${#relativeDir} + 1))")) ${description}"
    description="  - ${__HELP_TITLE_COLOR}${relativeDir}/${softName} ${__HELP_EXAMPLE}${description}${__RESET_COLOR}"
    echo -e " ${description}" | sed '2,$s/^/      /'
  done <<<"${list}"
}

softwaresListCacheFile() {
  local relativeDir="$1"
  directoryName="$(sed -E 's#/#_#g' <<<"${relativeDir}")"
  echo "${WSL_TMPDIR:-${PERSISTENT_TMPDIR:-/tmp}}/bash_dev_env_${directoryName}_arg_help_cache"
}

generateSoftwaresListCache() {
  local directory="$1"
  local relativeDir="$2"
  local softwaresListHelpTempFile="$3"

  if [[ ! -f "${softwaresListHelpTempFile}" ]] ||
    (($(File::elapsedTimeSinceLastModification "${softwaresListHelpTempFile}") > help_cache_max_duration)); then
    echo >&2 -n "Generating softwares list cache (directory ${relativeDir}) ..."
    generateSoftwaresList "${directory}" "${relativeDir}" >"${softwaresListHelpTempFile}" || rm -f "${softwaresListHelpTempFile}"
    echo >&2 -e "\033[2K" # erase line (Generating softwares list cache ...)
  fi
}

displayAvailableSoftwares() {
  local directory="$1"

  local relativeDir
  relativeDir="$(File::relativeToDir "${directory}" "${BASH_DEV_ENV_ROOT_DIR}")"
  local softwaresListHelpTempFile
  softwaresListHelpTempFile="$(softwaresListCacheFile "${relativeDir}")"
  generateSoftwaresListCache "${directory}" "${relativeDir}" "${softwaresListHelpTempFile}"
  echo -e "  ${__HELP_TITLE_COLOR}Available Softwares (directory ${relativeDir}):${__RESET_COLOR}"
  cat "${softwaresListHelpTempFile}"
}

declare -i help_cache_max_duration=86400
