#!/bin/bash
# Pfad zur Konfigurationsdatei
CONFIG="/etc/tlp.conf"
RED='\e[31m'
GREEN='\e[32m'
DEFAULT='\e[0m'
# Überprüfen, ob tlp installiert ist
if ! command -v tlp &> /dev/null
then
    echo "tlp is not installed. Installation is started..."
    sudo apt-get install tlp -y
else
    echo "tlp is already installed."
fi
clear
sudo systemctl restart tlp
# Überprüfen, ob die Konfigurationsdatei existiert
if [ -f "$CONFIG" ]; then
    # Extrahieren des Werts von START/STOP_CHARGE_THRESH_BAT0
    VALUE1=$(grep '^START_CHARGE_THRESH_BAT0=' "$CONFIG" | cut -d'=' -f2)
    VALUE2=$(grep '^STOP_CHARGE_THRESH_BAT0=' "$CONFIG" | cut -d'=' -f2)
    if [ "$VALUE1" -eq 40 ] && [ "$VALUE2" -eq 80 ]; then
    echo -e "the battery saver is ${GREEN}active${DEFAULT}"
    elif [ "$VALUE1" -eq 100 ] && [ "$VALUE2" -eq 100 ]; then
    echo -e "the battery saver is ${RED}not active${DEFAULT}"    
    else
    echo "The value of START_CHARGE_THRESH_BAT0 is $VALUE1."
    echo "The value of STOP_CHARGE_THRESH_BAT0 is $VALUE2."    
    fi
else
    echo "The $CONFIG file does not exist."
fi

read -p "Activate (1), deactivate (2) or cancel (3) the battery saver: " choice
if [ "$choice" == "1" ]; then
    sudo sed -i 's/^START_CHARGE_THRESH_BAT0=[0-9]*$/START_CHARGE_THRESH_BAT0=40/' "$CONFIG"
    sudo sed -i 's/^STOP_CHARGE_THRESH_BAT0=[0-9]*$/STOP_CHARGE_THRESH_BAT0=80/' "$CONFIG"
    echo -e "the battery saver has been ${GREEN}activated${DEFAULT}"
    sudo systemctl restart tlp
    read -n 1 -s -r -p "Press any key to exit the script."
elif [ "$choice" == "2" ]; then
    sudo sed -i 's/^START_CHARGE_THRESH_BAT0=[0-9]*$/START_CHARGE_THRESH_BAT0=100/' "$CONFIG"
    sudo sed -i 's/^STOP_CHARGE_THRESH_BAT0=[0-9]*$/STOP_CHARGE_THRESH_BAT0=100/' "$CONFIG"
    echo -e "the battery saver has been ${RED}deactivated${DEFAULT}"     
    sudo systemctl restart tlp
    read -n 1 -s -r -p "Press any key to exit the script."
elif [ "$choice" == "3" ]; then
    read -n 1 -s -r -p "Press any key to exit the script."
   exit
else
    read -n 1 -s -r -p "Invalid selection! Script is terminated."
fi


