uninstall_packages() {
    apt-get purge -y amneziawg amneziawg-dkms amneziawg-tools

    rm -f "/etc/apt/keyrings/amneziawg-keyring.gpg"
    rm -f "/etc/apt/sources.list.d/amneziawg.sources"
}
