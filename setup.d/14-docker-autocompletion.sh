# Bail if we are a container.
if [[ "$os" == "alpine" ]] || [[ "$os" == "debianContainer" ]]; then
    echo "warning: will not install nvm on container, stopping..."
    return 0
fi
# Note the standard zsh autocompletion paths.
echo "Installing docker if this is ubuntu and docker autocompletions for zsh"
zsh_autocomplete_dir="${HOME}/.oh-my-zsh/custom/plugins/zsh-completions/src/"

# Download the zsh autocompletion scripts.
curl -L https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/zsh/_docker -o \
    "${zsh_autocomplete_dir}/_docker"
curl -L https://raw.githubusercontent.com/docker/compose/1.24.0/contrib/completion/zsh/_docker-compose -o \
    "${zsh_autocomplete_dir}/_docker-compose"
curl -L https://raw.githubusercontent.com/docker/machine/v0.16.0/contrib/completion/zsh/_docker-machine -o \
    "${zsh_autocomplete_dir}/_docker-machine"

#installing docker if this is linux
echo "$os: Installing docker"
if [[ "$os" == "osx" ]]; then
    brew install docker
elif [[ "$os" == "ubuntu" ]]; then
    # sudo apt install -y  apt-transport-https ca-certificates curl gnupg lsb-release
    # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    # echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    # sudo apt update
    sudo apt install -y docker.io
fi
