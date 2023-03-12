# Bail if we are a container.
if [[ "$os" == "alpine" ]]; then
    echo "warning: will not setup alacritty on container, stopping..."
    return 0
fi
#set up the config file
if [[ ! -e "$HOME/.config" ]]; then
    mkdir ~/.config
fi

# Bail if we are not on OSX.
if [[ "$os" != "osx" ]]; then
    echo "warning: cannot setup OSX applications on '${os}', stopping..."
    return 0
elif [[ $type == "osx-arm" ]]; then
    echo "Arm mac detected. Compiling Alacritty from source"
    brew install alacritty
    #brew install rustup
    #rustup-init -y
    #source $HOME/.cargo/env
    #cd ~/src/
    #git clone https://github.com/alacritty/alacritty.git
    #cd alacritty
    #make app
    #cp -r target/release/osx/Alacritty.app /Applications/
    #sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
    #cd ../dotfiles/
else
    echo "Intel mac detected. Installing Alacritty"
    brew install alacritty
fi
ensure_symlink "$(pwd)/alacritty" "$HOME/.config/alacritty"