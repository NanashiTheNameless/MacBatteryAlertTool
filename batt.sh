#!/bin/bash

timeInbetweenAlerts=10
batteryPercentAlert=15

# This is from https://github.com/NanashiTheNameless/BatteryAlertTool
# It is licensed under https://github.com/NanashiTheNameless/BatteryAlertTool/blob/main/license.md

while true; do
    if [[ "$(uname)" == "Darwin" ]]; then
        if pmset -g batt | head -n 1 | grep -q "Battery" && [ $(pmset -g batt | grep -o '[0-9]\{1,3\}%' | tr -d '%') -le $batteryPercentAlert ]; then
            afplay /System/Library/Sounds/Funk.aiff
            sleep $timeInbetweenAlerts
        fi
    else
        batteryInfo=$(upower -i $(upower -e | grep BAT))
        batteryPercent=$(echo "$batteryInfo" | grep -oP 'percentage:\s+\K\d+')
        chargingState=$(echo "$batteryInfo" | grep -oP 'state:\s+\K\w+')

        if [[ "$chargingState" == "discharging" && $batteryPercent -le $batteryPercentAlert ]]; then
            paplay /usr/share/sounds/common/battery-low.ogg
            sleep $timeInbetweenAlerts
        fi
    fi

    sleep 1
done