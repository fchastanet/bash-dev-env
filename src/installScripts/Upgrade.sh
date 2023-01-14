#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/installScripts/Upgrade
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..

.INCLUDE "${TEMPLATE_DIR}/installScripts/definitions/Upgrade.sh"

showHelp() {
  # shellcheck disable=SC2154
  engine::installScript::showHelp \
    "$(installScripts_Upgrade_helpDescription)" \
    "$(installScripts_Upgrade_helpVariables)" \
    "$(installScripts_Upgrade_dependencies)"
}

.INCLUDE "${TEMPLATE_DIR}/engine/installScript/_header.sh"

installScripts_Upgrade_install
installScripts_Upgrade_configure
installScripts_Upgrade_test
