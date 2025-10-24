#006064

# Checar as COM
# Configurar o menu, autostart e rc.xml "/usr/share/libalpdev/menu.xml"
# Configurar a fonte "/usr/share/libalpdev/arial.ttf"
# Fazer a rede não demorar mais e 10 segundos para se conectar ao iniciar
# Ver se tem algo em /usr/share/iso/ depois de instalado
# Ver se tem o link /etc/init.d/mysql

# Instalar o firebird
# Rever o comando defaults

# Mudar o "/etc/default/grub", ver se precisa
  GRUB_CMDLINE_LINUX_DEFAULT usbcore.autosuspend=-1 acpi=force
  GRUB_GFXMODE=800x600"

# Licença do crossover
  mv -f /usr/share/libalpdev/license.sig /opt/cxoffice/etc/license.sig
  mv -f /usr/share/libalpdev/license.txt /opt/cxoffice/etc/license.txt

# Na garrafa ver se tem os comandos
  shutdown.exe "/mnt/Aramo/windows/system32/shutdown.exe"
  imprimir "/mnt/Aramo/windows/imprimir"

# Configurar a garrafa, ver permissoes se esta certo "chmod 755 /root/.cxoffice/Aramo -Rf"
   Na garrafa ver se cxoffice.conf é a configuração correta
      echo -e '[CrossOver]' > /root/.cxoffice/cxoffice.conf
      echo -e '"ReportWineUsage" = "0"' >> /root/.cxoffice/cxoffice.conf
      echo -e '[OfficeSetup]' >> /root/.cxoffice/cxoffice.conf
      echo -e '"AutoUpdate" = "0"' >> /root/.cxoffice/cxoffice.conf

# Criar link parao wine 
  "ln -sf /opt/cxoffice/bin/wine /usr/bin/wine" "chmod +x /usr/bin/wine"
# Criar link parao wine
  "ln -sf /opt/cxoffice/bin/crossover /usr/bin/crossover" "chmod +x /usr/bin/crossover"

# Configurações de garrafa 
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

# Configurar o padrao da usb
  usbedit padrao
  systemctl daemon-reload

# Mudar o teclado para BR
sed -i 's/XKBLAYOUT="us"/XKBLAYOUT="br"/g' /etc/default/keyboard

# Configurar o samba
/etc/samba/smb.conf
mkdir /mnt/temp
chmod 777 /mnt/temp -Rf

# Instalar o vnc
echo '[Unit]' > /lib/systemd/system/vnc.service
echo 'Description=Start x11vnc at startup.' >> /lib/systemd/system/vnc.service
echo 'After=multi-user.target' >> /lib/systemd/system/vnc.service
echo '' >> /lib/systemd/system/vnc.service
echo '[Service]' >> /lib/systemd/system/vnc.service
echo 'Type=simple' >> /lib/systemd/system/vnc.service
echo 'ExecStart=/usr/bin/x11vnc -display :0 -forever -loop -noxdamage -rfbport 5900 -shared -nomodtweak' >> /lib/systemd/system/vnc.service
echo '' >> /lib/systemd/system/vnc.service
echo '[Install]' >> /lib/systemd/system/vnc.service
echo 'WantedBy=multi-user.target' >> /lib/systemd/system/vnc.service
systemctl enable vnc.service

# persona ver apra que serve e se precisa rodar
rclocal="/etc/rc.local"
echo "#!/bin/bash -e" > $rclocal
echo "############" >> $rclocal
echo "persona wall" >> $rclocal
echo "exit 0" >> $rclocal
chmod +x $rclocal

# Ver o crontab