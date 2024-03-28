#!/bin/bash

[[ :${PATH}: == *":${HOME}/.local/bin:"* ]] || PATH="${HOME}/.local/bin:${PATH}"
export PATH