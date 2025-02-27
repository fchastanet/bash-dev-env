#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/BashUtils/Mlocate-conf" as conf_dir

helpDescription() {
  echo "installs mlocate(before 22.04) or plocate package (since 22.04)"
  echo "and configure it to exclude some directories"
  echo "from the locate database."
}

dependencies() {
  echo "installScripts/MandatorySoftwares"
}

# jscpd:ignore-start
fortunes() { :; }
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

configureMlocate() {
  # shellcheck disable=SC1003
  local -r BASE_MNT_C="$(mount | grep 'path=C:\\' | awk -F ' ' '{print $3}')"
  local -r prunePaths=(
    "${BASE_MNT_C}"
    "/var/cache"
    "/var/www"
    "/var/lib/docker"
    "${HOME}/.npm"
    "${HOME}/.cache"
    "${HOME}/.venvs"
  )
  # shellcheck disable=SC1003
  sudo sed -i -E \
    -e "s#^PRUNEPATHS=\"(.*)\"\$#PRUNEPATHS=\"\1 ${prunePaths[*]} \"#" \
    -e '$a\' \
    -e "# updated by bash-dev-env" \
    /etc/updatedb.conf
}

installMlocateConfigFile() {
  local configDir
  # shellcheck disable=SC2154
  configDir="$(Conf::getOverriddenDir "${embed_dir_conf_dir}" "$(fullScriptOverrideDir)")"
  SUDO=sudo OVERWRITE_CONFIG_FILES=0 Install::file \
    "${configDir}/etc/updatedb.conf" \
    "/etc/updatedb.conf" \
    "root" "root" configureMlocate
}

install() {
  Log::displayInfo "Configure locate updatedb.conf to exclude some directories"
  installMlocateConfigFile

  if Version::isUbuntuMinimum "22.04"; then
    # since 22.04 mlocate has been replaced by plocate
    installFromUbuntu22
  else
    installFromUbuntu20
  fi
}

installFromUbuntu22() {
  if ! Linux::Apt::isPackageInstalled plocate; then
    Log::displayInfo "install plocate required packages"
    Linux::Apt::update
    Linux::Apt::install --no-install-recommends \
      plocate -o Dpkg::Options::="--force-confold"
  fi
}

installFromUbuntu20() {
  if ! Linux::Apt::isPackageInstalled mlocate; then
    Log::displayInfo "install mlocate required packages"
    Linux::Apt::update
    Linux::Apt::install --no-install-recommends \
      mlocate -o Dpkg::Options::="--force-confold"
  fi
}

testInstall() {
  if Version::isUbuntuMinimum "22.04"; then
    # since 22.04 mlocate has been replaced by plocate
    testInstallFromUbuntu22 || return 1
  else
    testInstallFromUbuntu20 || return 1
  fi
}

testInstallFromUbuntu22() {
  local -i failures=0
  dpkg -s plocate &>/dev/null || {
    Log::displayError "missing plocate package"
    ((++failures))
  }
  Assert::commandExists "locate" || ((++failures))
  return "${failures}"
}

testInstallFromUbuntu20() {
  local -i failures=0
  dpkg -s mlocate &>/dev/null || {
    Log::displayError "missing mlocate package"
    ((++failures))
  }
  Assert::commandExists "locate" || ((++failures))
  return "${failures}"
}

configure() {
  if ! grep -q '# updated by bash-dev-env' /etc/updatedb.conf; then
    configureMlocate
  fi
  Log::displayInfo "Update completion database, can take a while ..."
  time sudo updatedb
}

testConfigure() {
  local -i failures=0
  grep -q -E '^PRUNEPATHS=".*( /mnt/c){1}.*"$' /etc/updatedb.conf || {
    Log::displayError "missing /mnt/c in /etc/updatedb.conf PRUNEPATHS"
    ((++failures))
  }
  return "${failures}"
}
