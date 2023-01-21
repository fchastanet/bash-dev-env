#!/usr/bin/env bash

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"
if [[ -d "${ROOT_DIR}/vendor/bash-tools-framework" ]]; then
  FRAMEWORK_DIR="$(cd "${ROOT_DIR}/vendor/bash-tools-framework" && pwd -P)"
else
  # shellcheck disable=SC2034
  FRAMEWORK_DIR="${ROOT_DIR}/vendor/bash-tools-framework"
fi
# shellcheck disable=SC2034
INSTALL_SCRIPTS_DIR="${ROOT_DIR}/installScripts"
