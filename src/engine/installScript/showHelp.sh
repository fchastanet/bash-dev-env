#!/usr/bin/env bash

engine::installScript::showHelp() {
  local description="$1"
  local helpVariables="$2"
  local dependencies="$3"
  if [[ "${dependencies}" = "" ]]; then
    dependencies="${__HELP_EXAMPLE}None${__HELP_NORMAL}"
  fi

  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} ${description}

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} --help prints this help and exits
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [--skip-install] [--skip-configure] [--skip-test]

    --skip-install              skip softwares installation
    --skip-configure            skip softwares configuration
    --skip-test                 skip softwares tests

${__HELP_TITLE}List of needed variables:${__HELP_NORMAL}
${helpVariables}

${__HELP_TITLE}List of dependencies:${__HELP_NORMAL}
  ${dependencies}

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/author.tpl"
EOF
}
