# Bail if we are a container.
if [[ "$os" == "alpine" ]]; then
    echo "warning: will not install nvm on container, stopping..."
    return 0
fi
# Configure Terraform.
echo "Setting up Terraform and Terraform Lint"
if [[ "$os" == "osx" ]]; then
    brew install terraform
    brew tap wata727/tflint
    brew install tflint
elif [[ "$os" == "ubuntu" ]]; then
    echo "Installing terraform on $os"
    sudo apt install -y software-properties-common
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install terraform
fi

terraform -install-autocomplete