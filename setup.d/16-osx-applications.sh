# Bail if we are not on OSX.
if [[ "$os" != "osx" ]]; then
    echo "warning: cannot setup OSX applications on '${os}', stopping..."
    return 0
fi

apps=('lastpass'
    'discord'
    'spotmenu'
    'forklift'
    'vagrant'
    'virtualbox'
    'visual-studio-code'
    'vlc'
    'whatsapp'
    'microsoft-teams'
    'alfred'
    'tunnelblick'
    'snagit'
    'multipass'
    'firefox'
    'fork'
    'kaleidoscope'
    'postman'
    'microsoft-remote-desktop'
    'zoom'
    'yed'
    'keybase'
    'slack'
)
# Note that I no longer install the following apps - they are installed by the
# enterprise profile:
# - slack

for app in "${apps[@]}"; do
    if ask "$os: Install Application '${app}'?" N; then
        brew install ${app}
    fi
done
