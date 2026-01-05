install_packages() {
    apt-get update
    apt-get install -y linux-headers-$(uname -r)

    if ! command -v curl > /dev/null; then
        apt-get install -y curl
    fi

    if ! command -v gpg > /dev/null; then
        apt-get install -y gnupg
    fi

    if [ ! -d "/etc/apt/keyrings" ]; then
        mkdir -p /etc/apt/keyrings

        chmod 755 /etc/apt/keyrings
    fi

    curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x57290828" | gpg --dearmor --output "/etc/apt/keyrings/amneziawg-keyring.gpg"

    echo "Types: deb deb-src
URIs: https://ppa.launchpadcontent.net/amnezia/ppa/ubuntu
Suites: focal
Components: main
Signed-By: /etc/apt/keyrings/amneziawg-keyring.gpg
" > "/etc/apt/sources.list.d/amneziawg.sources"

    apt-get update
    apt-get install -y ${INSTALLATION_PACKAGES}
}
