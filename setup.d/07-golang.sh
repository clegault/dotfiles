# Bail if we are a container.
if [[ "$os" == "alpine" ]] || [[ "$os" == "debianContainer" ]]; then
    echo "warning: will not install nvm on container, stopping..."
    return 0
fi
# Setup parameters.
gopath="$HOME/go"

if [[ "$os" == "osx" ]]; then
    echo "$os: Installing Go with brew..."
    brew install go
elif [[ "$os" == "ubuntu" ]]; then
    echo "$os: Installing Go with snap..."
    sudo snap install --classic go
fi

# Now make sure we have a go home for $GOPATH...
if [ ! -d "$gopath" ]; then
    echo "no gopath detected, creating \$GOPATH at '$gopath'"
    mkdir "${gopath}";
    mkdir "${gopath}/src";
    mkdir "${gopath}/pkg";
    mkdir "${gopath}/bin";
fi 