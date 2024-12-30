#!/usr/bin/env bash

# @description Check if the current Ubuntu version
# is greater or equal to the provided version
# @arg $1 string Expected minimum version
# @exitcode 0 If the current Ubuntu version is greater or equal
# to the provided version
Version::isUbuntuMinimum() {
  local expectedMinimumVersion="$1"

  Version::compare "${VERSION_ID}" "${expectedMinimumVersion}"
  local -r comparisonResult=$?
  ((comparisonResult == 0 || comparisonResult == 1))
}
