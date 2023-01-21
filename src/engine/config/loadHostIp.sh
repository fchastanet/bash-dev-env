#!/bin/bash

engine::config::loadHostIp() {
  HOST_IP="$(/sbin/ip route | awk '/default/ { print $3 }')"

  export HOST_IP
}
