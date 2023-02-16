#if [ -x "$(command -v xcode-select)" ]; then
#    xcode-select --install
#    echo "Follow the prompts on the screen to finish xcode installation. Press any key to continue once the installer is finished."
#    while [ true ] ; do
#        read -t 3 -n 1
#        if [ $? = 0 ] ; then
#            exit ;
#        else
#            echo "waiting for the keypress"
#        fi
#    done
#else
#    sudo apt update
#    sudo apt upgrade -y
#fi
#if [ ! -x "$(command -v git)" ]; then
#    echo "Installing git"
#    sudo apt install -y git
#fi
echo "Starting installation..."
mkdir ~/src
cd ~/src/
git clone https://github.com/clegault/dotfiles.git
cd dotfiles
echo "Running setup with this option: $1"
exec bash ./setup.sh $1
