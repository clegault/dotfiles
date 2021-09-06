# Configure Terraform.
echo "Setting up Terraform and Terraform Lint"
if [[ "$os" == "osx" ]]; then
    brew install terraform
    brew tap wata727/tflint
    brew install tflint

    # Now that terraform is installed, we can enable auto-completion.
    # Note that this won't take effect until the shell is restarted.
    terraform -install-autocomplete

elif [[ "$os" == "ubuntu" ]]; then
    echo "Installing terraform on $os"
    sudo apt install -y software-properties-common
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install terraform
    terraform -install-autocomplete  
fi