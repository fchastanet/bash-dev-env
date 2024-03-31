#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Composer
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/Composer" as composer_dir

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Composer"
}

helpDescription() {
  echo "Composer"
}

dependencies() {
  echo "Php"
}

helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  if command -v composer; then
    # upgrade
    composer global self-update
  else
    # install composer last version
    (
      trap 'rm -f composer-setup.php || true' EXIT
      cd /tmp || exit 1
      EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
      php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
      ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

      if [[ "${EXPECTED_CHECKSUM}" != "${ACTUAL_CHECKSUM}" ]]; then
        Log::displayError 'Invalid installer checksum'
        exit 1
      fi

      sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer --quiet
    )
  fi
}

testInstall() {
  Version::checkMinimal "composer" --version "2.4.3" || ((++failures))
}

configure() {
  # configure composer to be run as normal user
  sudo mkdir -p \
    /usr/local/.composer/cache \
    /usr/local/.composer/vendor \
    "${USER_HOME}/.config"
  sudo chown -R "${USERNAME}":"${USERGROUP}" \
    /usr/local/.composer \
    "${USER_HOME}/.config"

  Log::displayInfo "Install ~/.bash-dev-env/profile.d/composer_path.sh"
  local configDir
  # shellcheck disable=SC2154
  configDir="$(Conf::getOverriddenDir "${embed_dir_composer_dir}" "${CONF_OVERRIDE_DIR}/Composer")"
  OVERWRITE_CONFIG_FILES=1 Install::file \
    "${configDir}/.bash-dev-env/profile.d/composer_path.sh" "${USER_HOME}/.bash-dev-env/profile.d/composer_path.sh"
}

testConfigure() {
  local -i failures=0
  Assert::dirExists "/usr/local/.composer" || ((++failures))
  Assert::dirExists "${USER_HOME}/.config" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash-dev-env/profile.d/composer_path.sh" || ((++failures))
  exit "${failures}"
}
