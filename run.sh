#!/bin/bash
set -e

# Start Icecast in the background
echo "[*] Starting Icecast2..."
/usr/bin/icecast2 -b -c "/home/container/icecast.xml"

# Wait a few seconds to ensure Icecast is up
echo "[*] Waiting for Icecast to initialize..."
sleep 3

# Start Liquidsoap
echo "[*] Starting Liquidsoap..."
liquidsoap --verbose /home/container/radio.liq
