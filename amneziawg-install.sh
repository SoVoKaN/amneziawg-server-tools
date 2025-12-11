#!/bin/sh

AWG_TOOLS_VERSION="0.3.0"

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

check_awg_already_installed() {
    if [ -d "/etc/amnezia/amneziawg/server-tools" ]; then
        echo "AmneziaWG is already installed."
        exit 0
    fi
}

check_virt() {
    if grep "container=" /proc/1/environ > /dev/null 2>&1; then
        echo "Containers is not supported."
        exit 1
    fi
}

check_os() {
    . "/etc/os-release"

    OS="$ID"
}

validate_os_ver() {
    case "$OS" in
        "debian")
            if [ "$VERSION_ID" -lt 11 ]; then
                echo "Your version of Debian ${VERSION_ID} is not supported. Please use Debian 11 or later."
                exit 1
            fi
            ;;
        "ubuntu")
            MAJOR_VERSION="${VERSION_ID%%.*}"
            if [ "$MAJOR_VERSION" -lt 20 ]; then
                echo "Your version of Ubuntu ${VERSION_ID} is not supported. Please use Ubuntu 20.04 or later."
                exit 1
            fi
            ;;
        "fedora")
            if [ "$VERSION_ID" -ne 41 ]; then
                echo "Your version of Fedora ${VERSION_ID} is not supported. Please use Fedora 41."
                exit 1
            fi
            ;;
            *)
                echo "Your Linux distribution is not supported."
                exit 1
            ;;
    esac
}


check_required_params() {
    check_root
    check_awg_already_installed
    check_virt
    check_os
    validate_os_ver
}


handle_common_flags() {
    for ARG in "$@"; do
        case "$ARG" in
            "-v"|"--version")
                echo "amneziawg-server-tools version ${AWG_TOOLS_VERSION}"
                exit 0
                ;;
        esac
    done
}


main() {
    handle_common_flags "$@"

    check_required_params

    add_lib "utils" "installer"

    echo "---------------------------"
    echo "${BOLD_FS} AmneziaWG Installer ${AWG_TOOLS_VERSION} ${DEFAULT_FS} -> https://github.com/SoVoKaN/amneziawg-server-tools"
    echo "---------------------------"
    echo ""

    prepare_to_install

    install_modules

    setup_awg_server_tools

    echo ""
    echo "${GREEN}AmneziaWG is succesfuly installed.${DEFAULT_COLOR}"
    echo "You can now add an interface and then add clients using the ${CYAN}amneziawg-manager${DEFAULT_COLOR} tool."
}

main "$@"
