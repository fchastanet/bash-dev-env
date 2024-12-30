#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/Python/Python-conf" as conf_dir

helpDescription() {
  echo "$(scriptName) - installs python and configure venv"
}

helpLongDescription() {
  helpDescription
  echo "Python is a programming language that lets you work quickly and integrate systems more effectively."
  echo "The venv module supports creating lightweight 'virtual environments', each with their own independent set of Python packages installed in their site directories."
  echo "venv tutorial : https://python.land/virtual-environments/virtualenv"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}venv${__RESET_COLOR} is automatically loaded by ${__HELP_EXAMPLE}~/.bash-dev-env/profile.d/python.sh${__RESET_COLOR}."
  echo "You can activate this virtual env using the command 'source ${HOME}/.venvs/python3/bin/activate'"
  echo "venv tutorial : https://python.land/virtual-environments/virtualenv"
  echo "%"
}

# jscpd:ignore-start
dependencies() { :; }
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

isSupportedUbuntuVersion() {
  local versionCompare=0
  Version::compare "${VERSION_ID}" "24.04" || versionCompare=$?
  if [[ "${versionCompare}" = "2" ]]; then
    Log::displaySkipped "Unsupported ubuntu version (please install ubuntu version 24.04 minimum)"
    return 1
  fi
}

install() {
  isSupportedUbuntuVersion || return 0

  installFromUbuntu24
}

installFromUbuntu24() {
  local -a packages=(
    build-essential
    python3
    python-is-python3
    python3-pip
    python3-venv
  )
  Linux::Apt::installIfNecessary --no-install-recommends "${packages[@]}"

  mkdir -p \
    "${HOME}/.local/bin" \
    "${HOME}/.local/lib"

  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"

  # Upgrade of pip packages will be done on subsequent calls during upgrade cron
  upgradePipPackages
}

upgradePipPackages() {
  if [[ "${PIP_PACKAGES_UPGRADED:-0}" = "1" ]]; then
    return 0
  fi
  if [[ -f "${HOME}/.venvs/python3/bin/activate" ]]; then
    # load this virtualenv
    # shellcheck source=/dev/null
    source "${HOME}/.venvs/python3/bin/activate"

    Log::displayInfo "Removing duplicate pip packages with ~ prefix that breaks pip packages upgrade otherwise"
    local pythonUserSite
    pythonUserSite="$(python -m site --user-site)"
    if [[ -d "${pythonUserSite}" ]]; then
      find "${pythonUserSite}" -name '~*' -exec rm -Rf {} ';' || true
    fi

    Log::displayInfo "Installing pipx"
    python -m pip install pipx
    pipx ensurepath

    Log::displayInfo "Upgrading virtualenv dependencies"
    python -m venv --upgrade-deps "${HOME}/.venvs/python3"

    Log::displayInfo "Upgrading pip"
    python -m pip install --upgrade pip

    if [[ -n "$(pip freeze)" ]]; then
      Log::displayInfo "Upgrading virtualenv pip packages"
      pip freeze | awk '{print $1}' | xargs -n1 pip install --upgrade
    fi

    if [[ -n "$(pip freeze --user)" ]]; then
      Log::displayInfo "Upgrading virtualenv pip user packages"
      pip freeze --user | awk '{print $1}' | xargs -n1 pip install --upgrade
    fi
    PIP_PACKAGES_UPGRADED=1
  fi
}

testInstall() {
  isSupportedUbuntuVersion || return 0

  local -i failures=0
  Version::checkMinimal "python" "--version" "3.12.3" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/profile.d/python.sh" || ((++failures))
  return "${failures}"
}

configure() {
  isSupportedUbuntuVersion || return 0

  Log::displayInfo "Creating home directory that will receive venvs configs"
  mkdir -p "${HOME}/.venvs" || true
  mkdir -p "${HOME}/.pip/cache" || true

  Log::displayInfo "Creating python3 virtual env if needed"
  python -m venv --system-site-packages --upgrade-deps "${HOME}/.venvs/python3"

  upgradePipPackages
}

testConfigure() {
  isSupportedUbuntuVersion || return 0

  local -i failures=0
  # shellcheck source=/dev/null
  source "${HOME}/.venvs/python3/bin/activate" || ((++failures))
  Version::checkMinimal "python" "--version" "3.12.3" || ((++failures))
  Version::checkMinimal "pip" "--version" "24.0" || ((++failures))
  [[ "${VIRTUAL_ENV}" = "${HOME}/.venvs/python3" ]] || {
    Log::displayError "Virtualenv has not been loaded correctly"
    ((++failures))
  }
  return "${failures}"
}

cleanBeforeExport() {
  rm -Rf "${HOME}/.cache/pip" || true
}

testCleanBeforeExport() {
  ((failures = 0)) || true
  Assert::dirNotExists "${HOME}/.cache/pip" || ((++failures))
  return "${failures}"
}
