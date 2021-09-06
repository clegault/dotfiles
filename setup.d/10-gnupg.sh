# Configure gpg.
if [[ "$os" == "osx" ]]; then

    echo "$os: Installing gpg..."
    # Install GPG and Pinentry for Mac.
    brew install gnupg

    # Tell GPG to use pinentry-mac, and restart the agent. Create the gnupg
    # folder if we have to.
    mkdir -p ~/.gnupg
    echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
    gpgconf --kill gpg-agent

    # Make sure we lock down the gpg config folder.
    # Set ownership to your own user and primary group.
    chown -R "$USER:$(id -gn)" ~/.gnupg
    # Set permissions to read, write, execute for only yourself, no others.
    chmod 700 ~/.gnupg
    # Set permissions to read, write for only yourself, no others.
    chmod 600 ~/.gnupg/*

elif [[ "$os" == "ubuntu" ]]; then
    echo "$os: Installing gpg..."
    sudo apt install -y gnupg
fi
