#!/usr/bin/env bash
# @embed "${FRAMEWORK_ROOT_DIR}/src/UI/talk.ps1" as talkScript
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/Aws/conf" as conf_dir

helpDescription() {
  echo "Default aws config using saml2aws"
}

dependencies() {
  echo "installScripts/AwsCli"
  echo "installScripts/Saml2Aws"
}

listVariables() {
  echo "HOME"
  echo "USERNAME"
  echo "USERGROUP"
  echo "CAN_TALK_DURING_INSTALLATION"
  echo "AWS_APP_ID"
  echo "AWS_PROFILE"
  echo "AWS_USER_MAIL"
  echo "AWS_DEFAULT_REGION"
  echo "AWS_TEST_SECRET_ID"
  echo "AWS_DEFAULT_DOCKER_REGISTRY_ID"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- Use the alias ${__HELP_EXAMPLE}aws-login${__RESET_COLOR} in order to connect to your default aws profile."
  echo -e "Then the alias ${__HELP_EXAMPLE}aws-docker-login${__RESET_COLOR} can be used to login to docker registry."
  echo "%"
}

# jscpd:ignore-start
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
install() { :; }
testInstall() { :; }
isInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
isTestInstallImplemented() { :; }
# jscpd:ignore-end

configure() {
  local configDir
  # shellcheck disable=SC2154
  configDir="$(Conf::getOverriddenDir "${embed_dir_conf_dir}" "${CONF_OVERRIDE_DIR}/${scriptName}")"
  # install default configuration
  # shellcheck disable=SC2317
  configureAwsConfig() {
    sed -i -E \
      -e "s#azure_default_username=.+\$#azure_default_username=${AWS_USER_MAIL}#" \
      "${HOME}/.aws/config"
    Install::setUserRightsCallback "$@"
  }
  Install::file \
    "${configDir}/.aws/config" "${HOME}/.aws/config" \
    "${USERNAME}" "${USERGROUP}" configureAwsConfig
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"

  # use saml2aws to configure with the right parameters
  if [[ -n "${AWS_APP_ID}" && -n "${AWS_PROFILE}" && -n "${AWS_USER_MAIL}" ]]; then
    Log::displayInfo "Please wait saml2aws configuration finishing ..."
    DBUS_SESSION_BUS_ADDRESS=/dev/null saml2aws configure \
      --idp-provider='AzureAD' \
      --session-duration=43200 \
      --mfa='Auto' \
      --profile="${AWS_PROFILE}" \
      --url='https://account.activedirectory.windowsazure.com' \
      --username="${AWS_USER_MAIL}" \
      --app-id="${AWS_APP_ID}" \
      --skip-prompt
  else
    Log::displaySkipped "saml2aws configuration skipped as AWS_APP_ID, AWS_PROFILE or AWS_USER_MAIL are not provided"
  fi
}

testConfigure() {
  local -i failures=0

  Assert::fileExists "${HOME}/.aws/config" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/awsCli.sh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/saml2aws.sh" || ((++failures))

  if grep -q -E -e "azure_default_username=.+$" "${HOME}/.aws/config"; then
    # case where .aws/config has been overridden in conf_override folder
    local azureUserName
    azureUserName="$(sed -nr 's/azure_default_username=(.*)$/\1/p' "${HOME}/.aws/config")"
    if [[ -z "${azureUserName}" ]]; then
      ((++failures))
      Log::displayError "empty azure_default_username in '${HOME}/.aws/config'"
    elif [[ "${azureUserName}" != "${AWS_USER_MAIL}" ]]; then
      Log::displayWarning "azureUserName is not the same as AWS_USER_MAIL in ${BASH_DEV_ENV_ROOT_DIR}/.env"
    fi
  elif ! grep -q -E -e "^\[default\]$" "${HOME}/.aws/config"; then
    ((++failures))
    Log::displayError "default configuration not found in '${HOME}/.aws/config'"
  fi

  Assert::fileExists "${HOME}/.saml2aws" || ((++failures))

  if [[ "${INSTALL_INTERACTIVE}" = "0" ]]; then
    Log::displaySkipped "saml2aws configuration skipped as INSTALL_INTERACTIVE is set to 0"
  elif [[ -n "${AWS_APP_ID}" && -n "${AWS_PROFILE}" && -n "${AWS_USER_MAIL}" ]]; then
    # try to login
    # shellcheck disable=SC2154
    cp "${embed_file_talkScript}" "${embed_file_talkScript}.ps1"
    UI::talkToUser "Please on Bash Dev env installation, your input may be required" \
      "${embed_file_talkScript}.ps1"
    if ! Retry::parameterized 3 0 \
      "AWS Authentication, please provide your credentials ..." \
      saml2aws login -p "${AWS_PROFILE}" --disable-keychain; then
      ((++failures))
      Log::displayError "Failed to connect to aws"
      return "${failures}"
    fi
    Log::displaySuccess "Aws connection succeeds"

    # try to get secret
    Log::displayInfo "Trying to get secrets from aws"
    if ! aws secretsmanager \
      --region "${AWS_DEFAULT_REGION}" get-secret-value \
      --secret-id "${AWS_TEST_SECRET_ID}" \
      --query SecretString >/dev/null; then
      ((++failures))
      Log::displayError "Failed to connect to aws"
      return "${failures}"
    fi
    Log::displaySuccess "Aws secret retrieved successfully"

    # test docker private registry connection
    if ! command -v docker &>/dev/null; then
      Log::displaySkipped "test docker private registry connection skipped as docker command is missing"
      return "${failures}"
    fi

    Log::displayInfo "Trying to connect docker private registry, please provide password if asked"
    if aws ecr get-login-password --region "${AWS_DEFAULT_REGION}" | docker login \
      --username AWS \
      --password-stdin \
      "${AWS_DEFAULT_DOCKER_REGISTRY_ID}"; then
      Log::displaySuccess "docker login success"
    else
      ((++failures))
      Log::displayError "Failed to connect to docker private registry"
    fi
  else
    Log::displaySkipped "saml2aws configuration skipped as AWS_APP_ID, AWS_PROFILE or AWS_USER_MAIL are not provided"
  fi

  return "${failures}"
}