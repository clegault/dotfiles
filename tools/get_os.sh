# Echo's the operating system, simplified to:
# - osx
# - ubuntu/debian
# - container
#   - ubuntu/debian
#   - alpine
get_os() {
    # Identify the operating system.
    local un=$(uname -a)
    os="unknown"
    if [ -n "$(grep 'kthreadd' /proc/2/status 2>/dev/null)" ]; then
        if [[ "$un" =~ [Dd]arwin ]]; then
            echo "osx"
        elif [[ "$un" =~ [Uu]buntu ]]; then
            echo "ubuntu"
        else
            os="unknown"
        fi
    else
        if [[ "$(command -v apk)" ]]; then
            echo "alpine"
        elif [[ "$(command -v apt)" ]]; then
            echo "debianContainer"
        else
            os="unknown"
        fi
    fi

    if [[ "$os" == "unknown" ]]; then
        logger -s "Unable to idenfify operating system from uname '$un'"
        exit 1
    fi
}
