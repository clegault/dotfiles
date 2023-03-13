# Bail if we are a container.
if [[ "$os" == "alpine" || "$os" == "debianContainer"]]; then
    echo "warning: will not install nvm on container, stopping..."
    return 0
fi
# If NVM is not installed, install it.
echo "$os: Checking for NVM..."
nvm_installed=$(command -v nvm)
if [[ ${nvm_installed} != 0 ]]; then
    echo "$os: Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | zsh
else
    echo "$os: NVM is installed..."
fi

# Install the current node lts.
echo "Installing and use node lts as default"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" 
nvm install 'lts/*'
nvm alias default 'lts/*'
nvm cache clear