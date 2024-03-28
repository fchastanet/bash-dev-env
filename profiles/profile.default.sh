#!/bin/bash

if [[ -z "${CONFIG_LIST+xxx}" ]]; then
  CONFIG_LIST=()
fi

# Mandatory packages
CONFIG_LIST+=(
  "ConformanceTest"
  "Upgrade"
  "MandatorySoftwares"
)

# optional packages
CONFIG_LIST+=(
  "Docker"
  "DefaultMotd"
  "DefaultAwsConfig"
  "DefaultKubeConfig"
  "Saml2Aws"
  "ShellBash"
  "BashTools"
  "PreCommitConfig"
  "CodeCheckers"
  "Oq"
  "PlantUml"
)

# Mandatory packages
CONFIG_LIST+=(
  "Clean"
  "Export"
)
