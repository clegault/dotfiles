mkdir ~/src
cd ~/src/
git clone https://github.com/clegault/dotfiles.git
cd dotfiles

# Load each of the tools.
for file in ./tools/*; do
    [ -e "$file" ] || continue
    echo "Loading tool '$file'..."
    source "$file"
done

# Get the operating system, output it. The script will terminate if the OS
# cannot be categorically identified.
os=$(get_os)
type=$(get_type)

echo "os identified as: $os"
if [[ $type == "osx-arm" ]]; then
    echo "hw identified as ARM64"
fi

if [[ $1 == "-auto" ]]; then
    # Run each of the setup files.
    for file in ./setup.d/*; do
        # If we don't have a file (this happens when we find no results), then just
        # move onto the next file (or finish the loop).
        [ -e "$file" ] || continue
        source $file
    done
elif [[ $1 == "-shell-only" ]] || ask "$os: Do you  want to ONLY install the zsh shell and CLI utils?" N; then
    apps=('01-package-manager.sh'
        '03-git.sh'
        '04-node.sh'
        '05-python.sh'
        '08-vim.sh'
        '09-tmux.sh'
        '10-shell.sh'
        '14-docker-autocompletion.sh'
        '15-commandline-tools.sh'
    )
    for app in "${apps[@]}"; do
        echo "$os: Running script:  '${app}"
        source ./setup.d/${app}
    done
else
    # Run each of the setup files.
    for file in ./setup.d/*; do
        # If we don't have a file (this happens when we find no results), then just
        # move onto the next file (or finish the loop).
        [ -e "$file" ] || continue

        # Ask the user if they want to setup the feature, then setup or skip.
        feature=$(basename "$file")
        if ! ask "$os: setup feature '$feature'?" "N"; then continue; fi
        source $file
    done
fi

# Many changes (such as chsh) need a restart, offer it now,
if [[ $1 == "-shell-only" ]] || [[ $1 == "-auto" ]]; then
    exit 0
elif ask "$os: Some changes may require a restart - restart now?" Y; then
    if [[ "$os" == "osx" ]]; then
        echo "$os: Restarting..."
        sudo shutdown -r now
    elif [[ "$os" == "ubuntu" ]]; then
        echo "$os: Restarting..."
        sudo reboot
    fi
fi
