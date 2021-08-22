# Install pyrev and python.
if [[ "$os" == "osx" ]]; then
    echo "$os: Installing pyenv..."
    brew install pyenv
elif [[ "$os" == "ubuntu" ]]; then
    # Install python dependencies.
    sudo apt install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev\
        libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
fi