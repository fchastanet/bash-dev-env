#!/usr/bin/env bash

helpDescription() {
  echo "this is an example that can be used to debug or as a template for other install scripts"
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
isInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
isTestInstallImplemented() { :; }
# jscpd:ignore-end

install() {
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
      -o APT::Update::Exclude=updatedb plocate
  fi
}

installFromUbuntu20() {
  # download mlocate package
  if ! dpkg -s mlocate &>/dev/null; then
    (
      mkdir -p /tmp/mlocate true
      cd /tmp/mlocate || exit 1
      # download mlocate package
      sudo apt-get download mlocate
      # extract it
      dpkg-deb -R mlocate_*_amd64.deb /tmp/mlocate/deb
      rm ./*.deb
      # shellcheck disable=SC1003
      BASE_MNT_C="$(mount | grep 'path=C:\\' | awk -F ' ' '{print $3}')"
      # update configuration in order to remove /mnt/c, docker and other cache directories
      PRUNEPATHS="${BASE_MNT_C} /var/cache /var/www /var/lib/docker ${USERHOME}/.npm ${USERHOME}/.cache"
      sudo sed -i -r \
        "s#^PRUNEPATHS=\"(.*)\"\$#PRUNEPATHS=\"\1 ${PRUNEPATHS} \"#" \
        deb/etc/updatedb.conf
      sudo sed -i -r 's/^# PRUNENAMES=/PRUNENAMES=/' deb/etc/updatedb.conf
      # recompress package
      sudo dpkg-deb -b deb mlocate.deb
      rm -Rf deb
      # install the new package
      sudo dpkg -i mlocate.deb
    )
  fi
}

testInstall() {
  if Version::isUbuntuMinimum "22.04"; then
    # since 22.04 mlocate has been replaced by plocate
    testInstallFromUbuntu22
  else
    testInstallFromUbuntu20
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

configureMlocate() {
  local -r BASE_MNT_C="$(mount | grep 'path=C:\\' | awk -F ' ' '{print $3}')"
  local -r prunePaths=(
    "${BASE_MNT_C}"
    "/var/cache"
    "/var/www"
    "/var/lib/docker"
    "${USERHOME}/.npm"
    "${USERHOME}/.cache"
  )
  # shellcheck disable=SC1003
  sudo sed -i -E \
    -e "s#^PRUNEPATHS=\"(.*)\"\$#PRUNEPATHS=\"\1 ${prunePaths[*]} \"#" \
    -e 's/^# PRUNENAMES="/PRUNENAMES="node_modules /' \
    -e '$a\' \
    -e "# updated by bash-dev-env" \
    /etc/updatedb.conf
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
