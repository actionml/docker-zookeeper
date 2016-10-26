#!/bin/sh -e
# Display ip address of the given number (default: 1), Serf query payload passed as STDIN

ip_addresses() {
    ip address | grep 'inet\s' | grep -v '\blo\b' | sed -n 's/.*inet \(.*\)\/.*/\1/;p'
}

read addrnum
ip_addresses | sed "${addrnum}!d"
