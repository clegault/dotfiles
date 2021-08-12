# Setup ag.
echo "Installing The Silver Searcher"
if [[ "$os" == "osx" ]]; then
    brew install the_silver_searcher
elif [[ "$os" == "ubuntu" ]]; then
    echo "$os: installing silversearcher..."
    apt install -y silversearcher-ag
fi

# We refer to this global ag ignore file in the shell.d/aliases.sh file,
# because `ag` is an alias for using `ag` with this file.
ensure_symlink "$(pwd)/ag/ignore" "$HOME/.ignore"

# Fuzzy finder.
echo "Installing fzf"
if [[ "$os" == "osx" ]]; then
    # Install fzf, then setup the auto-completion.
    brew install fzf
    $(brew --prefix)/opt/fzf/install
elif [[ "$os" == "ubuntu" ]]; then
    apt install fzf -y
    exit 1
fi

# Setup Kubectl
# if ask "$os: Install kubectl?" Y; then
#     if [[ "$os" == "osx" ]]; then
#         brew install kubernetes-cli
#     elif [[ "$os" == "ubuntu" ]]; then
#         curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
#         chmod +x ./kubectl
#         sudo mv ./kubectl /usr/local/bin/kubectl
#     fi
# fi

# Setup grc
echo "Installing grc"
if [[ "$os" == "osx" ]]; then
    brew install grc
elif [[ "$os" == "ubuntu" ]]; then
    apt install -y grc
fi

# Setup tldr.
echo "Installing tldr"
if [[ "$os" == "osx" ]]; then
    brew install tldr
elif [[ "$os" == "ubuntu" ]]; then
    apt install -y tldr
fi

#setup colorls
# echo "Installing colorls"
#     if [[ "$os" == "osx" ]]; then
#         gem install colorls
#     elif [[ "$os" == "ubuntu" ]]; then
#         apt install build-essential ruby ruby-dev
#         gem install colorls
#     fi
# fi
