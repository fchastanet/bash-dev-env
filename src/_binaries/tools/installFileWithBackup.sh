#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/bin/installFileWithBackup
# FACADE
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..

HELP="$(
  cat <<EOF
${__HELP_TITLE}Synopsis:${__HELP_NORMAL} install a file and backup if exist

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} <file> <targetFile>

${__HELP_TITLE}Description:${__HELP_NORMAL}
Backup target file
and then install original file to target

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
)"
Args::defaultHelp "${HELP}" "$@"
