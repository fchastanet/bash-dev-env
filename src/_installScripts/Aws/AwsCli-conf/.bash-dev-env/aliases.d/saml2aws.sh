#!/usr/bin/env bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

if command -v saml2aws &>/dev/null; then
  alias aws-login='saml2aws login -p "${AWS_PROFILE:-default}" --session-duration=43200 --disable-keychain'
fi
