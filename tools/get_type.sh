# Echo's the hardware, simplified to:
# - osx-arm
get_type() {
    # Identify if this is apple silicon.
    type="unknown"
    if [[ $(uname -p) == 'arm' ]]; then 
        echo "osx-arm"
    fi
}