check_awg_interface_exists() {
    if [ -f "/etc/amnezia/amneziawg/${1}.conf" ]; then
        return 0
    fi

    if [ -d "${AWG_SERVER_TOOLS_PATH}/interfaces/${1}/" ]; then
        return 0
    fi

    return 1
}

load_interface_data() {
    . "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/${AWG_INTERFACE_NAME}.data"
}

start_awg_interface_service() {
    systemctl start "awg-quick@${AWG_INTERFACE_NAME}"
    systemctl enable "awg-quick@${AWG_INTERFACE_NAME}"
}

stop_awg_interface_service() {
    systemctl stop "awg-quick@${AWG_INTERFACE_NAME}"
    systemctl disable "awg-quick@${AWG_INTERFACE_NAME}"
}


interfaces_menu() {
    while :; do
        echo "-------------------"
        printf "${BOLD_FS} Manage interfaces ${DEFAULT_FS}\n"
        echo "-------------------"
        echo ""
        echo "1) Enable interface"
        echo "2) Disable interface"
        echo "3) List interfaces"
        echo "4) Create interface"
        echo "5) Delete interface"
        echo ""
        echo "0) Back"
        echo ""

        printf "Select option [0-5]: "

        handle_user_input

        clean_lines "13"

        case "$USER_INPUT" in
            "1")
                enable_awg_interface
                ;;
            "2")
                disable_awg_interface
                ;;
            "3")
                list_awg_interfaces
                ;;
            "4")
                create_awg_interface
                exit 0
                ;;
            "5")
                delete_awg_interface
                ;;
            "0")
                break
                ;;
        esac
    done
}
