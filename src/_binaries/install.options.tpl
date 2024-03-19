%
declare versionNumber="1.0"
declare copyrightBeginYear="2024"
declare commandFunctionName="installCommand"
declare help="Install or update softwares"
declare longDescription="""
Install or update softwares (kube, aws, composer, node, ...),
configure Home environnement (git config, kube, motd, ssh, dns, ...) and check configuration
"""
%

.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
.INCLUDE "$(dynamicTemplateDir _includes/install.default.options.tpl)"

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
Options::generateCommand "${options[@]}"
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
  else
    if [[ -z "${PROFILE}" ]]; then
      Log::fatal "You must specify either a list of softwares, either a profile name"
    fi
    if [[ "${SKIP_DEPENDENCIES}" = "0" ]]; then
      CONFIG_LIST=("${CONFIG_LIST[@]}")
      if [[ "${PREPARE_EXPORT}" = "1" ]]; then
        CONFIG_LIST+=("_Export")
      fi

      declare rootDependency="your software selection"
      if [[ -n "${PROFILE}" ]]; then
        rootDependency="profile ${PROFILE}"
      fi
      # deduce dependencies
      declare -ag allDepsResult=()
      # shellcheck disable=SC2034
      declare -Ag allDepsResultSeen=()

      Profiles::allDepsRecursive \
        "${SRC_DIR}/installScripts" "${rootDependency}" "${CONFIG_LIST[@]}"

      CONFIG_LIST=("${allDepsResult[@]}")
    fi
  fi
}

<% ${commandFunctionName} %> parse "${BASH_FRAMEWORK_ARGV[@]}"

export CONFIG_LIST
export PROFILE