#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/_Configs/PreCommitDefaultConfig-conf" as conf_dir

helpDescription() {
  echo "Default configuration for pre-commit."
}

helpLongDescription() {
  echo "Default configuration for pre-commit."
  echo "Configure git so pre-commit will be"
  echo "automatically installed in new repositories."
}

dependencies() {
  echo "installScripts/PreCommit"
  echo "installScripts/GitDefaultConfig"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}pre-commit${__RESET_COLOR} hooks template is automatically applied on ${__HELP_EXAMPLE}git clone${__RESET_COLOR} or ${__HELP_EXAMPLE}git init${__RESET_COLOR}."
  echo "%"
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- You can disable git hooks template using ${__HELP_EXAMPLE}git config --global --unset init.templatedir${__RESET_COLOR}."
  echo "%"
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- if .pre-commit-config.yaml file is present, pre-commit will run automatically the tools specified before the commit"
  echo "%"
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- hooks source code is stored in '${ROOT_DIR}/gitHooks' directory, check ~/.gitconfig templatedir property"
  echo "%"
}

# jscpd:ignore-start
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
install() { :; }
testInstall() { :; }
isInstallImplemented() { :; }
isTestInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
# jscpd:ignore-end

configure() {
  if [[ ! -f "${HOME}/.venvs/python3/bin/activate" ]]; then
    Log::displayError "VirtualEnv has not been installed correctly"
    return 1
  fi
  # Load virtualenv
  # shellcheck source=/dev/null
  source "${HOME}/.venvs/python3/bin/activate"
  export PATH=${PATH}:${HOME}/.local/bin
  if [[ ! -d "${HOME}/.bash-dev-env/GitDefaultConfig/pre-commit-template" ]]; then
    if ! pre-commit init-templatedir -t pre-commit -t pre-push \
      "${HOME}/.bash-dev-env/GitDefaultConfig/pre-commit-template"; then
      Log::displayError "Error during precommit template creation"
      return 1
    fi
  fi
  # shellcheck disable=SC2154
  OVERWRITE_CONFIG_FILES=0 Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    "info" \
    "${HOME}/.bash-dev-env/GitDefaultConfig/pre-commit-template/info"

  if ! git config --global init.templatedir \
    "${HOME}/.bash-dev-env/GitDefaultConfig/pre-commit-template"; then
    Log::displayError "Error during git precommit template initialization"
    return 1
  fi
}

testConfigure() {
  local -i failures=0

  Assert::dirExists "${HOME}/.bash-dev-env/GitDefaultConfig/pre-commit-template" || ((++failures))

  Log::displayInfo "check if git init.templatedir correctly set"
  if [[ "$(git config --global --get init.templatedir)" != "${HOME}/.bash-dev-env/GitDefaultConfig/pre-commit-template" ]]; then
    Log::displayError "git init.templatedir has not been correctly set"
    ((++failures))
  fi

  checkGitHooksCreatedOn() {
    local callback=$1
    (
      local tempDir
      tempDir="$(mktemp -d)"
      # shellcheck disable=SC2154
      trap 'rc=$?; rm -Rf "${tempDir}" &>/dev/null || true; exit "${rc}"' EXIT INT TERM ABRT
      ${callback} "${tempDir}"
      if [[ ! -f "${tempDir}/.git/hooks/pre-commit" ]]; then
        Log::displayError "pre-commit hook has not been installed during ${callback}"
        exit 2
      fi
      if [[ ! -f "${tempDir}/.git/hooks/pre-push" ]]; then
        Log::displayError "pre-push hook has not been installed during ${callback}"
        exit 3
      fi
      if [[ ! -f "${tempDir}/.git/info/exclude" ]]; then
        Log::displayError ".git/info/exclude hook has not been installed during ${callback}"
        exit 4
      fi
    ) || return 1
  }
  Log::displayInfo "check that git init sets hooks automatically"
  # shellcheck disable=SC2317
  gitInit() { git init "$1"; }
  checkGitHooksCreatedOn gitInit || ((++failures))

  Log::displayInfo "check that git clone sets hooks automatically"
  # shellcheck disable=SC2317
  gitClone() {
    git clone https://github.com/fchastanet/repo-test.git "$1"
  }
  checkGitHooksCreatedOn gitClone || ((++failures))

  Log::displayInfo "check that committing, runs pre-commit hook"
  (
    local tempDir
    tempDir="$(mktemp -d)"
    # shellcheck disable=SC2154
    trap 'rc=$?; rm -Rf "${tempDir}" &>/dev/null || true; exit "${rc}"' EXIT INT TERM ABRT
    cd "${tempDir}"
    git init
    git checkout -b fix/1867
    # shellcheck disable=SC2154
    cp "${embed_dir_conf_dir}/.pre-commit-config-test.yaml" .pre-commit-config.yaml
    echo "test" >test.js
    echo "test" >test.php
    git add test.*
    if git commit -m 'test'; then
      Log::displayError "pre-commit should have prevent the commit"
    else
      Log::displaySuccess "pre-commit has prevented the commit with success"
      if [[ "$(cat test.js)" != "failure" ]]; then
        Log::displayError "pre-commit should have changed content of test.js"
      fi
      if [[ "$(cat test.php)" != "success" ]]; then
        Log::displayError "pre-commit should have changed content of test.php"
      fi
    fi
  ) || ((++failures))

  return "${failures}"
}
