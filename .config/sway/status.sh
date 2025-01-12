#!/bin/bash

while true; do
	TEMP=$(($(cat /sys/class/thermal/thermal_zone*/temp | sort -n | tail -n 1) / 1000));
	BATERRY=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | cut -d':' -f2 | awk '{$1=$1};1')
	BATTERY_NUM=${BATERRY::-1}
	SECONDS=$(date +%s)
	((BATTERY_NUM < 15 && SECONDS % 2)) &&\
		[ $(cat /sys/class/power_supply/BAT0/status) != "Charging" ] &&\
			BATERRY="!!battery too low!!"
	TIME=$(date +'%Y-%m-%d %X')
	echo "impl Temp<$TEMP'C> + Bat<$BATERRY> + Time<$TIME>"
	sleep 1
done
