#!/usr/bin/env bash

engine::install::showHelp() {
  local description="$1"

  profilesList="$(Conf::list "${ROOT_DIR}" "profile." ".sh" "-type f" "" |
    paste -s -d ',' | sed -e 's/,/, /g' || true)"
  softwaresList="$(Conf::list "${ROOT_DIR}/installScripts" "" "" "-mindepth 1 -type d" "" |
    grep -v -E '^(_.*|MandatorySoftwares)$' | paste -s -d ',' | sed -e 's/,/, /g' || true)"
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} ${description}

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} --help prints this help and exits
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [--skip-install] [--skip-configure] [--skip-test] [--prepare-export] -p|--profile <profile>
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [--skip-install] [--skip-configure] [--skip-test] [--prepare-export] [--skip-dependencies] <Software>

    -p|--profile profileName    the name of the profile to use that indicates configuration to run
    --skip-install              skip softwares installation
    --skip-configure            skip softwares configuration
    --skip-test                 skip softwares tests
    --prepare-export            prepare the wsl image for export (remove all sensitive files)
    --skip-dependencies         install the software requested without resolving dependencies

${__HELP_TITLE}List of available softwares:${__HELP_NORMAL}
${softwaresList}

${__HELP_TITLE}List of available profiles:${__HELP_NORMAL}
${profilesList}

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/author.tpl"
EOF
}
