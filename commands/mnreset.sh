#!/bin/bash
while :
do
	/bin/ps -aux |grep yad | awk '{print $2}' | xargs kill -9
	wmctrl -c "MENU - PDV"
	if [ $(wmctrl -l |wc -l) -lt 1 ]; then
		break
	else
		for w in $(wmctrl -l | cut -d" " -f1); do
			wmctrl -i -c $w
		done
		/bin/ps -aux |grep yad | awk '{print $2}' | xargs kill -9
		wmctrl -c "MENU - PDV"
	fi
done
