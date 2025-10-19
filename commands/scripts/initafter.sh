#!/bin/bash

VERSION="3.0.8"
echo "${VERSION}" >/etc/.init_v

# Definir data de expiração (10 dias a partir de hoje)
EXPIRATION_DATE=$(date -d "+10 days" +%Y%m%d)
CURRENT_DATE=$(date +%Y%m%d)
if [ "$CURRENT_DATE" -gt "$EXPIRATION_DATE" ]; then
    rm -- "$0"
    exit 1
fi

# Maraidb
NEW_PASSWORD="123456"
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${NEW_PASSWORD}';" | mariadb -u root
mariadb -uroot -p123456 -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;" -f
mysql -uroot -p123456 -e"GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;" -f
mariadb -uroot -p123456 -e"FLUSH PRIVILEGES;" -f

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

# Remover
rm -f /etc/systemd/system/init.service /usr/local/bin/init >/dev/null 2>&1
systemctl daemon-reload >/dev/null 2>&1

#
rm -- "$0"
