#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/Docker/Docker-conf" as conf_dir

helpDescription() {
  echo "Installs docker inside wsl."
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- You can now use ${__HELP_EXAMPLE}docker compose${__RESET_COLOR} or ${__HELP_EXAMPLE}docker-compose${__RESET_COLOR} indifferently thanks to installed docker compose plugin."
  echo "%"
}

dependencies() {
  echo "installScripts/MandatorySoftwares"
  echo "installScripts/WslDefaultConfig"
  echo "installScripts/DockerCompose"
}

# jscpd:ignore-start
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
isInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
isTestInstallImplemented() { :; }
# jscpd:ignore-end

cleanBeforeExport() {
  if command -v docker; then
    Log::displayInfo "Cleaning docker system"
    docker system prune -a --volumes --force || true
  fi
}

testCleanBeforeExport() {
  :
}

# REQUIRE Linux::requireUbuntu
# REQUIRE Linux::requireExecutedAsUser
install() {
  if isUbuntuMinimum24; then
    installFromUbuntu24
  else
    installFromUbuntu20
  fi
}

isUbuntuMinimum24() {
  Version::compare "${VERSION_ID}" "24.04"
}

installFromUbuntu24() {
  Log::displayInfo "install docker required packages"
  Linux::Apt::installIfNecessary --no-install-recommends \
    ca-certificates \
    curl

  sudo sh -c 'install -m 0755 -d /etc/apt/keyrings'
  Retry::default sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  Log::displayInfo "install docker apt source list"
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/ubuntu \
    ${VERSION_CODENAME} stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  Log::displayInfo "install docker"
  Linux::Apt::installIfNecessary --no-install-recommends \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin
}

installFromUbuntu20() {
  Log::displayInfo "install docker required packages"
  Linux::Apt::installIfNecessary --no-install-recommends \
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
  sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

  Log::displayInfo "install docker apt source list"
  Retry::default curl -fsSL "https://download.docker.com/linux/${ID}/gpg" | sudo apt-key add --no-tty --batch -
  local dockerSource="deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable"
  if ! grep -Fq "${dockerSource}" "/etc/apt/sources.list.d/docker.list"; then
    echo "deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list
    Linux::Apt::update
  fi

  Log::displayInfo "install docker"
  Linux::Apt::installIfNecessary --no-install-recommends \
    containerd.io \
    docker-ce \
    docker-ce-cli
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

configureDockerPlugin() {
  Log::displayInfo "Configuring docker-compose as docker plugin"
  # create the docker plugins directory if it doesn't exist yet
  # shellcheck disable=SC2153
  mkdir -p "${HOME}/.docker/cli-plugins"
  rm -f "${HOME}/.docker/cli-plugins/docker-compose" || true
  sudo ln -sf /usr/local/bin/docker-compose "${HOME}/.docker/cli-plugins/docker-compose"
}

configure() {
  Log::displayInfo "allowing user '${USERNAME}' to use docker"
  sudo getent group docker >/dev/null || sudo groupadd docker || true
  sudo usermod -aG docker "${USERNAME}" || true

  if ! isUbuntuMinimum24; then
    configureDockerPlugin
  fi

  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service

  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
}

testConfigure() {
  local -i failures=0
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/docker.sh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/profile.d/docker.sh" || ((++failures))
  Log::displayInfo "check if docker-compose binary is working"
  if ! docker-compose version &>/dev/null; then
    Log::displayError "docker-compose failure"
    ((++failures))
  fi

  Log::displayInfo "check if docker compose plugin is working"
  if ! docker compose version &>/dev/null; then
    Log::displayError "docker compose plugin failure"
    ((++failures))
  fi

  asUserToAvoidWslRestart() {
    sudo -u "${USERNAME}" -i "$@"
  }
  Log::displayInfo "check if docker dns is working"
  asUserToAvoidWslRestart docker run busybox ping google.com -c 1 &>/dev/null || {
    ((++failures))
    Log::displayError "google.com is not reachable from docker, dns issue ?"
    ping google.com -c 1 &>/dev/null || {
      Log::displayError "google.com is not reachable from host neither"
      ((++failures))
    }
  }

  Log::displayInfo "check if docker container can be launched"
  if ! asUserToAvoidWslRestart docker run --rm hello-world | grep -q "Hello from Docker!"; then
    Log::displayError "docker container cannot be launched"
    ((++failures))
  fi
  asUserToAvoidWslRestart docker image rm hello-world || true

  return "${failures}"
}
