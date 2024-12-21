#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/_Configs/KubeDefaultConfig-conf" as conf_dir

kubeBeforeParseCallback() {
  Git::requireGitCommand
  Linux::requireJqCommand
}

helpDescription() {
  echo "Kube default configuration"
}

dependencies() {
  echo "installScripts/Saml2Aws"
  echo "installScripts/Docker"
  echo "installScripts/GoGvm"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- these kubernetes tools are available "
  echo -e "  - ${__HELP_EXAMPLE}helm${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}kubectl${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}kind${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}minikube${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}kubeps1${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}kubectx${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}kubens${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}lazydocker${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}kube-linter${__RESET_COLOR}."
  echo "%"
  if command -v lazydocker &>/dev/null; then
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- you can use ${__HELP_EXAMPLE}lazydocker${__RESET_COLOR} to navigate through your containers."
    echo -e "Lazydocker is a simple terminal UI for both ${__HELP_EXAMPLE}docker${__RESET_COLOR} and ${__HELP_EXAMPLE}docker-compose${__RESET_COLOR}, written in Go."
    echo "%"
  fi
  if command -v k9s &>/dev/null; then
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- you can use ${__HELP_EXAMPLE}k9s${__RESET_COLOR} to navigate through your pods."
    echo "K9s provides a terminal UI to interact with your Kubernetes clusters."
    echo "The aim of this project is to make it easier to navigate, observe"
    echo "and manage your applications in the wild. K9s continually watches"
    echo "kubernetes for changes and offers subsequent commands to interact"
    echo "with your observed resources."
    echo "%"
  fi
}

# jscpd:ignore-start
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
isInstallImplemented() { :; }
isTestInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
# jscpd:ignore-end

installHelm() {
  if ! command -v helm &>/dev/null; then
    # remove old apt-key that was installed by this script
    sudo apt-key del "7C1A 168A" || true

    Log::displayInfo "install helm ..."
    Retry::default curl -fsSL https://baltocdn.com/helm/signing.asc |
      gpg --dearmor |
      sudo tee /usr/share/keyrings/helm.gpg >/dev/null
    Linux::Apt::installIfNecessary --no-install-recommends \
      apt-transport-https
    echo "deb [arch=$(dpkg --print-architecture) \
      signed-by=/usr/share/keyrings/helm.gpg] \
      https://baltocdn.com/helm/stable/debian/ all main" |
      sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

    Linux::Apt::installIfNecessary --no-install-recommends \
      helm
  fi
}

installKubectl() {
  Log::displayInfo "install kubectl ..."
  local versionUrl="https://storage.googleapis.com/kubernetes-release/release/stable.txt"
  local latestVersion
  latestVersion="$(curl -fsSL "${versionUrl}" | Version::parse)"
  if command -v kubectl &&
    [[ "$(kubectl version 2>/dev/null | Version::parse)" = "${latestVersion}" ]]; then
    Log::displaySkipped "kubectl version ${latestVersion} already installed"
  else
    Retry::default curl \
      -L \
      -o /tmp/kubectl \
      --fail \
      "https://storage.googleapis.com/kubernetes-release/release/v${latestVersion}/bin/linux/amd64/kubectl"
    sudo chmod +x /tmp/kubectl
    sudo mv /tmp/kubectl /usr/local/bin/kubectl
  fi
}

installKind() {
  SUDO=sudo Github::upgradeRelease \
    /usr/local/bin/kind \
    "https://github.com/kubernetes-sigs/kind/releases/download/v@latestVersion@/kind-linux-amd64"
}

installMinikube() {
  SUDO=sudo Github::upgradeRelease \
    /usr/local/bin/minikube \
    "https://github.com/kubernetes/minikube/releases/download/v@latestVersion@/minikube-linux-amd64" \
    version
}

installKubeps1() {
  SUDO=sudo GIT_CLONE_OPTIONS="--depth=1" Git::cloneOrPullIfNoChanges \
    "/opt/kubeps1" \
    "https://github.com/jonmosco/kube-ps1.git"
}

installKubectx() {
  SUDO=sudo GIT_CLONE_OPTIONS="--depth=1" Git::cloneOrPullIfNoChanges \
    "/opt/kubectx" \
    "https://github.com/ahmetb/kubectx"

  sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
  sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
}

installLazydocker() {
  Log::displayInfo "Installing lazydocker"
  (
    # shellcheck source=/dev/null
    source "${HOME}/.bash-dev-env/profile.d/golang.sh" || exit 1
    go install github.com/jesseduffield/lazydocker@latest || exit 1
  ) || {
    Log::displayError "Failure during lazydocker installation"
    return 1
  }
}

