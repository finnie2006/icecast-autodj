#!/bin/bash

# Define the cleanup function
cleanup() {
    echo "[*] Received stop signal, shutting down..."
    
    # First, send a friendly TERM signal
    kill -SIGTERM $LIQUIDSOAP_PID 2>/dev/null
    kill -SIGTERM $ICECAST_PID 2>/dev/null
    
    # Give the processes 2 seconds to shut down gracefully
    sleep 2
    
    # Check if any processes are still running and force them to stop
    echo "[*] Checking for stubborn processes..."
    if kill -0 $ICECAST_PID 2>/dev/null; then
        echo "[!] Icecast (PID $ICECAST_PID) did not respond, forcing shutdown (SIGKILL)..."
        kill -SIGKILL $ICECAST_PID 2>/dev/null
    fi
    if kill -0 $LIQUIDSOAP_PID 2>/dev/null; then
        echo "[!] Liquidsoap (PID $LIQUIDSOAP_PID) did not respond, forcing shutdown (SIGKILL)..."
        kill -SIGKILL $LIQUIDSOAP_PID 2>/dev/null
    fi
    
    echo "[*] All processes have been terminated."
    exit 0
}

# Set a trap for the SIGINT and SIGTERM signals
trap 'cleanup' SIGINT SIGTERM

# Start Icecast in the background
echo "[*] Starting Icecast2..."
/usr/bin/icecast2 -c "/home/container/icecast.xml" &
ICECAST_PID=$!

# Wait a few seconds
echo "[*] Waiting for Icecast to initialize..."
sleep 3

# Start Liquidsoap in the background
echo "[*] Starting Liquidsoap..."
/usr/bin/liquidsoap --verbose "/home/container/radio.liq" &
LIQUIDSOAP_PID=$!

# THIS LINE IS FOR PTERODACTYL: Server is done starting
echo "[AutoDJ Startup]: Server is online and ready!"

# Keep looping as long as both processes are running.
# The 'trap' will interrupt this loop for a clean shutdown.
while kill -0 $ICECAST_PID 2>/dev/null && kill -0 $LIQUIDSOAP_PID 2>/dev/null; do
  sleep 1
done

# If we get here, a process has crashed. Clean up the rest.
echo "[*] One of the main processes stopped unexpectedly. Cleaning up..."
cleanup
