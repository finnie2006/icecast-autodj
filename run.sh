#!/bin/bash
set -e

# Start Icecast in the background
/usr/bin/icecast2 -b -c "/home/container/icecast.xml"

# Wait a few seconds to ensure Icecast is up
sleep 5

# Start Liquidsoap
liquidsoap --verbose /home/container/radio.liq
