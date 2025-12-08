#!/bin/sh

AWG_TOOLS_VERSION="0.1.0"

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


check_required_params() {
    check_root
    check_awg_installed
}


handle_common_flags() {
    for ARG in "$@"; do
        case "$ARG" in
            "-v"|"--version")
                echo "amneziawg-server-tools version ${VERSION}"
                exit 0
                ;;
        esac
    done
}


main() {
    handle_common_flags "$@"

    check_required_params

    . /etc/amnezia/amneziawg/server-tools/server-tools.conf

    add_lib "utils" "manager"

    main_menu
}

main "$@"
