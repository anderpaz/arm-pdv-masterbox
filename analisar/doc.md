# Pacotes necessários para rodar o crossover_24.0.2-1
  gir1.2-atk-1.0  gir1.2-freedesktop  gir1.2-gdkpixbuf-2.0  gir1.2-glib-2.0  gir1.2-gtk-3.0  gir1.2-harfbuzz-0.0  gir1.2-pango-1.0  gir1.2-vte-2.91  libgirepository-1.0-1  libvte-2.91-0  libvte-2.91-common  python3-cairo  python3-dbus  python3-gi  python3-gi-cairo

# Pacotes para abrir o crossover
  libduktape207 libpolkit-agent-1-0 libpolkit-gobject-1-0 pkexec polkitd sgml-base xml-core

# A pasta crossover_win_7 em packages.chroot é para as dependências do crossover win 7 32bit

# Linha para iniciar rápido com problema  de rede
  mkdir -p /etc/systemd/system/networking.service.d
  sudo nano /etc/systemd/system/networking.service.d/timeout.conf
  [Service]
  TimeoutStartSec=5s

