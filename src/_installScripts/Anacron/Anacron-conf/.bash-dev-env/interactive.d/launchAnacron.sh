#!/usr/bin/env bash

if [[ -o login && -f "${HOME}/.cron_activated" ]]; then
  sudo service anacron start
fi
