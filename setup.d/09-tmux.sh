# Bail if we are a container.
if [[ "$os" == "alpine" ]]; then
    echo "warning: will not install tmux on container, stopping..."
    return 0
fi
# Ensure tmux is up to date.
if [[ "$os" == "osx" ]]; then
    echo "$os: installing tmux..."
    brew install tmux
elif [[ "$os" == "ubuntu" ]]; then
    echo "$os: installing tmux..."
    sudo apt-get install -y tmux
fi
ensure_symlink "$(pwd)/tmux/tmux.conf" "$HOME/.tmux.conf"


# Install the TMux Plugin Manager.
echo "Installing tmux plugin manager."
# Setup the tmux plugin manager if it is not already installed.
if [[ ! -e ~/.tmux ]]; then
    mkdir ~/.tmux
else
    rm -rf ~/.tmux/plugins/tpm  || true
fi
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install tmux plugins.
~/.tmux/plugins/tpm/scripts/install_plugins.sh