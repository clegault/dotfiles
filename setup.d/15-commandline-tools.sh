# We refer to this global ag ignore file in the shell.d/aliases.sh file,
# because `ag` is an alias for using `ag` with this file.
ensure_symlink "$(pwd)/ag/agignore" "$HOME/.ignore"
if [[ ! -e "$HOME/.config" ]]; then
    mkdir ~/.config
fi
ensure_symlink "${pwd}/alacritty" "$HOME/.config/alacritty"

# Install Linux apps on osx.
if [[ "$os" == "osx" ]]; then
    brew tap homebrew/cask
    brew tap homebrew/cask-fonts
    apps=('font-hack-nerd-font'
        'font-mononoki-nerd-font '
        'coreutils'
        'fzf'
        'grc'
        'tldr'
        'the_silver_searcher'
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
        'spotify'
        'alacritty'
        'iterm2'
        'mas'
        'kubernetes-cli'
    )
    for app in ${apps[@]}; do
        if [[ ${app} == "alacrity"]] && [[ $type == "osx-arm" ]]; then continue 
        else
            echo "$os: Installing tool '${app}'"
            brew install ${app}
    done
    $(brew --prefix)/opt/fzf/install
    sudo gem install colorls
elif [[ "$os" == "ubuntu" ]]; then
    apps=('silversearcher-ag'
        'fzf'
        'grc'
        'tldr'
        'build-essential'
        'ruby'
        'ruby-dev'
        'tree'
        'ansible'
    )
    for app in ${apps[@]}; do
        echo "$os: Installing tool '${app}'"
        sudo apt install -y ${app}
    done
    sudo gem install colorls
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
fi