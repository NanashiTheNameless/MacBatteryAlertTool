#!/bin/bash

# This is from https://github.com/NanashiTheNameless/BatteryAlertTool
# It is licensed under https://github.com/NanashiTheNameless/BatteryAlertTool/blob/main/license.md

if [[ "$(uname)" == "Darwin" ]]; then
    # Darwin Variables
    SCRIPT_PATH="/Users/$USER/Library/Scripts/batt.sh"
    PLIST_PATH="/Users/$USER/Library/LaunchAgents/batt.plist"
    LAUNCHAGENTS_DIR="/Users/$USER/Library/LaunchAgents"
    SCRIPTS_DIR="/Users/$USER/Library/Scripts"
else
    # Linux Variables
    SCRIPT_PATH="/home/$USER/bin/batteryReminder"
    SCRIPTS_DIR="/home/$USER/bin"
fi

# Create the directories if they don't exist
if [[ "$(uname)" == "Darwin" ]]; then
    mkdir -p "$LAUNCHAGENTS_DIR"
fi
mkdir -p "$SCRIPTS_DIR"

function script() {
# Write the bash script to the batt.sh file
cat << 'EOF' > "$SCRIPT_PATH"
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
EOF
}

function plist() {
# Write the plist file to start the script automatically
cat << EOF > "$PLIST_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>batt</string>
    <key>ProgramArguments</key>
    <array>
        <string>sh</string>
        <string><!!!SCRIPT PATH HERE!!!></string>
    </array>
    <key>StartInterval</key>
    <integer>1</integer>
</dict>
</plist>
EOF
}

if [[ "$(uname)" == "Darwin" ]]; then

    script
    plist

    # Use sed to replace <!!!SCRIPT PATH HERE!!!> with the actual script path
    sed -i "" "s|<!!!SCRIPT PATH HERE!!!>|$SCRIPT_PATH|g" "$PLIST_PATH"

    # Load the plist to launchd
    launchctl load "$PLIST_PATH"
else
    script

    if [ ! -f "/usr/share/sounds/common/battery-low.ogg" ]; then
    sudo mkdir -p /usr/share/sounds/common
    sudo wget -q -O "/usr/share/sounds/common/battery-low.ogg" "https://github.com/NanashiTheNameless/BatteryAlertTool/raw/refs/heads/main/battery-low.ogg"
    fi

    echo "You now need to add $SCRIPT_PATH to run on start, this can be done with a tool like \"crontab -e\" or something similar"
    echo "You can replace \"/usr/share/sounds/common/battery-low.ogg\" with the preferred alert sound of your choice!"
fi

# Make the script executable
if [ ! -x "$SCRIPT_PATH" ]; then
    echo "$SCRIPT_PATH is not executable. Attempting to add execute permission."
    chmod +x "$SCRIPT_PATH"
    if [ ! -x "$SCRIPT_PATH" ]; then
        echo "$SCRIPT_PATH is not executable after trying to add permissions, now trying with sudo."
        sudo chmod +x "$SCRIPT_PATH"
        if [ ! -x "$SCRIPT_PATH" ]; then
            echo "$SCRIPT_PATH is still not executable after trying to add permissions with sudo. Something is very wrong, This likely needs to be fixed manually!"
            echo "Try running \"sudo chmod +x $SCRIPT_PATH\" or \"chmod +x $SCRIPT_PATH\" as root"
            exit 1
        else
            echo "$SCRIPT_PATH is now executable."
        fi
    else
        echo "$SCRIPT_PATH is now executable."
    fi
else
    echo "$SCRIPT_PATH is already executable."
fi

if [[ "$(uname)" == "Darwin" ]]; then
    echo "Battery alert script and LaunchAgent have been successfully set up!"
else
    echo "Battery alert script successfully added to $SCRIPT_PATH!"
fi
