# Install the latest zsh.
echo "installing zsh"
if [[ "$os" == "osx" ]]; then
    brew install zsh zsh-completions
    # Make sure the installed zsh path is allowed in the list of shells.
    echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells
elif [[ "$os" == "ubuntu" ]]; then
    sudo apt-get install -y zsh
elif [[ "$os" == "alpine" ]]; then
    apk add zsh zsh-vcs
elif [[ "$os" == "debianContainer" ]]; then
    apt install -y locales
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    dpkg-reconfigure --frontend=noninteractive locales
    apt install zsh -y
fi

# Our zshrc assumes oh-my-zsh, ask to install it first.
echo "Installing current oh-my-zsh"
# Run the unattended install, see:
# https://github.com/ohmyzsh/ohmyzsh#unattended-install

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# install the zsh plugins for oh-my-zsh
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/unixorn/warhol.plugin.zsh.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/warhol
#git clone https://github.com/trapd00r/zsh-syntax-highlighting-filetypes.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting-filetypes
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# After we have installed zsh, create a link to our zshrc.
echo "$os: setting ~/.zshrc link..."
if [ -e ~/.zshrc ]; then
    mv $HOME/.zshrc $HOME/.zshrc-pre-install
    mv $HOME/.p10k.zsh $HOME/.p10k.zsh-pre-install
fi
ensure_symlink "$(pwd)/zsh/zshrc" "$HOME/.zshrc"
ensure_symlink "$(pwd)/zsh/p10k.zsh" "$HOME/.p10k.zsh"

# Move to zsh.
echo "$os: checking shell..."
if [[ "$os" == "alpine" ]] || [[ "$os" == "debianContainer" ]]; then
    echo "$os: can't change shell for container"
elif [[ ! "$SHELL" =~ zsh$ ]]; then
    echo "Changing shell to zsh"
    if [[ $os == "ubuntu" ]]; then
        sudo chsh -s `$(command echo which zsh)` $USER
    else
        sudo chsh -s "$(brew --prefix)/bin/zsh" $USER
    fi
fi

# Check the shell, and make sure that we are sourcing the .shell.sh file.
echo "Adding .shell.sh to zsh"

# Create the .shell.sh script symlink as well as shell.d folder symlink.
ensure_symlink "$(pwd)/shell.sh" "$HOME/.shell.sh"
ensure_symlink "$(pwd)/shell.d" "$HOME/.shell.d"

# Source our shell configuration in any local shell config files.
config_files=(~/.zshrc)
for config_file in ${config_files[@]}; do
    # Skip config files that don't exist.
    ! [ -r "${config_file}" ] && continue

    # If we don't have the 'source ~/.shell.d' line in our config, add it.
    source_command="[ -r ~/.shell.sh ] && source ~/.shell.sh"
    if ! grep -q "${source_command}" "${config_file}"; then
        echo ".shell.sh is not sourced in '${config_file}'. adding it."
        echo "" >> "${config_file}"
        echo "# Source my personal (github.com/dwmkerr/dotfiles) configuration." >> "${config_file}"
        echo "${source_command}" >> "${config_file}"
    fi
done
