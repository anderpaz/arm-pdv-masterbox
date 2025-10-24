#!/bin/bash

VERSION="3.0.5"

cat > /etc/version <<EOF
Version: ${VERSION}
Debian: 12
Architecture: amd64
Develop: Anderson Paz
Email: anderluizpaz@gmail.com
EOF

# Definir data de expiração (10 dias a partir de hoje)
EXPIRATION_DATE=$(date -d "+10 days" +%Y%m%d)
CURRENT_DATE=$(date +%Y%m%d)
if [ "$CURRENT_DATE" -gt "$EXPIRATION_DATE" ]; then
    rm -- "$0"
    exit 1
fi

# Maraidb
NEW_PASSWORD="152100"
# Muda a senha do root corretamente (usa a senha atual)
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${NEW_PASSWORD}';" | mariadb -u root
# Sá acesso total
mysql -uroot -p"${NEW_PASSWORD}" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;" -f
mysql -uroot -p"${NEW_PASSWORD}" -e"GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '152100' WITH GRANT OPTION;" -f
mysql -uroot -p"${NEW_PASSWORD}" -e"FLUSH PRIVILEGES;" -f

# Interfaces de rede
INTERFACES_DIR="/etc/network/interfaces.d"
mkdir -p "$INTERFACES_DIR"

INTERFACES=$(ip -o link show | awk -F': ' '$2 !~ "lo" {print $2}')
counter=0

for IFACE in $INTERFACES; do
    CONFIG_FILE="$INTERFACES_DIR/$IFACE"

    if [ $counter -eq 0 ]; then
        echo "auto $IFACE" >"$CONFIG_FILE"
        echo "iface $IFACE inet static" >>"$CONFIG_FILE"
        echo "address 10.10.10.10" >>"$CONFIG_FILE"
        echo "netmask 255.255.255.0" >>"$CONFIG_FILE"
        ifup $IFACE
    else
        echo "auto $IFACE" >"$CONFIG_FILE"
        echo "iface $IFACE inet dhcp" >>"$CONFIG_FILE"
    fi
    counter=$((counter + 1))
done

# Sources
SOURCES_FILE="/etc/apt/sources.list"
echo "# Default repositories for Debian Bookworm\n" >"$SOURCES_FILE"
echo "deb http://deb.debian.org/debian bookworm main contrib" >>"$SOURCES_FILE"
echo "deb http://deb.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" >>"$SOURCES_FILE"

# Configurar a garrafa do Crossover
ln -sf /root/.cxoffice/Aramo/drive_c/ /mnt/Aramo
ln -sf /root/.cxoffice/Aramo /root/.cxoffice/default
ln -sf /dev/ttyS0 /root/.cxoffice/Aramo/dosdevices/com1
ln -sf /dev/ttyS1 /root/.cxoffice/Aramo/dosdevices/com2
ln -sf /dev/ttyS2 /root/.cxoffice/Aramo/dosdevices/com3
ln -sf /dev/ttyS3 /root/.cxoffice/Aramo/dosdevices/com4
ln -sf /dev/ttyS4 /root/.cxoffice/Aramo/dosdevices/com5
ln -sf /dev/ttyS5 /root/.cxoffice/Aramo/dosdevices/com6
ln -sf /dev/ttyS6 /root/.cxoffice/Aramo/dosdevices/com7
ln -sf /dev/usbPinPad /root/.cxoffice/Aramo/dosdevices/com8
ln -sf /dev/usbBal /root/.cxoffice/Aramo/dosdevices/com9
ln -sf /dev/usbEcf /root/.cxoffice/Aramo/dosdevices/com10/
ln -sf /dev/sr0 /root/.cxoffice/Aramo/dosdevices/d::
ln -sf ../drive_c/ /root/.cxoffice/Aramo/dosdevices/c:
ln -sf /root/ /root/.cxoffice/Aramo/dosdevices/y:
ln -sf / /root/.cxoffice/Aramo/dosdevices/z:

# Configurar o Masterbox
usbedit padrao
backuppdv criamdb

# Remover
rm -f /etc/systemd/system/init.service /usr/local/bin/init >/dev/null 2>&1
systemctl daemon-reload >/dev/null 2>&1

#
rm -- "$0"
