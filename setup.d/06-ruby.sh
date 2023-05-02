# Bail if we are a container.
if [[ "$os" == "alpine" ]] || [[ "$os" == "debianContainer" ]]; then
    echo "warning: will not install ruby on container, stopping..."
    return 0
fi
# Install RVM, but do not automatically try and edit a bash profile or whatever
# to source commands, we'll handle that ourselves in the ~/.shell.d/ruby.sh
# script. Get the GPG keys first.

if [[ "$os" == "ubuntu" ]]; then
    echo "$os: Installing ruby..."
    sudo apt install -y ruby ruby-dev
else
    command curl -sSL https://rvm.io/mpapis.asc | gpg --import -
    command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
    curl -sSL https://get.rvm.io | bash -s -- --ignore-dotfiles
fi