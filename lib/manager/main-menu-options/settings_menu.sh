settings_menu() {
    while :; do
        echo "--------------------"
        printf "${BOLD_FS} AmneziaWG Settings${DEFAULT_FS}\n"
        echo "--------------------"
        echo ""
        echo "1) Client configs path"
        echo ""
        echo "0) Back"
        echo ""

        printf "Select option [0-1]: "

        handle_user_input

        clean_lines "9"

        case "$USER_INPUT" in
            "1")
                change_awg_client_configs_path
                ;;
            "0")
                break
                ;;
        esac
    done
}
