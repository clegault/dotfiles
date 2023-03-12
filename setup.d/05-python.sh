# Bail if we are a container.
if [[ "$os" == "alpine" ]]; then
    echo "warning: will not install python on container, stopping..."
    return 0
fi
if [[ "$os" == "osx" ]]; then
    echo "$os: Installing pyenv..."
    brew install pyenv
elif [[ "$os" == "ubuntu" ]]; then
    # Install python dependencies.
    sudo apt install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev libncurses5-dev\
        libncursesw5-dev libffi-dev liblzma-dev
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
fi

#python-openssl is missing?