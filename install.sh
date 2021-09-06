if [ -x "$(command -v xcode-select)" ]; then
    xcode-select --install
    echo "Follow the prompts on the screen to finish xcode installation. Press any key to continue once the installer is finished."
    while [ true ] ; do
        read -t 3 -n 1
        if [ $? = 0 ] ; then
            exit ;
        else
            echo "waiting for the keypress"
        fi
    done
else
    sudo apt update
    sudo apt upgrade -y
fi
if [ ! -x "$(command -v git)" ]; then
    echo "Installing git"
    sudo apt install -y git
fi
# Configure Git.
if [[ "$USER" == "clegault" ]]; then
    # if ask "$os: Configure git for clegault user and GPG signing?" n; then
        git config --global user.name "Collin LeGault"
        git config --global user.email "1413504+clegault@users.noreply.github.com"
        git config --global user.signingKey ""
        git config --global commit.gpgSign false
        git config --global tag.forceSignAnnotated false
        git config --global gpg.program "gpg"
        # Note: on ubuntu we might need:
        # git config --global gpg.program "gpg2"
    # fi
fi
echo "Starting installation..."
mkdir ~/src
cd ~/src/
git clone https://github.com/clegault/dotfiles.git
cd dotfiles
exec ./setup.sh -shell-only