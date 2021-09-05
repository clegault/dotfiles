# Bail if we are not on OSX.
if [[ "$os" != "osx" ]]; then
    echo "warning: cannot setup OSX applications on '${os}', stopping..."
    return 0
fi

apps=('1password'
    'discord'
    'spotmenu'
    'forklift'
    'vagrant'
    'visual-studio-code'
    'vlc'
    'whatsapp'
    'microsoft-teams'
    'alfred'
    'tunnelblick'
    'snagit'
    'firefox'
    'brave'
    'fork'
    'kaleidoscope'
    'postman'
    'microsoft-remote-desktop'
    'zoom'
    'yed'
    'slack'
    '1password-cli'
    'mas'
)

intelonlyapps=(
    'multipass'
    'keybase'
    'virtualbox'
)
# Note that I no longer install the following apps - they are installed by the
# enterprise profile:
# - slack

for app in "${apps[@]}"; do
    if [[ $1 == "-auto" ]] || $ask "$os: Install Application '${app}'?" N; then
        brew install ${app}
    fi
done
if [[ $type != 'osx-arm' ]]; then
    for app in "${intelonlyapps[@]}"; do
        if [[ $1 == "-auto" ]] || $ask "$os: Install Application '${app}'?" N; then
            brew install ${app}
        fi
    done
fi