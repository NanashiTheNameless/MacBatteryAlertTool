#!/bin/bash

timeInbetweenAlerts=10
batteryPercentAlert=15

# This is from https://github.com/NanashiTheNameless/MacBatteryAlertTool
# It is licensed under https://github.com/NanashiTheNameless/MacBatteryAlertTool/blob/main/license.md

while true; do
    if pmset -g batt | head -n 1 | grep -q "Battery" && [ $(pmset -g batt | grep -o '[0-9]\{1,3\}%' | tr -d '%') -le $batteryPercentAlert ]; then
        afplay /System/Library/Sounds/Funk.aiff
        sleep $timeInbetweenAlerts
    fi
    sleep 0.1
done