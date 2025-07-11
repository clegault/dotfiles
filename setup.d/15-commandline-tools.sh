# We refer to this global ag ignore file in the shell.d/aliases.sh file,
# because `ag` is an alias for using `ag` with this file.
ensure_symlink "$(pwd)/ag/agignore" "$HOME/.ignore"

# Install Linux apps on osx.
if [[ "$os" == "osx" ]]; then
    brew tap homebrew/cask
    brew tap homebrew/cask-fonts
    apps=('font-hack-nerd-font'
        'font-mononoki-nerd-font'
        'coreutils'
        'fzf'
        'grc'
        'tldr'
        'the_silver_searcher'
        'fswatch'
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
        'kubernetes-cli'
        'git'
        'btop'
        'ripgrep'
        'duf'
        'autojump'
        'ranger'
        'lukechilds/tap/gifgen'
        'neofetch'
        'thefuck'
        'pv'
        'eza'
        'bat'
        'watch'
        'htop'
        'git-who'
    )
    for app in ${apps[@]}; do
        echo "$os: Installing tool '${app}'"
        brew install ${app}
    done
    $(brew --prefix)/opt/fzf/install -all
    pip3 install ntfy
elif [[ "$os" == "ubuntu" ]]; then
    apps=('silversearcher-ag'
        'fzf'
        'grc'
        'tldr'
        'tree'
        'ansible'
        'ripgrep'
        'autojump'
        'ranger'
        'neofetch'
        'btop'
        'duf'
        'pv'
        'bat'
        'eza'
    )
    # add support for eza installation
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    for app in ${apps[@]}; do
        echo "$os: Installing tool '${app}'"
        sudo apt install -y ${app}
    done
    sudo pip3 install thefuck
    mkdir /tmp/dotfiles
    cd /tmp/dotfiles
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    if echo "$(cat kubectl.sha256) kubectl" | sha256sum --check --status; then
        echo "Checksum is valid"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    else
        echo "Checksum is invalid"
        echo "You will need to install kubectl manually"
    fi
    cd -
    rm -rf /tmp/dotfiles
    ensure_symlink "$(pwd)/zsh/selected-editor" "$HOME/.selected-editor"
    sudo sed -i '/^[^#]/s/^/# /' /etc/update-motd.d/00-header /etc/update-motd.d/10-help-text /etc/update-motd.d/50-landscape-sysinfo
    echo "exec /usr/bin/neofetch" | sudo tee -a /etc/update-motd.d/00-header > /dev/null
else
    echo "Probably installing in a container, not installing extra tools. Stoping..."
fi
