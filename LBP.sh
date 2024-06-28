#!/bin/bash
# Pfad zur Konfigurationsdatei
CONFIG="/etc/tlp.conf"
RED='\e[31m'
GREEN='\e[32m'
DEFAULT='\e[0m'
# Überprüfen, ob tlp installiert ist
if ! command -v tlp &> /dev/null
then
    echo "tlp ist nicht installiert. Installation wird gestartet..."
    sudo apt-get install tlp -y
else
    echo "tlp ist bereits installiert."
fi
clear
sudo systemctl restart tlp
# Überprüfen, ob die Konfigurationsdatei existiert
if [ -f "$CONFIG" ]; then
    # Extrahieren des Werts von START/STOP_CHARGE_THRESH_BAT0
    VALUE1=$(grep '^START_CHARGE_THRESH_BAT0=' "$CONFIG" | cut -d'=' -f2)
    VALUE2=$(grep '^STOP_CHARGE_THRESH_BAT0=' "$CONFIG" | cut -d'=' -f2)
    if [ "$VALUE1" -eq 40 ] && [ "$VALUE2" -eq 80 ]; then
    echo -e "der Akkuschoner ist ${GREEN}aktiv${DEFAULT}"
    elif [ "$VALUE1" -eq 100 ] && [ "$VALUE2" -eq 100 ]; then
    echo -e "der Akkuschoner ist ${RED}nicht aktiv${DEFAULT}"    
    else
    echo "Der Wert von START_CHARGE_THRESH_BAT0 ist $VALUE1."
    echo "Der Wert von STOP_CHARGE_THRESH_BAT0 ist $VALUE2."    
    fi
else
    echo "Die Datei $CONFIG existiert nicht."
fi

read -p "Akkuschoner aktivieren (1), deaktivieren (2) oder abbrechen (3): " choice
if [ "$choice" == "1" ]; then
    sudo sed -i 's/^START_CHARGE_THRESH_BAT0=[0-9]*$/START_CHARGE_THRESH_BAT0=40/' "$CONFIG"
    sudo sed -i 's/^STOP_CHARGE_THRESH_BAT0=[0-9]*$/STOP_CHARGE_THRESH_BAT0=80/' "$CONFIG"
    echo -e "der Akkuschoner wurde ${GREEN}aktiviert${DEFAULT}"
    sudo systemctl restart tlp
    read -n 1 -s -r -p "Drücken Sie eine beliebige Taste, um das Skript zu beenden."
elif [ "$choice" == "2" ]; then
    sudo sed -i 's/^START_CHARGE_THRESH_BAT0=[0-9]*$/START_CHARGE_THRESH_BAT0=100/' "$CONFIG"
    sudo sed -i 's/^STOP_CHARGE_THRESH_BAT0=[0-9]*$/STOP_CHARGE_THRESH_BAT0=100/' "$CONFIG"
    echo -e "der Akkuschoner wurde ${RED}deaktiviert${DEFAULT}"     
    sudo systemctl restart tlp
    read -n 1 -s -r -p "Drücken Sie eine beliebige Taste, um das Skript zu beenden."
elif [ "$choice" == "3" ]; then
    read -n 1 -s -r -p "Drücken Sie eine beliebige Taste, um das Skript zu beenden."
   exit
else
    read -n 1 -s -r -p "Ungültige Auswahl! Script wird beendet."
fi


