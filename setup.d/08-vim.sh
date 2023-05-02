# I expect the following folder in my $HOME for temp stuff. Vim'll save the edit
# history and backups there.
mkdir ~/tmp
mkdir ~/.vim

if [[ "$os" == "osx" ]]; then
    echo "$os: Installing vim..."
    brew install vim
elif [[ "$os" == "alpine" ]]; then
    echo "$os: Installing vim..."
    apk add vim
elif [[ "$os" == "debianContainer" ]]; then
    echo "$os: Installing vim..."
    apt install vim -y
fi

# Note: I no longer use Vundle, having migrated to Vim-Plug. However, if you
# want it installed, just uncomment the line below:
# git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Use our dotfiles for vimrc and vim spell.
ensure_symlink "$(pwd)/vim/vim-spell-en.utf-8.add" "$HOME/.vim-spell-en.utf-8.add"
ensure_symlink "$(pwd)/vim/vimrc" "$HOME/.vimrc"
ensure_symlink "$(pwd)/vim/coc-settings.json" "$HOME/.vim/coc-settings.json"