#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Docker
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Docker"
}

helpDescription() {
  echo "install docker and docker-compose inside wsl"
}

dependencies() {
  echo "MandatorySoftwares"
  echo "WslConfig"
}

helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

# REQUIRE Linux::requireUbuntu
# REQUIRE Linux::requireExecutedAsUser
install() {
  Log::displayInfo "install docker required packages"
  Linux::Apt::update
  Linux::Apt::install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2

  # Docker utilizes iptables to implement network isolation.
  # For good reason, Debian uses the more modern nftables, but this means
  # that Docker cannot automatically tweak the Linux firewall.
  # Given this, you probably want to configure Debian to use the legacy
  # iptables by default
  sudo update-alternatives --set iptables /usr/sbin/iptables-legacy

  Log::displayInfo "install docker apt source list"
  Retry::default curl -fsSL "https://download.docker.com/linux/${ID}/gpg" | sudo apt-key add -
  local dockerSource="deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable"
  if ! grep -q "${dockerSource}" "/etc/apt/sources.list.d/docker.list"; then
    echo "deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list
    Linux::Apt::update
  fi

  Log::displayInfo "install docker"
  Retry::default sudo apt-get install -y \
    containerd.io \
    docker-ce \
    docker-ce-cli

  Log::displayInfo "Installing docker-compose"
  # shellcheck disable=SC2317
  dockerComposeVersionCallback() {
    echo "v$(Version::getCommandVersionFromPlainText "$@")"
  }
  export -f dockerComposeVersionCallback
  # shellcheck disable=SC2154
  SUDO=sudo Github::upgradeRelease \
    /usr/local/bin/docker-compose \
    "https://github.com/docker/compose/releases/download/@latestVersion@/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)" \
    "--version" \
    dockerComposeVersionCallback

  sudo rm -f /usr/bin/docker-compose || true
  sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
}

testInstall() {
  local -i failures=0

  if ! Linux::isSystemdRunning; then
    if grep -q -E '^systemd=true' /etc/wsl.conf; then
      Log::fatal "You need to restart wsl by running 'wsl --shutdown' from powershell and re-run this script, in order to start with systemd"
    else
      Log::fatal "/etc/wsl.conf has not been updated with systemd=true instruction, please check this install logs"
    fi
  fi

  Version::checkMinimal "docker" --version "25.0.3" || ((++failures))
  Version::checkMinimal "docker-compose" --version "2.23.1" || ((++failures))

  Log::displayInfo "docker executable path $(command -v docker || true)"
  Log::displayInfo "docker version $(docker --version || true)"
  Log::displayInfo "docker-compose version $(docker-compose --version || true)"

  dockerIsStarted() {
    DOCKER_PS="$(docker ps 2>&1 || true)"
    [[ ! "${DOCKER_PS}" =~ "Cannot connect to the Docker daemon" ]]
  }
  Log::displayInfo "Checking if docker is started ..."
  if dockerIsStarted; then
    Log::displaySuccess "Docker connection success"
  else
    Log::displayError "Docker is not started"
    ((++failures))
  fi
  return "${failures}"
}

configure() {
  Log::displayInfo "allowing user '${USERNAME}' to use docker"
  sudo getent group docker >/dev/null || sudo groupadd docker || true
  sudo usermod -aG docker "${USERNAME}" || true

  Log::displayInfo "Configuring docker-compose as docker plugin"
  # create the docker plugins directory if it doesn't exist yet
  # shellcheck disable=SC2153
  mkdir -p "${USER_HOME}/.docker/cli-plugins"
  rm -f "${USER_HOME}/.docker/cli-plugins/docker-compose" || true
  sudo ln -sf /usr/local/bin/docker-compose "${USER_HOME}/.docker/cli-plugins/docker-compose"
}

testConfigure() {
  local -i failures=0

  Log::displayInfo "check if docker-compose binary is working"
  if ! docker-compose version &>/dev/null; then
    Log::displayError "docker-compose failure"
    ((++failures))
  fi

  Log::displayInfo "check if docker compose plugin is installed"
  if [[ ! -f "${USER_HOME}/.docker/cli-plugins/docker-compose" ]]; then
    Log::displayError "docker compose plugin not installed in folder ${USER_HOME}/.docker/cli-plugins/"
    ((++failures))
  fi

  Log::displayInfo "check if docker compose plugin is working"
  if ! docker compose version &>/dev/null; then
    Log::displayError "docker compose plugin failure"
    ((++failures))
  fi

  Log::displayInfo "check if docker dns is working"
  sudo -u "${USERNAME}" -i docker run busybox ping google.com -c 1 &>/dev/null || {
    ((++failures))
    Log::displayError "google.com is not reachable from docker, dns issue ?"
    ping google.com -c 1 &>/dev/null || {
      Log::displayError "google.com is not reachable from host neither"
      ((++failures))
    }
  }

  Log::displayInfo "check if docker container can be launched"
  if ! sudo -u "${USERNAME}" -i docker run --rm hello-world | grep -q "Hello from Docker!"; then
    ((++failures))
    Log::displayError "docker container cannot be launched"
  fi
  sudo -u "${USERNAME}" -i docker image rm hello-world || true

  return "${failures}"
}
