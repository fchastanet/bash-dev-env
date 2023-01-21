#!/usr/bin/env bash

stats::logRecapitulative() {
  local logFile="$1"

  local logRecapitulativeAwkScript
  logRecapitulativeAwkScript="$(
    cat <<'EOF'
.INCLUDE "${TEMPLATE_DIR}/stats/logRecapitulative.awk"
EOF
  )"

  if [[ -f "${logFile}" ]]; then
    awk --source "${logRecapitulativeAwkScript}" "${logFile}" | uniq
  fi
}
