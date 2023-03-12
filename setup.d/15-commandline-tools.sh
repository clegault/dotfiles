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
    )
    for app in ${apps[@]}; do
        echo "$os: Installing tool '${app}'"
        brew install ${app}
    done
    $(brew --prefix)/opt/fzf/install -all
    sudo gem install colorls
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
    )
    for app in ${apps[@]}; do
        echo "$os: Installing tool '${app}'"
        sudo apt install -y ${app}
    done
    sudo pip3 install thefuck
    sudo gem install colorls
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    # btop installation
    sudo snap install btop
    #duf installation:
    mkdir /tmp/dotfiles
    cd /tmp/dotfiles
    curl -s https://api.github.com/repos/muesli/duf/releases/latest | grep -o "https://.*\.amd64\.deb" | xargs curl -fsLJO
    sudo dpkg --install ./*.deb
    cd
    rm -rf /tmp/dotfiles
else
    echo "Probably installing in a container, not installing extra tools. Stoping..."
fi