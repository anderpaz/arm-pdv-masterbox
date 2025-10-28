#!/bin/bash
openconf="/etc/xdg/openbox/autostart"
opendir="/etc/xdg/openbox"
grubconf="/etc/default/grub"
###################################################

configm5() {


	mv $opendir/autostart $opendir/oldautostart
	echo "/usr/bin/xset -dpms s off" > $openconf
	echo "xset s off s noblank dpms 0 0 0" >> $openconf
	echo "xrandr -s 1024x768 -r 60" >> $openconf
	echo "numlockx" >> $openconf
	echo "resetmaster &" >> $openconf
	sed -i 's/GRUB_GFXMODE=800x600/GRUB_GFXMODE=1024x768/' $grubconf
	update-grub > /dev/null 2>&1
    init 6

}
configm3() {

    mv $opendir/autostart $opendir/oldautostart
	echo "/usr/bin/xset -dpms s off" > $openconf
	echo "xset s off s noblank dpms 0 0 0" >> $openconf
	echo "xrandr -s 800x600 -r 60" >> $openconf
	echo "numlockx" >> $openconf
	echo "resetmaster &" >> $openconf
	sed -i 's/GRUB_GFXMODE=1024x768/GRUB_GFXMODE=800x600/' $grubconf
	update-grub > /dev/null 2>&1
    init 6

}
case $1 in
	m5)
	configm5
	;;
	m3)
	configm3
	;;
esac
