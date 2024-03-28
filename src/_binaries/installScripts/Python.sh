#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Python
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/Python/etc/profile.d/python_path.sh" as python_path

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Python"
}

helpDescription() {
  echo "Python"
}

fortunes() { 
  fortunes+=("Python - virtualenv is automatically loaded by ~/.bash-dev-env")
}
dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  Linux::Apt::addRepository ppa:deadsnakes/ppa
  local -a packages=(
    build-essential
    # libdbus-glib-1-dev needed by dbus-python
    libdbus-glib-1-dev
    # libgirepository1.0-dev needed by dbus-python
    libgirepository1.0-dev
    # libcairo2-dev needed by PyGObject
    libcairo2-dev
    # libkrb5-dev needed by pykerberos
    libkrb5-dev
    python3.9
    # needed by some pip dependencies
    python3-cairo-dev
    python3-dbus
    python3.9-distutils
    python3.9-dev
    python-is-python3
    python3-pip
  )
  Linux::Apt::install "${packages[@]}"

  mkdir -p \
    "${USER_HOME}/.local/bin" \
    "${USER_HOME}/.local/lib"
  
  # Installing virtualenv
  PIP_REQUIRE_VIRTUALENV=false python -m pip install virtualenv

  # Configure bin path
  Log::displayInfo "Install /etc/profile.d/python_path.sh"
  local fileToInstall
  # shellcheck disable=SC2154
  fileToInstall="$(Conf::dynamicConfFile "etc/profile.d/python_path.sh" "${embed_file_python_path}")" || return 1
  SUDO=sudo OVERWRITE_CONFIG_FILES=1 BACKUP_BEFORE_INSTALL=0 Install::file \
    "${fileToInstall}" "/etc/profile.d/python_path.sh" \
    "root" "root" \
    Install::setRootExecutableCallback || return 1

  # Upgrade of pip packages will be done on subsequent calls during upgrade cron
  upgradePipPackages
}

removeDuplicatePipPackages() {
  # remove duplicate pip packages with ~ prefix that breaks pip packages upgrade otherwise
  find "${VIRTUAL_ENV}/lib/python3.9/site-packages" -name '~*' -exec rm -Rf {} ';' || true
}

testInstall() {
  local -i failures=0
  # since virtualenv is not loaded python 3.9 is not yet available
  Version::checkMinimal "python" "--version" "3.8.10" || ((++failures))
  Version::checkMinimal "virtualenv" "--version" "20.25.1" || ((++failures))
  Assert::fileExists "/etc/profile.d/python_path.sh" root root || ((++failures))
  return "${failures}"
}

configure() {
  # create home directory that will receive virtualenv configs
  mkdir -p "${USER_HOME}/.virtualenvs" || true
  mkdir -p "${USER_HOME}/.pip/cache" || true

  # create python3.9 virtual env
  # virtualenv (for Python 3) and venv (for Python 2) 
  # allows you to manage separate package installations 
  # for different projects.
  virtualenv --system-site-packages --python=/usr/bin/python3.9 "${USER_HOME}/.virtualenvs/python3.9"
  upgradePipPackages
}

upgradePipPackages() {
  if [[ "${PIP_PACKAGES_UPGRADED:-0}" = "1" ]]; then
    return 0
  fi
  if [[ -f "${USER_HOME}/.virtualenvs/python3.9/bin/activate" ]]; then
    # load this virtualenv
    # shellcheck source=/dev/null
    source "${USER_HOME}/.virtualenvs/python3.9/bin/activate"

    # remove duplicate pip packages with ~ prefix that breaks pip packages upgrade otherwise
    find "${VIRTUAL_ENV}/lib/python3.9/site-packages" -name '~*' -exec rm -Rf {} ';' || true

    # install/upgrade pip
    python -m pip install --upgrade pip
    PIP_PACKAGES_UPGRADED=1
  fi
}

testConfigure() {
  local -i failures=0
  # shellcheck source=/dev/null
  source "${USER_HOME}/.virtualenvs/python3.9/bin/activate"
  Version::checkMinimal "python" "--version" "3.9.18" || ((++failures))
  Version::checkMinimal "pip" "--version" "24.0" || ((++failures))
  [[ "${VIRTUAL_ENV}" = "${USER_HOME}/.virtualenvs/python3.9" ]] || {
    Log::displayError "Virtualenv has not been loaded correctly"
    ((++failures))
  }
  return "${failures}"
}
