#!/bin/bash

# load config
if ! engine::config::checkConfigExist "${ROOT_DIR}/.env"; then
  exit 1
fi
engine::config::loadConfig "${ROOT_DIR}/.env"
engine::config::check "${ROOT_DIR}/.env"
engine::config::loadHostIp
engine::config::loadWslVariables
engine::config::createSudoerFile

CONFIG_LOGS_DIR="${CONFIG_LOGS_DIR:-${TMPDIR}}"
