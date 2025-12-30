#!/bin/sh

AWG_SERVER_TOOLS_VERSION="0.5.0"

set -eu

add_folder() {
    DIR=$1
    for ENTRY in "$DIR"/*; do
        if [ -d "$ENTRY" ]; then
            add_folder "$ENTRY"
        elif [ -f "$ENTRY" ]; then
            . "$ENTRY"
        fi
    done
}

add_lib() {
    SCRIPT_PATH=$(cd $(dirname "$0") && pwd)
    LIB_PATH="${SCRIPT_PATH}/lib"

    for FOLDER_NAME in "$@"; do
        FOLDER_PATH="${LIB_PATH}/${FOLDER_NAME}"

        add_folder "$FOLDER_PATH"
    done
}


check_root() {
    if [ $(id -u) -ne 0 ]; then
        echo "This script must be run as root."
        exit 1
    fi
}

check_awg_installed() {
    if [ ! -d "/etc/amnezia/amneziawg/server-tools" ]; then
        echo "AmneziaWG is not installed. Install AmneziaWG using the amneziawg-installer tool."
        exit 1
    fi
}

check_os() {
    . "/etc/os-release"

    OS="$ID"
}


check_required_params() {
    check_root
    check_awg_installed
    check_os
}


handle_common_flags() {
    for ARG in "$@"; do
        case "$ARG" in
            "-v"|"--version")
                echo "amneziawg-server-tools version ${AWG_SERVER_TOOLS_VERSION}"
                exit 0
                ;;
        esac
    done
}


main() {
    handle_common_flags "$@"

    check_required_params

    . /etc/amnezia/amneziawg/server-tools/server-tools.conf

    add_lib "utils" "uninstaller"

    print_dashes "$((22 + ${#AWG_SERVER_TOOLS_VERSION}))"

    printf "${BOLD_FS} AmneziaWG Uninstaller ${AWG_SERVER_TOOLS_VERSION} ${DEFAULT_FS} -> https://github.com/SoVoKaN/amneziawg-server-tools\n"

    print_dashes "$((22 + ${#AWG_SERVER_TOOLS_VERSION}))"
    echo ""

    prepare_to_uninstall

    uninstall_modules

    echo ""
    printf "${GREEN}AmneziaWG is succesfuly uninstalled.${DEFAULT_COLOR}\n"
    echo "You can also remove the qrencode and nftables if you don't need them."
}

main "$@"
