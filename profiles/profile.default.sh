#!/bin/bash

if [[ -z "${CONFIG_LIST+xxx}" ]]; then
  CONFIG_LIST=()
fi

# Mandatory packages
CONFIG_LIST+=(
  "installScripts/ConformanceTest"
  "installScripts/MandatorySoftwares"
  "installScripts/WslDefaultConfig"
  "installScripts/Upgrade"
)

# Code Checkers
CONFIG_LIST+=(
  "installScripts/ShFmt"
  "installScripts/Hadolint"
  "installScripts/Shellcheck"
)

# optional packages
CONFIG_LIST+=(
  "installScripts/MLocate"
  "installScripts/Docker"
  "installScripts/FortunesForProfile"
  "installScripts/Saml2Aws"
  "installScripts/BashTools"
  "installScripts/Oq"
  "installScripts/PlantUml"
)

# SDK
CONFIG_LIST+=(
  "installScripts/JavaSdkManagerDependencies"
  "installScripts/ComposerDependencies"
  "installScripts/NodeDependencies"
  "installScripts/GoDependencies"
)

# default configuration
CONFIG_LIST+=(
  "installScripts/ShellZshDefaultConfig"
  "installScripts/ShellBashDefaultConfig"
  "installScripts/MotdDefaultConfig"
  "installScripts/AwsDefaultConfig"
  "installScripts/KubeDefaultConfig"
  "installScripts/GitDefaultConfig"
  "installScripts/PreCommitDefaultConfig"
)

# Mandatory packages
CONFIG_LIST+=(
  "installScripts/Clean"
  "installScripts/Export"
)
