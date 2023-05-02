# Setup Java.
echo "Setting up the latest Java"
if [[ "$os" == "osx" ]]; then
    brew install adoptopenjdk
elif [[ "$os" == "ubuntu" ]]; then
    sudo apt install openjdk-16-jre-headless -y 
else
    echo "warning: will not install Java on container, stopping..."
fi