%
# shellcheck source=/dev/null
source <(
  profileHelp() { :; }
  Options::generateOption \
    --help profileHelp \
    --help-value-name profile \
    --variable-type "String" \
    --alt "--profile" \
    --alt "-p" \
    --callback validateProfile \
    --variable-name "PROFILE" \
    --function-name optionProfileFunction

  softwareArgHelp() { :; }
  Options::generateArg \
    --variable-name "CONFIG_LIST" \
    --min 0 \
    --max -1 \
    --name "softwares" \
    --help softwareArgHelp \
    --function-name softwaresArgFunction
)
options+=(
  optionProfileFunction
  softwaresArgFunction
  --callback commandCallback
)
%

profileHelp() {
  echo "Profile name to use that contains all the softwares to install"
  echo "List of profiles available:"
  echo
  Conf::list "${BASH_DEV_ENV_ROOT_DIR}/profiles" "" ".sh" "-type f" "   - "  | sort | uniq
}

softwareArgHelp() {
  echo "List of softwares to install (--profile option cannot be used in this case)"
  echo "List of softwares available:"
  Conf::list "${BASH_DEV_ENV_ROOT_DIR}/installScripts" "" "" "-type f" "" |
    grep -v -E '^(_.*|MandatorySoftwares)$' | paste -s -d ',' | sed -e 's/,/, /g' || true

}

validateProfile() {
  if [[ ! -f "${BASH_DEV_ENV_ROOT_DIR}/profiles/profile.$2.sh" ]]; then
    Log::fatal "Profile file ${BASH_DEV_ENV_ROOT_DIR}/profile.$2.sh doesn't exist"
  fi
}

commandCallback() {
  if ((${#CONFIG_LIST} > 0)); then
    if [[ -n "${PROFILE}" ]]; then
      Log::fatal "You cannot combine profile and softwares"
    fi
    # check if each Softwares exists
    local software
    for software in "${CONFIG_LIST[@]}"; do
      if [[ ! -f "${BASH_DEV_ENV_ROOT_DIR}/installScripts/${software}" ]]; then
        Log::fatal "Software installScripts/${software} configuration does not exists"
      fi
    done
  elif [[ -z "${PROFILE}" ]]; then
    Log::fatal "You must specify either a list of softwares, either a profile name"
  else
    # load selected profile
    mapfile -t CONFIG_LIST < <(
      IFS=$'\n' Profiles::loadProfile "${BASH_DEV_ENV_ROOT_DIR}/profiles" "${PROFILE}"
    )
  fi
  if [[ "${SKIP_DEPENDENCIES}" = "0" ]]; then
    CONFIG_LIST=("${CONFIG_LIST[@]}")

    declare rootDependency="your software selection"
    if [[ -n "${PROFILE}" ]]; then
      rootDependency="profile ${PROFILE}"
    fi
    # deduce dependencies
    declare -ag allDepsResult=()
    # shellcheck disable=SC2034
    declare -Ag allDepsResultSeen=()

    Profiles::allDepsRecursive \
      "${INSTALL_SCRIPTS_DIR}" "${rootDependency}" "${CONFIG_LIST[@]}"

    CONFIG_LIST=("${allDepsResult[@]}")
  fi
  if ((${#CONFIG_LIST} == 0)); then
    Log::fatal "Softwares list is empty"
  fi
}

export CONFIG_LIST
export PROFILE
