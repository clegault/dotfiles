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
if [ ! -x "$(command -v git)" ]; then
    echo "Installing git..."
    if [ -x "$(command -v apk)" ]; then
        echo "Checking for Alpine linux..."
        apk update
        apk install git
    elif [ -x "$(command -v apt)" ]; then
        echo "Checking for Ubuntu/Debian based linux..."
        if [ -x "$(command -v sudo)" ]; then
            echo "Found sudo, so using it..."
            sudo apt update
            sudo apt install git -y
        else
            echo "Trying without sudo, if this fails you will need to manually install git before continuing."
            apt update
            apt install git -y
        fi
    else
        echo "Please manually install git and try again"
        return 0;
    fi
fi

echo "Starting installation..."
mkdir ~/src
cd ~/src/
git clone https://github.com/clegault/dotfiles.git
cd dotfiles
echo "Running setup with this option: $1"
exec bash ./setup.sh $1
