#!/usr/bin/env bash
# @embed  "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/GithubReleases/Bat-conf" as conf_dir

helpDescription() {
  echo "A cat(1) clone with syntax highlighting and Git integration"
}

fortunes() {
  if command -v bat &>/dev/null; then
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- Use ${__HELP_EXAMPLE}bat${__RESET_COLOR} command to pre-visualize one or multiple files."
    echo "%"
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- alias ${__HELP_EXAMPLE}h${__RESET_COLOR} allows to display command help using ${__HELP_EXAMPLE}bat${__RESET_COLOR}, try ${__HELP_EXAMPLE}h cp${__RESET_COLOR}."
    echo "%"

    if [[ "${USER_SHELL}" = "/usr/bin/zsh" ]]; then
      echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- command with ${__HELP_EXAMPLE}--help${__RESET_COLOR} will automatically be displayed with ${__HELP_EXAMPLE}bat${__RESET_COLOR}."
      echo "%"
    fi
  else
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- Run ${__HELP_EXAMPLE}installAndConfigure Bat${__RESET_COLOR} to initialize ${__HELP_EXAMPLE}bat${__RESET_COLOR} (file pre-visualization tool)."
    echo "%"
  fi
}

install() {
  SUDO=sudo INSTALL_CALLBACK=Linux::installDeb Github::upgradeRelease \
    "/usr/bin/bat" \
    "https://github.com/sharkdp/bat/releases/download/v@latestVersion@/bat_@latestVersion@_amd64.deb"
}

testInstall() {
  Version::checkMinimal "bat" --version "0.22.1" || return 1
}

configure() {
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "$(fullScriptOverrideDir)" \
    ".bash-dev-env"
}

testConfigure() {
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/bat.sh"
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/bat.zsh"
}
