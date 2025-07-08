#!/usr/bin/env zsh

# skip if non interactive mode
if [[ $- != *i* ]]; then
  return 0
fi

source "${HOME}/fchastanet/bash-dev-env/.env" || {
  echo "Warning: Could not source .env file"
}

# load aliases
if [[ -f "${HOME}/.aliases" ]]; then
  source "${HOME}/.aliases"
fi

export PATH="/usr/local/bin:${PATH}"

source "${HOME}/.bash-dev-env/init.d/zsh-zinit.zsh" || {
  echo "Error: Could not source zsh-zinit.zsh"
  exit 1
}

loadConfigFiles() {
  local dir="$1"
  local file
  while IFS= read -r file ; do
    # shellcheck source=src/_binaries/MandatorySoftwares/conf/.bash-dev-env/aliases.d/bash-dev-env.sh
    source "${file}"
  done < <("${HOME}/.bash-dev-env/findConfigFiles" "${dir}" sh zsh || echo)
}

loadConfigFiles "${HOME}/.bash-dev-env/themes.d"
loadConfigFiles "${HOME}/.bash-dev-env/interactive.d"
loadConfigFiles "${HOME}/.bash-dev-env/aliases.d"
loadConfigFiles "${HOME}/.bash-dev-env/completions.d"
