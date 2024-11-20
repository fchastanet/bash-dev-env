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
  # download mlocate package
  if ! dpkg -s mlocate &>/dev/null; then
    (
      mkdir -p /tmp/mlocate true
      cd /tmp/mlocate || exit 1
      # download mlocate package
      apt-get download mlocate
      # extract it
      dpkg-deb -R mlocate_*_amd64.deb /tmp/mlocate/deb
      rm ./*.deb
      # shellcheck disable=SC1003
      BASE_MNT_C="$(mount | grep 'path=C:\\' | awk -F ' ' '{print $3}')"
      # update configuration in order to remove /mnt/c, docker and other cache directories
      PRUNEPATHS="${BASE_MNT_C} /var/cache /var/www /var/lib/docker ${USERHOME}/.npm ${USERHOME}/.cache"
      sed -i -r \
        "s#^PRUNEPATHS=\"(.*)\"\$#PRUNEPATHS=\"\1 ${PRUNEPATHS} \"#" \
        deb/etc/updatedb.conf
      sed -i -r 's/^# PRUNENAMES=/PRUNENAMES=/' deb/etc/updatedb.conf
      # recompress package
      dpkg-deb -b deb mlocate.deb
      rm -Rf deb
      # install the new package
      dpkg -i mlocate.deb
    )
  fi
}

testInstall() {
  local -i failures=0
  dpkg -s mlocate &>/dev/null || {
    Log::displayError "missing mlocate binary"
    ((++failures))
  }
  Assert::commandExists "locate" || ((++failures))
  return "${failures}"
}

configure() {
  # update database
  export MYPRUNEPATHS="/tmp /var/spool /media /var/lib/os-prober /var/lib/ceph /home/.ecryptfs /var/lib/schroot /var/cache /var/www /var/lib/docker"
  dpkg --configure -a

  Log::displayInfo "Update completion database, can take a while ..."
  time updatedb
}

testConfigure() {
  local -i failures=0
  grep -E '^PRUNEPATHS=".*( /mnt/c){1}.*"$' /etc/updatedb.conf || ((++failures))
  grep -E '^PRUNEPATHS=".*( /c){1}.*"$' /etc/updatedb.conf || ((++failures))
  return "${failures}"
}
