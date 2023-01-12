#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/doc
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..

.INCLUDE "${TEMPLATE_DIR}/_includes/_header.tpl"
DOC_DIR="${ROOT_DIR}/pages"

HELP="$(
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} generate markdown documentation
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME}

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/author.tpl"
EOF
)"
Args::defaultHelp "${HELP}" "$@"

if [[ "${IN_BASH_DOCKER:-}" != "You're in docker" ]]; then
  "${BIN_DIR}/runBuildContainer" "/bash/bin/doc" "$@"
  exit $?
fi

#-----------------------------
# doc generation
#-----------------------------

# copy other files
cp "${ROOT_DIR}/README.md" "${DOC_DIR}/README.md"
sed -i -E \
  -e '/<!-- remove -->/,/<!-- endRemove -->/d' \
  -e 's#https://fchastanet.github.io/bash-dev-env/#/#' \
  -e 's#^> \*\*_TIP:_\*\* (.*)$#> [!TIP|label:\1]#' \
  "${DOC_DIR}/README.md"

cp -R "${ROOT_DIR}/docs" "${DOC_DIR}"
