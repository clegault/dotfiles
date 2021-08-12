# Bail if we are not on OSX.
if [[ "$os" != "osx" ]]; then
    echo "warning: cannot setup OSX applications on '${os}', stopping..."
    return 0
fi

apps=('lastpass'
    'docker'
    'dropbox'
    'alacritty'
    'discord'
    'spotmenu'
    'spotify'
    'forklift'
    'vagrant'
    'virtualbox'
    'visual-studio-code'
    'vlc'
    'whatsapp'
    'font-hack-nerd-font'
    'font-mononoki-nerd-font '
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

brew tap homebrew/cask
brew tap homebrew/cask-fonts
for app in "${apps[@]}"; do
    if ask "$os: Install Application '${app}'?" N; then
        brew install ${app}
    fi
done

# Install Linux apps.
apps=('coreutils'
    'findutils'
    'gawk'
    'gnu-indent'
    'gnu-sed'
    'gnu-tar'
    'gnutls'
    'grep'
    'telnet'
    'ossp-uuid' # uuid linux tool
    'tree'
    'wget'
)
for app in ${apps[@]}; do
    $os: Install tool '${app}'"
    brew install ${app}
done
