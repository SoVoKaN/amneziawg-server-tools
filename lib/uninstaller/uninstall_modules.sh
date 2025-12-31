add_uninstallation_scripts() {
    SCRIPT_DIR=$(cd $(dirname "$0") && pwd)
    FOLDER_DIR="${SCRIPT_DIR}/lib/uninstaller"

    UNINSTALLATION_DIR="${FOLDER_DIR}/distros/${OS}"

    for SCRIPT in "${UNINSTALLATION_DIR}"/*.sh; do
        if [ -f "$SCRIPT" ]; then
            . "$SCRIPT"
        fi
    done
}

configure_uninstallation_packages() {
    UNINSTALLATION_PACKAGES="amneziawg-dkms amneziawg-tools"
}

remove_config_files() {
    rm -rf "/etc/amnezia/amneziawg"
}


uninstall_modules() {
    add_uninstallation_scripts

    configure_uninstallation_packages

    remove_config_files

    uninstall_packages
}