installK9s() {
  SUDO=sudo INSTALL_CALLBACK=Linux::installDeb Github::upgradeRelease \
    /usr/bin/k9s \
    "https://github.com/derailed/k9s/releases/download/v@latestVersion@/k9s_linux_amd64.deb" \
    version
}

install() {
  installHelm || {
    Log::displayError "Error during helm install"
    return 1
  }
  installKubectl || {
    Log::displayError "Error during kubectl install"
    return 1
  }
  installKind || {
    Log::displayError "Error during kind install"
    return 1
  }
  installMinikube || {
    Log::displayError "Error during minikube install"
    return 1
  }
  installKubeps1 || {
    Log::displayError "Error during kubeps1 install"
    return 1
  }
  installKubectx || {
    Log::displayError "Error during kubectx install"
    return 1
  }
  installLazydocker || {
    Log::displayError "Error during lazydocker install"
    return 1
  }
  installK9s || {
    Log::displayError "Error during k9s install"
    return 1
  }
  Log::displayInfo "Installing kube-linter"
  (
    export GOBIN="${HOME}/.gvm/go/bin"
    go install golang.stackrox.io/kube-linter/cmd/kube-linter@latest
  )
}

testInstall() {
  local -i failures=0
  Version::checkMinimal "helm" "version" "3.14.2" || ((++failures))
  Version::checkMinimal "kubectl" "version" "1.29.1" || ((++failures))
  Version::checkMinimal "kind" "--version" "0.16.0" || ((++failures))
  Version::checkMinimal "minikube" "version" "1.27.1" || ((++failures))
  Version::checkMinimal "k9s" "version" "0.28.2" || ((++failures))
  (
    local -i errors=0
    # shellcheck source=/dev/null
    source "${HOME}/.bash-dev-env/profile.d/golang.sh" || ((++errors))
    Assert::commandExists "kube-linter" || ((++errors))
    Assert::commandExists "lazydocker" || ((++errors))
    exit "${errors}"
  ) || ((failures += $?))
  Assert::commandExists kubectx || ((++failures))
  Assert::commandExists kubens || ((++failures))
  Assert::fileExists /opt/kubeps1/kube-ps1.sh root root || ((++failures))
  return "${failures}"
}

isKubeConfigGenerationAvailable() {
  local type="$1"
  if [[ "${INSTALL_INTERACTIVE}" = "0" ]]; then
    Log::displaySkipped ".kube/config configuration ${type} skipped as INSTALL_INTERACTIVE is set to 0"
    return 1
  fi

  if [[ -z "${KUBE_CONFIG_REGION_CODE}" || -z "${KUBE_CONFIG_CLUSTER_ARN}" ]]; then
    Log::displaySkipped ".kube/config configuration ${type} skipped as KUBE_CONFIG_REGION_CODE or KUBE_CONFIG_CLUSTER_ARN are not provided"
    return 1
  fi
  if command -v aws &>/dev/null; then
    Log::displaySkipped ".kube/config configuration ${type} skipped as aws command is not available"
    return 1
  fi
}

configure() {
  mkdir -p "${HOME}/.bash_completion.d" || true
  chown "${USERNAME}":"${USERGROUP}" "${HOME}/.bash_completion.d"

  ln -sf /opt/kubectx/completion/kubens.bash "${HOME}/.bash_completion.d/kubens"
  chown -h "${USERNAME}":"${USERGROUP}" "${HOME}/.bash_completion.d/kubens"
  ln -sf /opt/kubectx/completion/kubectx.bash "${HOME}/.bash_completion.d/kubectx"
  chown -h "${USERNAME}":"${USERGROUP}" "${HOME}/.bash_completion.d/kubectx"

  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"

  IGNORE_MISSING_SOURCE_DIR=1 Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".kube"

  if [[ ! -f "${HOME}/.kube/config" ]] && isKubeConfigGenerationAvailable "generation"; then
    aws eks update-kubeconfig \
      --region "${KUBE_CONFIG_REGION_CODE}" \
      --name "${KUBE_CONFIG_CLUSTER_ARN}" || return 1
  fi
}

testConfigure() {
  local -i failures=0
  Assert::dirExists "${HOME}/.bash_completion.d" || ((++failures))
  Assert::fileExists "${HOME}/.bash_completion.d/kubens" || ((++failures))
  Assert::fileExists "${HOME}/.bash_completion.d/kubectx" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/completions.d/kubectl.zsh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/kube-ps1.bash" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/kube.zsh" || ((++failures))
  if isKubeConfigGenerationAvailable "test"; then
    Assert::fileExists "${HOME}/.kube/config" || ((++failures))
  fi

  return "${failures}"
}
