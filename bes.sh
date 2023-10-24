#!/bin/bash
# Constantin CLERC - v0.1b - 24.10.2023

# Variables
flag_file="/Users/etudiant/Library/Application Support/FileWave/.bseFT"
fwapp_path="/usr/local/sbin/FileWave.app/Contents/MacOS/fwcld"
servers=("fwx001.florinfo.ch" "fwx002.florinfo.ch" "fwx003.florinfo.ch" "fwx004.florinfo.ch")
port="20013"
isFCOBlocked="false" # By default, set to false, but if you want to block connection to FLORIMONT-CO, feel free to change it to true. You might need to use a personal hotspot.
# Daemon At-Startup Config/Update (besd)
# Feel free to delete this part if you want to edit the daemon yourself.
curl https://raw.githubusercontent.com/c22dev/BES/main/besd.plist -O
mv -f besd.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/besd.plist
# Moving file script file to home folder
cp -R "bes.sh" "/Users/etudiant/bes.sh"

# First Time ?

if [ ! -e "$flag_file" ]; then
    # tccutil time ! 

    # This is meant to reset preferences of all apps/softwares.
    # Most of them were taken from this Gist : https://gist.github.com/haircut/aeb22c853b0ae4b483a76320ccc8c8e9
    # I could simply have done a "tccutil reset All" but I wanted to be more precise. Feel free to edit code. 
    # This might not work if only ran on first time. An admin user could allow back concerned apps. This might be moved in daemon at-startup run in 0.1c, or be an option in GUI.

    tccutil reset ScreenCapture # Screen Recording
    tccutil reset SystemPolicyAllFiles # Full Disk Access
    tccutil reset SystemPolicyDesktopFolder # Desktop Folder
    tccutil reset SystemPolicyDeveloperFiles # Developer Files
    tccutil reset SystemPolicyDocumentsFolder # Documents Folder
    tccutil reset SystemPolicyNetworkVolumes # Network Volumes
    tccutil reset SystemPolicyRemovableVolumes # Removable Volumes
    tccutil reset SystemPolicySysAdminFiles # System Administration Files
    tccutil reset SystemPolicyDownloadsFolder # Downloads Folder
    tccutil reset KeyboardNetwork # Input Monitoring
    tccutil reset UserTracking # User Data
    tccutil reset SensorKitDeviceUsage # Motion Sensor
    tccutil reset SensorKitKeyboardMetrics # Keyboard Sensor
    tccutil reset SensorKitMouseMetrics # Mouse Sensor
    tccutil reset CoreLocationAgent # Location Services
    tccutil reset FileProviderDomain # Files and Folders1
    tccutil reset FileProviderPresence # Files and Folders2
    tccutil reset Location # Location Services
    tccutil reset Motion # Motion Sensor
    tccutil reset Accessibility # Accessibility
    tccutil reset InputMonitoring # Input Monitoring1
    tccutil reset Keyboard # Input Monitoring2
    launchctl load ~/Library/LaunchAgents/besd.plist # Relaunch daemon if disabled by our modifications

    # Creating flag file (first time ?)
    touch "$flag_file"
    echo "Script is now installed ! Please restart your computer."
    osascript -e 'tell app "System Events" to display dialog "Script is now installed ! Please restart your computer."'
    exit 1
fi

# Script before-loop work
# launchctl time ! (some of these commands might not work)
function launchctl_time {
    launchctl remove com.filewave.fwGUI
    launchctl remove com.promethean.activhardwareservice
    launchctl remove com.promethean.activmgr
}

launchctl_time

launchctl disable user/502/com.filewave.fwGUI
launchctl disable user/502/com.promethean.activhardwareservice
launchctl disable user/502/com.promethean.activmgr


# Network filtering
# This is meant to block all incoming/outgoing connections from/to the FileWave server. Not sure this will work as this could rely on admin privileges.

# Using pfctl app blocking
# First we create the PF rule file
echo "block drop in from any to any app \"$fwapp_path\"" > "/Users/etudiant/Library/Application Support/FileWave/block_app.pf"
echo "block drop out from any to any app \"$fwapp_path\"" >> "/Users/etudiant/Library/Application Support/FileWave/block_app.pf"
# Then we innit pfctl to our new rule file
pfctl -f "/Users/etudiant/Library/Application Support/FileWave/block_app.pf"
# And we enable pfctl
pfctl -e

