#!/bin/bash
############################################################################

setser() {

    if [[ -e /etc/setser ]]; then
        echo "FEITO" >> /etc/setser
	else
        ln -sf /dev/ttyS0 /root/.cxoffice/Aramo/dosdevices/com1
        ln -sf /dev/ttyS1 /root/.cxoffice/Aramo/dosdevices/com2
        ln -sf /dev/ttyS2 /root/.cxoffice/Aramo/dosdevices/com3
        ln -sf /dev/ttyS3 /root/.cxoffice/Aramo/dosdevices/com4
        ln -sf /dev/ttyS4 /root/.cxoffice/Aramo/dosdevices/com5
        ln -sf /dev/ttyS5 /root/.cxoffice/Aramo/dosdevices/com6
        ln -sf /dev/ttyS6 /root/.cxoffice/Aramo/dosdevices/com7
        ln -sf /dev/usbPinPad /root/.cxoffice/Aramo/dosdevices/com8
        ln -sf /dev/usbBal /root/.cxoffice/Aramo/dosdevices/com9
        ln -sf /dev/usbEcf /root/.cxoffice/Aramo/dosdevices/com10
        touch /etc/setser
	fi

}

############################################################################

case $1 in
	setser)
		setser
	;;
esac