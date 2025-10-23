sed -i 's/enabled=True/enabled=False/g' /etc/xdg/user-dirs.conf # não cria pasta de usuario

## Já esta logando na interface grafica
echo >> /root/.bashrc
echo '#' >> /root/.bashrc
echo 'if [ "$(echo $(tty))" == "/dev/tty1" ]; then' >> /root/.bashrc
echo '	startx'  >> /root/.bashrc
echo 'fi' >> /root/.bashrc

## já loga como root
sed -i 's\^ExecStart.*\ExecStart=-/sbin/agetty --autologin root --noclear %I 38400 linux\' /etc/systemd/system/getty.target.wants/getty\@tty1.service

## removi o ps, ele subistitui o coamndo ps
echo -e '#!/bin/bash' > /usr/bin/ps
echo -e '/bin/ps $* | /bin/grep -v "yad" | /bin/grep -v "/usr/bin/ps" | /bin/grep -v "wine"' >> /usr/bin/ps
chmod +x /usr/bin/ps

# alterar a tecla numlock ver se precisa disso mesmo
echo -e 'keycode 77 = NoSymbol Num_Lock' > /root/.Xmodmap
echo -e 'clear Lock' >> /root/.Xmodmap

# Removi o tema persona_circle e não configurei

# Removi esses pacotes
libc6-i386
libgtk2.0-0:i386
libxml2:i386
libncursesw6:i386
libmariadb-dev-compat:i386
libsqlite3-0:i386