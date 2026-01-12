set_awg_server_tools_pager() {
    AWG_SERVER_TOOLS_PAGER=""

    if command -v less > /dev/null 2>&1; then
        AWG_SERVER_TOOLS_PAGER="less"
        return
    fi
}


main_menu() {
    while :; do
        print_dashes "$((20 + ${#AWG_SERVER_TOOLS_VERSION}))"

        printf "${BOLD_FS} AmneziaWG Manager ${AWG_SERVER_TOOLS_VERSION} ${DEFAULT_FS} -> https://github.com/SoVoKaN/amneziawg-server-tools\n"

        print_dashes "$((20 + ${#AWG_SERVER_TOOLS_VERSION}))"
        echo ""
        echo "1) Manage clients"
        echo "2) Manage interfaces"
        echo ""
        echo "0) Exit"
        echo ""

        printf "Select option [0-2]: "

        handle_user_input

        clean_lines "10"

        case "$USER_INPUT" in
            "1")
                clients_menu
                ;;
            "2")
                interfaces_menu
                ;;
            "0")
                break
                ;;
        esac
    done
}
