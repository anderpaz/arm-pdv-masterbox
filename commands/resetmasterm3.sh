#!/bin/bash
############################################################################################################################

pkill -HUP MasterBox
pkill -HUP MASTERBOX
if [ ! -z $1 ]; then
	if [ $1 == 'kill' ]; then
		pkill -HUP MasterBox
		pkill -HUP MASTERBOX
		exit 0
	fi
fi
mnreset
numlockx on
cd /root/.cxoffice/Aramo/drive_c/MASTERBOX/
nice -20 /opt/cxoffice/bin/wine explorer /desktop=800x600 "/root/.cxoffice/Aramo/drive_c/MASTERBOX/MasterBox.exe" &
confset setser
#
exit 0
