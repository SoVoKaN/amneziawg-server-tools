add_uninstallation_scripts() {
    SCRIPT_DIR=$(cd $(dirname "$0") && pwd)
    FOLDER_DIR="${SCRIPT_DIR}/lib/uninstaller"

    case "$OS" in
        "ubuntu") INSTALLATION_DIR="${FOLDER_DIR}/ubuntu" ;;
    esac

    for SCRIPT in "${INSTALLATION_DIR}"/*.sh; do
        if [ -f "$SCRIPT" ]; then
            . "$SCRIPT"
        fi
    done
}

remove_config_files() {
    rm -rf "/etc/amnezia/amneziawg"
}


uninstall_modules() {
    add_uninstallation_scripts

    remove_config_files

    uninstall_packages
}
