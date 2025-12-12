confirm_uninstallation() {
    printf "This will ${RED}uninstall${DEFAULT_COLOR} ${BOLD_FS}AmneziaWG${DEFAULT_FS} and ${RED}remove${DEFAULT_COLOR} all the ${BOLD_FS}configuration files${DEFAULT_FS}!\n"
	printf "Please ${GREEN}backup${DEFAULT_COLOR} the \"/etc/amnezia/amneziawg\" directory if you want to keep your configuration files.\n"
    echo ""

    QUESTION=$(printf '%s' "Do you want to continue with uninstallation (y/n): ")

    printf '%s' "$QUESTION"

    handle_user_input

    if [ -z "$USER_INPUT" ]; then
        default_value_autocomplete "n" "$QUESTION"
    fi

    echo ""

    case "$USER_INPUT" in
        "y" | "yes" | "Y" | "YES")
            ;;
        *)
            echo "Aborted."
            exit 0
            ;;
    esac
}

stop_services() {
    systemctl stop "awg-quick@*" > /dev/null 2>&1
    systemctl disable "awg-quick@*" > /dev/null 2>&1
}

disable_routing() {
    rm -f "/etc/sysctl.d/awg.conf"

    sysctl --system > /dev/null 2>&1
}


prepare_to_uninstall() {
    confirm_uninstallation

    stop_services

    disable_routing
}
