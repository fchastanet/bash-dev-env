#!/bin/bash

[[ :${PATH}: == *":/home/wsl/.config/composer/vendor/bin:"* ]] || PATH="/home/wsl/.config/composer/vendor/bin:${PATH}"
export PATH