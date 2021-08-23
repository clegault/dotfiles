#check if this is an M1 mac, if yes, abort
if [[ $type == "osx-arm" ]]; then
    continue
else
    # If NVM is not installed, install it.
    echo "$os: Checking for NVM..."
    nvm_installed=$(command -v nvm)
    if [[ ${nvm_installed} != 0 ]]; then
        echo "$os: Installing NVM..."
        touch ~/.bash_profile
        # TODO: make sure this also does zsh
        curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
    else
        echo "$os: NVM is installed..."
    fi

    # Install the current node lts.
    echo "Installing and use node lts as default"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 'lts/*'
    nvm alias default 'lts/*'
fi
