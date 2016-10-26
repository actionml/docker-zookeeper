#!/bin/sh -e
# Display ip address of the given number (default: 1), Serf query payload passed as STDIN

read addrnum
hostnames -I | cut -f${addrnum} -d' '