# Using pfctl server blocking
# Block connexions
for server in "${servers[@]}"; do
    pfctl -t blockedhosts -T add "${server}:${port}"
done

# Fake time for FW to corrupt https and avoid FileWave server connection interval (This might not work for the moment)

# First, we create bin directory for libfaketime if not existing already
if [ ! -d "/Users/etudiant/Library/Printers/.bin/faketime/" ]; then
    mkdir -p "/Users/etudiant/Library/Printers/.bin/faketime/" # Create bin dir within Printers exec dir
    cd /Users/etudiant/ # Go to home dir if not already
    mkdir tmp && cd tmp # Create tmp dir and go to it
    curl -LOk https://github.com/c22dev/BES/raw/main/libfaketime.zip # Download libfaketime
    unzip libfaketime.zip # Unzip libfaketime
    chmod +x libfaketime.1.dylib # Make libfaketime executable
    chmod +x faketime # Make faketime executable
    xattr -d com.apple.quarantine libfaketime.1.dylib # Remove quarantine attribute
    xattr -d com.apple.quarantine faketime # Remove quarantine attribute
    mv faketime "/Users/etudiant/Library/Printers/.bin/faketime/" # Move faketime to bin dir
    mv libfaketime.1.dylib "/Users/etudiant/Library/Printers/.bin/faketime/" # Move libfaketime to bin dir
    cd ../ # Go back to home dir
    rm -rf tmp # Remove tmp dir
fi

# Next, we type in commands to fake time. We need to add faketime to path because lib may not be found
export PATH="/Users/etudiant/Library/Printers/.bin/faketime/:$PATH" # Add bin dir to path
export DYLD_FORCE_FLAT_NAMESPACE=1 # Force flat namespace
export DYLD_INSERT_LIBRARIES="/Users/etudiant/Library/Printers/.bin/faketime/libfaketime.1.dylib" # Add libfaketime to path
export FAKETIME="2008-12-24 08:15:42" # Add faketime spec to path
cd /Users/etudiant/Library/Printers/.bin/faketime/ # Go to bin dir
./faketime '2008-12-24 08:15:42' /usr/local/sbin/FileWave.app/Contents/MacOS/fwcld # Fake time for FileWave
cd /Users/etudiant/ # Go back to home dir

# Loop kill user level processes (FileWave GUI, Active Manager) - This is kinda useless, might be removed in the future.
while :; do
    process=$(ps aux | grep "fwGUI" | grep -v grep) # Get all running processes but extract process called fwGUI
    if [ -n "$process" ]; then # If process is not empty
        pid=$(echo "$process" | awk '{print $2}') # Get process PID
        echo "Killing process $pid" 
        kill -9 "$pid" # Kill process (by it's PID)
    fi
    process=$(ps aux | grep "activmgr" | grep -v grep)
    if [ -n "$process" ]; then
        pid=$(echo "$process" | awk '{print $2}')
        echo "Killing process $pid"
        kill -9 "$pid"
    fi
    process=$(ps aux | grep "activhardwareservice" | grep -v grep)
    if [ -n "$process" ]; then
        pid=$(echo "$process" | awk '{print $2}')
        echo "Killing process $pid"
        kill -9 "$pid"
    fi
    process=$(ps aux | grep "fwcld" | grep -v grep)
    if [ -n "$process" ]; then
        pid=$(echo "$process" | awk '{print $2}')
        echo "Killing process $pid"
        kill -9 "$pid"
    fi
    launchctl_time
    if [ "$isFCOBlocked" = "true" ]; then # If you want this to work, you need to set isFCOBlocked to true. This is meant to block any connection to FLORIMONT-CO network.
        if /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep -i "SSID: FLORIMONT-CO"; then
            networksetup -setairportpower Wi-Fi off # Here, we disable Wi-Fi if connected to Florimont-CO. This is disabled as it might be annoying. 
        fi
    fi  
    sleep 1
done
