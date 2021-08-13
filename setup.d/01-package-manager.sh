# Setup any package manager required.
if [[ "$os" == "osx" ]]; then
    echo "$os: Checking for brew..."
    which -s brew
    if [[ $? != 0 ]] ; then
        echo "$os: Installing HomeBrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.profile
        eval "$(/opt/homebrew/bin/brew shellenv)"
        # If there was an error, it might be this issue:
        echo "If you see an error above, run:"
        echo "  brew doctor"
    fi
    echo "$os: Updating brew..."
    brew update
elif [[ "$os" == "ubuntu" ]]; then
    echo "$os: Updating apt..."
    sudo apt-get update -y
    sudo apt-get upgrade -y

    # Ensure that snap is installed for Ubuntu.
    if [ ! -x "$(command -v snap)" ]; then
        echo "$os: Installing snap..."
        sudo apt-get install -y snapd
    else
        echo "$os: 'snap' is installed..."
    fi
fi