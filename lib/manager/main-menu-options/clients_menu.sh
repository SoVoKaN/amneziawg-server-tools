get_awg_interface_name_clients_menu() {
    printf "${BOLD_FS}Enter interface name to manage its clients.${DEFAULT_FS}\n"
    printf '%s' "Name: "

    handle_user_input

    echo ""

    if [ -z "$USER_INPUT" ]; then
        echo "Interface name can not be empty."
        exit 1
    fi

    if [ ${#USER_INPUT} -gt 15 ]; then
        echo "Interface name length must be < 16."
        exit 1
    fi

    if ! check_awg_interface_exists "$USER_INPUT"; then
        echo "Interface \"${USER_INPUT}\" does not exists."
        exit 1
    fi

    AWG_INTERFACE_NAME="$USER_INPUT"

    clean_lines "3"
}

load_client_data() {
    . "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/clients/${AWG_CLIENT_NAME}.data"
}

clients_menu() {
    echo "----------------"
    printf "${BOLD_FS} Manage clients ${DEFAULT_FS}\n"
    echo "----------------"
    echo ""

    if ! select_awg_interface_submenu "get_awg_interface_name_clients_menu"; then
        SUBMENU_RETURN_CODE="1"
    else
        SUBMENU_RETURN_CODE="0"
    fi

    clean_lines "4"

    if [ "$SUBMENU_RETURN_CODE" = "1" ]; then
        return
    fi

    load_interface_data

    while :; do
        print_dashes "$((19 + ${#AWG_INTERFACE_NAME}))"

        printf "${BOLD_FS} Manage clients [${AWG_INTERFACE_NAME}] ${DEFAULT_FS}\n"

        print_dashes "$((19 + ${#AWG_INTERFACE_NAME}))"
        echo ""
        echo "1) Create client"
        echo "2) Delete client"
        echo "3) List clients"
        echo "4) Show client QR"
        echo ""
        echo "0) Back"
        echo ""

        printf "Select option [0-4]: "

        handle_user_input

        clean_lines "12"

        case "$USER_INPUT" in
            "1")
                create_awg_client
                exit 0
                ;;
            "2")
                delete_awg_client
                exit 0
                ;;
            "3")
                list_awg_clients
                ;;
            "4")
                show_awg_client_qr
                exit 0
                ;;
            "0")
                break
                ;;
        esac
    done
}
