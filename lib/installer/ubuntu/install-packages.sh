install_packages() {
    if [ -f "/etc/apt/sources.list.d/ubuntu.sources" ]; then
        sed 's/deb/deb-src/' /etc/apt/sources.list.d/ubuntu.sources > /etc/apt/sources.list.d/amneziawg.sources
    else
        sed 's/^deb/deb-src/' /etc/apt/sources.list > /etc/apt/sources.list.d/amneziawg.sources.list
    fi

    apt-get update
    apt-get install -y software-properties-common linux-headers-$(uname -r)

    add-apt-repository -y ppa:amnezia/ppa

    apt-get update
    apt-get install -y ${INSTALLATION_PACKAGES}
}
