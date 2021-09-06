#install rosetta if this is an M1
if [[ $type == 'osx-arm' ]]; then
  echo "M1 Mac detected, installing rosetta"
  sudo softwareupdate --install-rosetta --agree
fi

# Setup any package manager required.
if [[ "$os" == "osx" ]]; then
    echo "$os: Checking for brew..."
    if [[ ! -x $(command -v brew) ]] ; then
        echo "$os: Installing HomeBrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo 'eval "$('$(brew --prefix)'/bin/brew shellenv)"'  >> ~/.zprofile
        eval "$("$(brew --prefix)"/bin/brew shellenv)"
        # If there was an error, it might be this issue:
        echo "If you see an error above, run:"
        echo "  brew doctor"
    fi
    echo "$os: Updating brew..."
    brew update
elif [[ "$os" == "ubuntu" ]]; then
    echo "$os: Updating apt..."
    sudo apt update -y
    sudo apt upgrade -y

    # Ensure that snap is installed for Ubuntu.
    if [[ ! -x "$(command -v snap)" ]]; then
        echo "$os: Installing snap..."
        sudo apt install -y snapd
    else
        echo "$os: 'snap' is installed..."
    fi
fi
