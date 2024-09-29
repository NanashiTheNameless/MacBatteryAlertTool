#!/bin/bash

# This is from https://github.com/NanashiTheNameless/MacBatteryAlertTool
# It is licensed under https://github.com/NanashiTheNameless/MacBatteryAlertTool/blob/main/license.md

# Variables
SCRIPT_PATH="/Users/$USER/Library/Scripts/batt.sh"
PLIST_PATH="/Users/$USER/Library/LaunchAgents/batt.plist"
LAUNCHAGENTS_DIR="/Users/$USER/Library/LaunchAgents"
SCRIPTS_DIR="/Users/$USER/Library/Scripts"

# Create the directories if they don't exist
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$LAUNCHAGENTS_DIR"

# Write the bash script to the batt.sh file
cat << 'EOF' > "$SCRIPT_PATH"
#!/bin/bash

timeInbetweenAlerts=30
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
EOF

# Make the script executable
chmod +x "$SCRIPT_PATH"

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

# Use sed to replace <!!!SCRIPT PATH HERE!!!> with the actual script path
sed -i "" "s|<!!!SCRIPT PATH HERE!!!>|$SCRIPT_PATH|g" "$PLIST_PATH"

# Load the plist to launchd
launchctl load "$PLIST_PATH"

echo "Battery alert script and LaunchAgent have been successfully set up!"