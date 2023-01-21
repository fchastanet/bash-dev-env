#!/usr/bin/env bash

export SKIP_INSTALL
export SKIP_CONFIGURE
export SKIP_TEST

SKIP_INSTALL=0
SKIP_CONFIGURE=0
SKIP_TEST=0

# read command parameters
# $@ is all command line parameters passed to the script.
# -o is for short options like -h
# -l is for long options with double dash like --help
# the comma separates different long options
LONG_OPTIONS="help,skip-test,skip-tests,skip-config,skip-configure,skip-configuration,skip-install,skip-installation"
SHORT_OPTIONS="h"

options=$(getopt -l "${LONG_OPTIONS}" -o "${SHORT_OPTIONS}" -- "$@" 2>/dev/null) || {
  showHelp
  Log::fatal "invalid options specified"
}

eval set -- "${options}"
while true; do
  case $1 in
    -h | --help)
      showHelp
      exit 0
      ;;
    --skip-installation | --skip-install)
      SKIP_INSTALL=1
      ;;
    --skip-config | --skip-configure | --skip-configuration)
      SKIP_CONFIGURE=1
      ;;
    --skip-test | --skip-tests)
      SKIP_TEST=1
      ;;
    --)
      shift || true
      break
      ;;
    *)
      showHelp
      Log::fatal "invalid argument $1"
      ;;
  esac
  shift || true
done

if [[ "$#" != "0" ]]; then
  showHelp
  Log::fatal "no fixed parameter need to be provided"
fi
