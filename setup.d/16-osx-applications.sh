# Bail if we are not on OSX.
if [[ "$os" != "osx" ]]; then
    echo "warning: cannot setup OSX applications on '${os}', stopping..."
    return 0
fi

apps=('1password'
    'discord'
    'forklift'
    'vagrant'
    'visual-studio-code'
    'vlc'
    'whatsapp'
    'microsoft-teams'
    'tunnelblick'
    'snagit'
    'vivaldi'
    'fork'
    'kaleidoscope'
    'postman'
    'microsoft-remote-desktop'
    'zoom'
    'yed'
    'slack'
    '1password-cli'
    'istats-menu'
    'barrier'
    'raycast'
    'kitty'
    'alacritty'
    'fantastical'
    'rancher'
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

# Check for SSL cert from Barrier, sometimes it doesn't generate
if [[ ! -f ~/Library/Application\ Support/barrier/SSL/Barrier.pem ]]; the 
    mkdir -P ~/Library/Application\ Support/barrier/SSL/Fingerprints
    openssl req -x509 -nodes -days 365 -subj /CN=Barrier -newkey rsa:4096 -keyout ~/Library/Application\ Support/barrier/SSL/Barrier.pem -out ~/Library/Application\ Support/barrier/SSL/Barrier.pem
    openssl x509 -fingerprint -sha1 -noout -in ~/Library/Application\ Support/barrier/SSL/Barrier.pem > ~/Library/Application\ Support/barrier/SSL/Fingerprints/Local.txt
fi
