# Stop Connman
/etc/init.d/connman stop

# Avvia D-Bus
/etc/init.d/dbus-1 start

pkill wpa
pkill udhcp

# Copy configuration file
cp /home/root/wpa_supplicant.conf /etc/

# Configura l'interfaccia WiFi
ifconfig wlan0 up

# echo "Eseguo WPA-supplicant"
# # Esegui wpa_supplicant
# wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant.conf -d -D wext

# Restart wlan0
ifup wlan0

# Get IP address
sleep 1
udhcpc -i wlan0


