check_awg_client_already_disabled() {
    awk -v pattern="### ${1}" '
$0 == pattern {
    if (getline) {
        if ($0 == "#[Peer]") exit 0
        else exit 1
    }
}' "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"

    if [ "$?" = "1" ]; then
        return 1
    fi

    return 0
}

get_awg_client_name_disable() {
    while :; do
        printf "${BOLD_FS}Enter client name to disable.${DEFAULT_FS}\n"
        printf '%s' "Name: "

        handle_user_input

        echo ""

        if [ -z "$USER_INPUT" ]; then
            echo "Client name can not be empty."
            exit 1
        fi

        if [ ${#USER_INPUT} -gt 20 ]; then
            echo "Client name length must be <= 20."
            exit 1
        fi

        if ! check_awg_client_exists "$USER_INPUT"; then
            echo "Client \"${USER_INPUT}\" does not exists."
            exit 1
        fi

        if check_awg_client_already_disabled "$USER_INPUT"; then
            echo "Client \"${USER_INPUT}\" is already disabled."
            exit 1
        fi

        AWG_CLIENT_NAME="$USER_INPUT"

        break
    done
}

confirm_awg_client_disable() {
    QUESTION=$(printf '%s' "This will disable \"${AWG_CLIENT_NAME}\" client. Continue? (y/n): ")

    printf '%s' "$QUESTION"

    handle_user_input

    if [ -z "$USER_INPUT" ]; then
        default_value_autocomplete "n" "$QUESTION"
    fi

    case "$USER_INPUT" in
        "y" | "yes" | "Y" | "YES") ;;
        *)
            echo ""
            echo "Aborted."
            exit 0
            ;;
    esac
}

disable_awg_client_in_config() {
    TEMP_FILE=$(mktemp)

    awk -v n="4" -v pattern="### ${AWG_CLIENT_NAME}" '
$0 == pattern { to_comment = n; print; next }
to_comment > 0 { print "#" $0; to_comment--; next }
{ print }
' "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf" > "$TEMP_FILE"

    mv "$TEMP_FILE" "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"
}


disable_awg_client() {
    print_dashes "$((19 + ${#AWG_INTERFACE_NAME}))"

    printf "${BOLD_FS} Disable Client [${AWG_INTERFACE_NAME}] ${DEFAULT_FS}\n"

    print_dashes "$((19 + ${#AWG_INTERFACE_NAME}))"
    echo ""

    if select_awg_client_submenu "get_awg_client_name_disable" "active"; then
        SUBMENU_RETURN_CODE="0"
    else
        SUBMENU_RETURN_CODE="$?"
    fi

    if [ "$SUBMENU_RETURN_CODE" = "1" ]; then
        clean_lines "4"

        return
    elif [ "$SUBMENU_RETURN_CODE" = "2" ]; then
        set_awg_server_tools_pager

        clean_lines "4"

        if [ -n "$AWG_SERVER_TOOLS_PAGER" ]; then
            printf "$SELECT_CLIENT_SUBMENU_FAILURE_RETURN_MESSAGE" | "$AWG_SERVER_TOOLS_PAGER"
        else
            printf "\n${BOLD_FS}${SELECT_CLIENT_SUBMENU_FAILURE_RETURN_MESSAGE}${DEFAULT_FS}\n\n"
        fi

        return
    fi

    confirm_awg_client_disable

    disable_awg_client_in_config

    awg_sync_clients

    echo ""
    printf "${GREEN}Client ${BOLD_FS}\"${AWG_CLIENT_NAME}\"${DEFAULT_FS} is succesfuly disabled.${DEFAULT_COLOR}\n"
    exit 0
}
