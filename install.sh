if [ ! -x "$(command -v git)" ]; then
    echo "you need to run xcode-select --install first"
    return 0
else
    echo "executing"
    mkdir ~/src
    cd ~/src/
    git clone https://github.com/clegault/dotfiles.git
    cd dotfiles
    ./setup.sh -auto
fi