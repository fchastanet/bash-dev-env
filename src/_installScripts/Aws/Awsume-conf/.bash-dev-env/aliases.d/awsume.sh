#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

# in order to log in to aws ecr - private docker registry
if command -v awsume &>/dev/null; then
  alias awsume="source awsume"
fi
