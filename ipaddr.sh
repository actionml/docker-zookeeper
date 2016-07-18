#!/bin/sh -e
# Grab inet address on the given interface, Serf query payload passed as STDIN

read dev
addr=$(ip a show dev $dev | grep 'inet ' | tr -s '[:space:]' | cut -f3 -d' ')
echo ${addr%/*}
