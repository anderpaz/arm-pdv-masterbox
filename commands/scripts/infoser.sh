#!/bin/bash
arq="/tmp/.serial"
setserial -g /dev/ttyS* | cut -d "/" -f 3-10 | grep -v 'unknown' > $arq
sed -i 's/ttyS0/COM1, ttyS0/g' $arq && sed -i 's/ttyS1/COM2, ttyS1/g' $arq && sed -i 's/ttyS2/COM3, ttyS2/g' $arq && sed -i 's/ttyS3/COM4, ttyS3/g' $arq
sed -i 's/ttyS4/COM5, ttyS4/g' $arq && sed -i 's/ttyS5/COM6, ttyS5/g' $arq && sed -i 's/ttyS6/COM7, ttyS6/g' $arq && sed -i 's/ttyS7/COM8, ttyS7/g' $arq
sed -i 's/ttyS8/COM9, ttyS8/g' $arq && sed -i 's/ttyS9/COM10, ttyS9/g' $arq && sed -i 's/ttyS10/COM11, ttyS10/g' $arq && sed -i 's/ttyS11/COM12, ttyS11/g' $arq
port=$(cat $arq)
yad --center --height=10 --width=410 --title " Portas Serial"  --text "\n<b><big> Portas localizadas:</big></b>:\n\n$port" --button="gtk-close:1" --image="insert-link"
