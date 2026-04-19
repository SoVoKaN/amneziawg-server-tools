get_awg_client_name_rename() {
    while :; do
        printf "${BOLD_FS}Enter client name to rename.${DEFAULT_FS}\n"
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

        AWG_CLIENT_NAME="$USER_INPUT"

        break
    done
}

get_awg_client_new_name_rename() {
    while :; do
        printf "${BOLD_FS}Enter new name for client.${DEFAULT_FS}\n"
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

        if check_awg_client_exists "$USER_INPUT"; then
            echo "Client \"${USER_INPUT}\" is already exists."
            exit 1
        fi

        AWG_CLIENT_NEW_NAME="$USER_INPUT"

        break
    done
}

confirm_awg_client_renaming() {
    QUESTION=$(printf '%s' "This will rename \"${AWG_CLIENT_NAME}\" client to \"${AWG_CLIENT_NEW_NAME}\". Continue? (y/n): ")

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

rename_awg_client_configs() {
    TEMP_FILE=$(mktemp)

    sed "s/### ${AWG_CLIENT_NAME}/### ${AWG_CLIENT_NEW_NAME}/g" "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf" > "$TEMP_FILE"
    mv "$TEMP_FILE" "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"

    mv "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/clients/${AWG_CLIENT_NAME}.data" "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/clients/${AWG_CLIENT_NEW_NAME}.data"
}

rename_client() {
    print_dashes "$((18 + ${#AWG_INTERFACE_NAME}))"
    printf "${BOLD_FS} Rename client [${AWG_INTERFACE_NAME}] ${DEFAULT_FS}\n"
    print_dashes "$((18 + ${#AWG_INTERFACE_NAME}))"
    echo ""

    if select_awg_client_submenu "get_awg_client_name_rename" "all"; then
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

    get_awg_client_new_name_rename

    confirm_awg_client_renaming

    echo ""

    rename_awg_client_configs

    printf "${GREEN}Client ${BOLD_FS}\"${AWG_CLIENT_NAME}\"${DEFAULT_FS} is succesfuly renamed to ${BOLD_FS}\"${AWG_CLIENT_NEW_NAME}\"${DEFAULT_FS}.${DEFAULT_COLOR}\n"
    exit 0
}
