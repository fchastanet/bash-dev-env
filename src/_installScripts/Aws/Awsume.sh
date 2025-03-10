#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/Aws/Awsume-conf" as conf_dir

helpDescription() {
  echo "With awsume, you can easily switch between different AWS roles and accounts."
}

helpLongDescription() {
  helpDescription
  echo "Awsume is a convenient way to manage session tokens and assume role credentials"
  echo "It is a command-line utility for retrieving and exporting AWS credentials"
  echo "to your shell's environment."
}

dependencies() {
  echo "installScripts/Python"
}

# shellcheck disable=SC2317
listVariables() {
  echo "HOME"
  echo "USERNAME"
  echo "USERGROUP"
  echo "AWS_DEFAULT_REGION"
}

fortunes() {
  if command -v awsume &>/dev/null; then
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- command ${__HELP_EXAMPLE}awsume${__RESET_COLOR} is a convenient"
    echo "way to manage session tokens and assume role credentials (see https://awsu.me/)"
    echo "%"
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- command ${__HELP_EXAMPLE}awsume -c profileName${__RESET_COLOR}"
    echo "will open aws console in your browser using sso link (see https://github.com/trek10inc/awsume-console-plugin)"
    echo "%"
  else
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- command ${__HELP_EXAMPLE}awsume${__RESET_COLOR} is not installed, you can install it using ${__HELP_EXAMPLE}installAndConfigure Awsume${__RESET_COLOR}"
    echo "%"
  fi
}

# jscpd:ignore-start
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  # shellcheck source=/dev/null
  source "${HOME}/.venvs/python3/bin/activate" || return 1
  AWSUME_SKIP_ALIAS_SETUP=true pipx install awsume
  pipx inject awsume awsume-console-plugin
}

testInstall() {
  # shellcheck source=/dev/null
  source "${HOME}/.venvs/python3/bin/activate" || return 1

  Version::checkMinimal "awsume" -v "4.5.4" || return 1
}

configure() {
  local configDir
  # shellcheck disable=SC2154
  configDir="$(Conf::getOverriddenDir "${embed_dir_conf_dir}" "$(fullScriptOverrideDir)")"
  # install default configuration
  # shellcheck disable=SC2317
  configureAwsumeConfig() {
    local targetFile="$2"
    sed -i -E \
      -e "s#region: .+\$#region: ${AWS_DEFAULT_REGION}#" \
      "${targetFile}"
    Install::setUserRightsCallback "$@"
  }
  OVERWRITE_CONFIG_FILES=0 Install::file \
    "${configDir}/.config/awsume/config.yaml" \
    "${HOME}/.config/awsume/config.yaml" \
    "${USERNAME}" "${USERGROUP}" configureAwsumeConfig

  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "$(fullScriptOverrideDir)" \
    ".bash-dev-env"
}
testConfigure() {
  local -i failures=0

  # shellcheck source=/dev/null
  source "${HOME}/.venvs/python3/bin/activate" || return 1

  Assert::fileExists "${HOME}/.config/awsume/config.yaml" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/awsume.sh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/profile.d/awsume.bash" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/profile.d/awsume.zsh" || ((++failures))

  return "${failures}"
}
