add_installation_scripts() {
    SCRIPT_DIR=$(cd $(dirname "$0") && pwd)
    FOLDER_DIR="${SCRIPT_DIR}/lib/installer"

    INSTALLATION_DIR="${FOLDER_DIR}/${OS}"

    for SCRIPT in "${INSTALLATION_DIR}"/*.sh; do
        if [ -f "$SCRIPT" ]; then
            . "$SCRIPT"
        fi
    done
}

configure_installation_packages() {
    INSTALLATION_PACKAGES="amneziawg amneziawg-tools nftables"

    if [ "$INSTALL_QRENCODE" = "y" ]; then
        INSTALLATION_PACKAGES="${INSTALLATION_PACKAGES} qrencode"
    fi
}


install_modules() {
    add_installation_scripts

    configure_installation_packages

    install_packages
}
