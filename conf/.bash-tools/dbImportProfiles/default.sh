#!/usr/bin/env bash

# cat represents the whole list of tables
cat |
  grep -v '_stats' |
  grep -v '_log' |
  grep -v '_history' |
  # always finish by a cat to be sure the command does not return exit code != 0
  cat
