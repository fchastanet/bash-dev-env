#!/usr/bin/env bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

if [[ "${USE_AWS_CONFIGURE_SSO:-1}" = "1" ]]; then
  alias aws-login='aws configure sso'
elif command -v saml2aws &>/dev/null; then
  alias aws-login='saml2aws login -p "${AWS_PROFILE:-default}" --session-duration=43200 --disable-keychain'
fi
