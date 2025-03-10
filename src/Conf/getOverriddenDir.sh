#!/bin/bash

# @description generate temp directory where default
# and overridden directories have been merged
#   - if overridden dir exists, create a new temp folder
#     - copy all files from default folder
#     - overwrite with files from overridden folder
#     - (Later) delete files listed in .remove$$ file
#     - return the path of this temp folder
#   - else just return the default folder path
# Then it is easier to pick overridden or default files/folders
#
# @arg $1 defaultDir:String usually the embed directory
# @arg $2 overriddenDirPath:String the path to the directory
#   that could be overridden
# @exitcode 1 if default dir does not exist
# @exitcode 2 if error during copy
Conf::getOverriddenDir() {
  local -a overriddenDirPaths=("$@")
  local overriddenDirPath

  local tempDir
  tempDir="$(mktemp -d)"
  (
    shopt -s dotglob
    for overriddenDirPath in "${overriddenDirPaths[@]}"; do
      if [[ -d "${overriddenDirPath}" && -n "$(ls -A "${overriddenDirPath}" || true)" ]]; then
        Log::displayInfo "Conf::getOverriddenDir - use overridden files from ${overriddenDirPath}"
        cp -R "${overriddenDirPath}/." "${tempDir}"
      else
        if [[ -z "${overriddenDirPath}" ]]; then
          Log::displayError "Conf::getOverriddenDir - empty overridden directory path"
        else
          Log::displayInfo "Conf::getOverriddenDir - directory ${overriddenDirPath} does not exist or is empty"
        fi
      fi
    done
  ) || {
    Log::displayError "Conf::getOverriddenDir - error during copy"
    return 2
  }
  echo "${tempDir}"
}
