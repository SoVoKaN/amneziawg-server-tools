uninstall_packages() {
    apt-get purge -y ${UNINSTALLATION_PACKAGES}
    add-apt-repository -y -r ppa:amnezia/ppa

    if [ -f "/etc/apt/sources.list.d/amneziawg.sources" ]; then
        rm -f "/etc/apt/sources.list.d/amneziawg.sources"
    elif [ -f "/etc/apt/sources.list.d/amneziawg.sources.list" ]; then
        rm -f "/etc/apt/sources.list.d/amneziawg.sources.list"
    fi
}
