# Note the standard zsh autocompletion paths.
echo "Installing docker autocompletions for zsh"
zsh_autocomplete_dir="${HOME}/.oh-my-zsh/custom/plugins/zsh-completions/src/"

# Download the zsh autocompletion scripts.
curl -L https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/zsh/_docker -o \
    "${zsh_autocomplete_dir}/_docker"
curl -L https://raw.githubusercontent.com/docker/compose/1.24.0/contrib/completion/zsh/_docker-compose -o \
    "${zsh_autocomplete_dir}/_docker-compose"
curl -L https://raw.githubusercontent.com/docker/machine/v0.16.0/contrib/completion/zsh/_docker-machine -o \
    "${zsh_autocomplete_dir}/_docker-machine"

