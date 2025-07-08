#!/usr/bin/env sh

powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "netsh interface portproxy add v4tov4 listenport=9000 connectaddress='${HOST_IP}' connectport=9000"
