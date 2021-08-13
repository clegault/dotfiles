# Creates symbolic links.
link:
	mkdir ~/.vim
	ln -sf ${PWD}/shell.sh ~/.shell.sh
	ln -sf ${PWD}/shell.d ~/.shell.d
	ln -sf ${PWD}/vim/vimrc ~/.vimrc
	ln -sf ${PWD}/vim/coc-settings.json ~/.vim/coc-settings.json
	ln -sf ${PWD}/tmux/tmux.conf ~/.tmux.conf
	ln -sf ${PWD}/ag/agignore ~/.ignore
	ln -sf ${PWD}/alacritty ~/.config/alacritty

# Backup private config files (ssh keys etc).
private-files-backup:
	./private-files/private-files-backup.sh

# Restore private config files (ssh keys etc).
private-files-restore:
	./private-files/private-files-restore.sh
