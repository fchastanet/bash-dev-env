#!/bin/bash

envFileTemplate="$(
  cat <<'EOF'
.INCLUDE "${BASH_DEV_ENV_ROOT_DIR}/.env.template"
EOF
)"

# @description load .env file
# @arg $1 envFile:String the file to load
Engine::Config::loadConfig() {
  if [[ "${BASH_DEV_ENV_CONFIG_LOADED:-}" = "1" ]]; then
    return 0
  fi
  local envFile="${BASH_DEV_ENV_ROOT_DIR}/.env"
  Engine::Config::createEnvFileFromTemplate \
    "${envFile}" "${envFileTemplate}" || exit 1
  set -o allexport
  # shellcheck source=/.env.template
  source <(echo "${envFileTemplate}")
  # shellcheck source=/.env
  source "${BASH_DEV_ENV_ROOT_DIR}/.env"
  set +o allexport

  # load environment variables ID, VERSION_CODENAME
  Engine::Config::loadOsRelease

  if ! Engine::Config::checkEnv; then
    Log::displayError "one or more variables are invalid, check above logs and fix '${envFile}' file accordingly"
    return 1
  fi

  Engine::Config::loadUserVariables
  Engine::Config::loadHostIp

  Engine::Config::requireWslu

  #Linux::Wsl::initEnv
  Engine::Config::loadWslVariables

  Engine::Config::installBashDevEnv

  Log::requireLoad

  export PATH="${PATH}:${USER_HOME}/.local/bin"

  export BASH_DEV_ENV_CONFIG_LOADED=1
}
