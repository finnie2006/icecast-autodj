#!/bin/bash

# Definieer de opruim-functie
cleanup() {
    echo "[*] Stopsignaal ontvangen, bezig met afsluiten..."
    
    # Stuur eerst een vriendelijk TERM-signaal
    kill -SIGTERM $LIQUIDSOAP_PID 2>/dev/null
    kill -SIGTERM $ICECAST_PID 2>/dev/null
    
    # Geef de processen 2 seconden de tijd om netjes af te sluiten
    sleep 2
    
    # Controleer of er nog processen draaien en forceer ze dan te stoppen
    echo "[*] Controleren op koppige processen..."
    if kill -0 $ICECAST_PID 2>/dev/null; then
        echo "[!] Icecast (PID $ICECAST_PID) luisterde niet, bezig met geforceerd afsluiten (SIGKILL)..."
        kill -SIGKILL $ICECAST_PID 2>/dev/null
    fi
    if kill -0 $LIQUIDSOAP_PID 2>/dev/null; then
        echo "[!] Liquidsoap (PID $LIQUIDSOAP_PID) luisterde niet, bezig met geforceerd afsluiten (SIGKILL)..."
        kill -SIGKILL $LIQUIDSOAP_PID 2>/dev/null
    fi
    
    echo "[*] Alle processen zijn afgesloten."
    exit 0
}

# Zet een 'trap' op de signalen SIGINT en SIGTERM
trap 'cleanup' SIGINT SIGTERM

# Start Icecast op de achtergrond
echo "[*] Starting Icecast2..."
/usr/bin/icecast2 -c "/home/container/icecast.xml" &
ICECAST_PID=$!

# Wacht een paar seconden
echo "[*] Waiting for Icecast to initialize..."
sleep 3

# Start Liquidsoap op de achtergrond
echo "[*] Starting Liquidsoap..."
/usr/bin/liquidsoap --verbose /home/container/radio.liq &
LIQUIDSOAP_PID=$!

# DEZE REGEL IS VOOR PTERODACTYL: Server is klaar met opstarten
echo "[AutoDJ Startup]: Server is online and ready!"

# Blijf in een loop zolang beide processen nog draaien.
# De 'trap' zal deze loop onderbreken voor een nette shutdown.
while kill -0 $ICECAST_PID 2>/dev/null && kill -0 $LIQUIDSOAP_PID 2>/dev/null; do
  sleep 1
done

# Als we hier komen, is een proces gecrasht. Ruim de rest ook op.
echo "[*] Een van de hoofdprocessen is onverwacht gestopt. Bezig met opruimen..."
cleanup
