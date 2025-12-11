uninstall_packages() {
    apt-get purge -y ${UNINSTALLATION_PACKAGES}

    rm -f "/etc/apt/keyrings/amneziawg-keyring.gpg"
    rm -f "/etc/apt/sources.list.d/amneziawg.sources"
}
