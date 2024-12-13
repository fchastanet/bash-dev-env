#!/usr/bin/env bash

helpDescription() {
  echo "Go dependencies - development tools"
}

helpLongDescription() {
  helpDescription
  echo "$(scriptName) -- the following go tools and linters are available:"
  echo -e "  - ${__HELP_EXAMPLE}staticcheck${__RESET_COLOR} linter"
  echo -e "      Staticcheck is a state of the art linter for the Go"
  echo -e "      programming language. Using static analysis, it finds bugs"
  echo -e "      and performance issues, offers simplifications, and enforces"
  echo -e "      style rules."
  echo -e "  - ${__HELP_EXAMPLE}gofumpt${__RESET_COLOR} formatters"
  echo -e "      Enforce a stricter format than gofmt, while being backwards"
  echo -e "      compatible. That is, gofumpt is happy with a subset of the"
  echo -e "      formats that gofmt is happy with."
  echo -e "  - ${__HELP_EXAMPLE}revive${__RESET_COLOR} linter"
  echo -e "      Fast, configurable, extensible, flexible, and beautiful"
  echo -e "      linter for Go. Drop-in replacement of golint."
  echo -e "  - ${__HELP_EXAMPLE}goimports${__RESET_COLOR}"
  echo -e "      This tool updates your Go import lines, adding missing ones"
  echo -e "      and removing unreferenced ones."
  echo -e "  - ${__HELP_EXAMPLE}bingo${__RESET_COLOR}"
  echo -e "      built on top of Go Modules, allowing reproducible dev environments."
  echo -e "      'bingo' allows to easily maintain a separate, nested Go Module for"
  echo -e "      each binary."
  echo -e "  - ${__HELP_EXAMPLE}golangci-lint${__RESET_COLOR}"
  echo -e "       is a fast Go linters runner."
  echo -e "  - ${__HELP_EXAMPLE}dlv${__RESET_COLOR} debugger"
  echo -e "  - ${__HELP_EXAMPLE}kcl${__RESET_COLOR}"
  echo -e "       KCL is an open-source, constraint-based record and functional"
  echo -e "       language that enhances the writing of complex configurations,"
  echo -e "       including those for cloud-native scenarios."
}

dependencies() {
  echo "installScripts/GoGvm"
}

fortunes() {
  helpLongDescription
  echo "%"
}

# jscpd:ignore-start
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
configure() { :; }
testConfigure() { :; }
# jscpd:ignore-end

install() {
  Log::displayInfo "Installing go dependencies"
  # install useful dependencies
  (
    export GOBIN="${HOME}/.gvm/go/bin"
    go install mvdan.cc/gofumpt@latest
    go install github.com/bwplotka/bingo@latest
    go install github.com/mgechev/revive@latest
    go install honnef.co/go/tools/cmd/staticcheck@latest
    go install github.com/go-delve/delve/cmd/dlv@latest
    go install github.com/Gelio/go-global-update@latest
    go install kcl-lang.io/cli/cmd/kcl@latest
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    go install golang.org/x/tools/cmd/goimports@latest
  )

  Log::displayInfo "Upgrading go dependencies"
  go-global-update
}

testInstall() {
  local -i failures=0
  (
    local -i failures=0
    # shellcheck source=/dev/null
    source "${HOME}/.bash-dev-env/profile.d/golang.sh" || exit 1
    Version::checkMinimal "gofumpt" --version "0.7.0" || ((++failures))
    Version::checkMinimal "bingo" version "0.9" || ((++failures))
    Version::checkMinimal "revive" --version "1.3.9" || ((++failures))
    Version::checkMinimal "staticcheck" --version "0.5.1" || ((++failures))
    Version::checkMinimal "dlv" version "1.23.1" || ((++failures))
    Version::checkMinimal "go-global-update" version "0.2.5" || ((++failures))
    Version::checkMinimal "kcl" version "0.10.3" || ((++failures))
    Version::checkMinimal "golangci-lint" version "1.61.0" || ((++failures))
    Assert::commandExists "goimports" || ((++failures))
    exit "${failures}"
  ) || failures="$?"
  return "${failures}"
}
