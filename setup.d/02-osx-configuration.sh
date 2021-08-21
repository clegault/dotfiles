# Perform MacOSX Dock Configuration.
if [[ "$os" != "osx" ]]; then
    echo "warning: cannot setup OSX configuration on '${os}', stopping..."
    return 0
fi

echo "Standardise Dock Configuration?"
# Set my preferred dock size and enable magnification.
defaults write com.apple.dock tilesize -int 32
defaults write com.apple.dock largesize -float 64
defaults write com.apple.dock magnification -bool true

# Only show apps which are open, rather than shortcuts.
defaults write com.apple.dock static-only -bool true

# Restart the dock.
killall Dock

echo  "Showing hidden files and folders" 
defaults write com.apple.finder AppleShowAllFiles -bool true; killall Finder

echo "Showing the path bar in Finder"
defaults write com.apple.finder ShowPathbar -bool true; killall Finder

echo "Showing all drives, connected servers and removable media on desktop in Finder"
# Set the finder settings
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true

# Restart the Finder.
killall -HUP Finder

echo "Setting up 'reattach-to-user-namespace' to allow proper clipboard support in the shell"
brew install reattach-to-user-namespace

#Turn on remote desktop features
if ask "$os: Would you like to turn on Screen Sharing?" N; then
    sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool false
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
fi

#Turn on remote login features
if ask "$os: Would you like to turn on remote login (SSH)?" N; then
    sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users admin -privs -all -restart -agent -menu
fi

#Turn on fileshare features
if ask "$os: Would you like to turn on File Sharing?" N; then
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.smbd.plist
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist EnabledServices -array disk
fi

# Get the current computer name and ask if the user wants to change it.
if ask "$os: Would you like to run through the computer name changes?" N; then
    computer_name=$(scutil --get ComputerName)
    if ask "$os: Computer name is '${computer_name}', would you like to change it?" N; then
        echo -n "Enter the new computer name: "
        read new_computer_name
        scutil --set ComputerName "${new_computer_name}"
    fi

    # Get the current host name and ask if the user wants to change it.
    host_name=$(scutil --get HostName)
    if ask "$os: Host name is '${host_name}', would you like to change it?" N; then
        echo -n "Enter the new host name (no spaces): "
        read new_host_name
        scutil --set HostName "${new_host_name}"
    fi

    # Get the current local host name and ask if the user wants to change it.
    local_host_name=$(scutil --get LocalHostName)
    if ask "$os: Local Host name is '${local_host_name}', would you like to change it?" N; then
        echo -n "Enter the new local host name (no spaces): "
        read new_local_host_name
        scutil --set LocalHostName "${new_local_host_name}"
    fi
fi