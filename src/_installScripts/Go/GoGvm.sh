#!/usr/bin/env bash

helpDescription() {
  echo "gvm tool allows to switch from one go version to another."
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- use gvm to switch go version"
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
isInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
isTestInstallImplemented() { :; }
# jscpd:ignore-end

install() {
  # shellcheck source=/dev/null
  source "${HOME}/.bash-dev-env/profile.d/golang.sh" || ((++failures))

  mkdir -p "${HOME}/.local/bin"
  curl -o "${HOME}/.local/bin/gvm" \
    -L "https://github.com/devnw/gvm/releases/download/latest/gvm" || ((++failures))
  chmod +x "${HOME}/.local/bin/gvm"

  return "${failures}"
}

testInstall() {
  local -i failures=0
  # shellcheck source=/dev/null
  Assert::commandExists gvm || ((++failures))

  return "${failures}"
}

configure() {
  # install latest version only the first time
  if [[ -f "${HOME}/.gvm/latestVersionInitialized" ]]; then
    Log::displaySkipped "go latest version is installed only the first time, use gvm command to switch go version"
  else
    Log::displayInfo "Retrieve list of go version available"
    # install latest version
    local latestVersion
    latestVersion="$(
      curl 'https://go.dev/VERSION?m=text' |
        grep -Eoh '[0-9]+\..*'
    )"

    Log::displayInfo "Installing go latest version is ${latestVersion}"
    gvm "${latestVersion}" -s

    touch "${HOME}/.gvm/latestVersionInitialized"
  fi
  # install useful dependencies
  GOBIN="${HOME}/.gvm/go/bin" go install mvdan.cc/gofumpt@latest
  GOBIN="${HOME}/.gvm/go/bin" go install github.com/bwplotka/bingo@latest
  GOBIN="${HOME}/.gvm/go/bin" go install golang.org/x/tools/cmd/goimports@latest
  GOBIN="${HOME}/.gvm/go/bin" go install github.com/mgechev/revive@latest
}

testConfigure() {
  local failures=0
  Version::checkMinimal "go" "version" "1.22.1" || ((++failures))
  return "${failures}"
}
