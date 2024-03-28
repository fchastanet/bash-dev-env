#!/bin/bash

export N_PREFIX="${HOME}/n"
[[ :${PATH}: == *":${N_PREFIX}/bin:"* ]] || PATH="${N_PREFIX}/bin:${PATH}"
export PATH="${HOME}/.npm-global/bin/:${PATH}"