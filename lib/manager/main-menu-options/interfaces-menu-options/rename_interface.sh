get_awg_interface_name_rename() {
    while :; do
        printf "${BOLD_FS}Enter interface name to rename.${DEFAULT_FS}\n"
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

        break
    done
}

get_awg_interface_new_name_rename() {
    while :; do
        printf "${BOLD_FS}Enter new name for interface.${DEFAULT_FS}\n"
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

        if check_awg_interface_exists "$USER_INPUT"; then
            echo "Interface \"${USER_INPUT}\" is already exists."
            exit 1
        fi

        AWG_INTERFACE_NEW_NAME="$USER_INPUT"

        break
    done
}

confirm_awg_interface_renaming() {
    QUESTION=$(printf '%s' "This will rename \"${AWG_INTERFACE_NAME}\" interface to \"${AWG_INTERFACE_NEW_NAME}\". Continue? (y/n): ")

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

rename_awg_interface_configs() {
    sed "s/${AWG_INTERFACE_NAME}/${AWG_INTERFACE_NEW_NAME}/g" "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf" > "/etc/amnezia/amneziawg/${AWG_INTERFACE_NEW_NAME}.conf"
    rm "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"

    mv "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}" "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NEW_NAME}"

    mv "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NEW_NAME}/${AWG_INTERFACE_NAME}.data" "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NEW_NAME}/${AWG_INTERFACE_NEW_NAME}.data"
}


rename_interface() {
    echo "------------------"
    printf "${BOLD_FS} Rename Interface ${DEFAULT_FS}\n"
    echo "------------------"
    echo ""

    if select_awg_interface_submenu "get_awg_interface_name_rename" "all"; then
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
            printf "$SELECT_INTERFACE_SUBMENU_FAILURE_RETURN_MESSAGE" | "$AWG_SERVER_TOOLS_PAGER"
        else
            printf "\n${BOLD_FS}${SELECT_INTERFACE_SUBMENU_FAILURE_RETURN_MESSAGE}${DEFAULT_FS}\n\n"
        fi

        return
    fi

    get_awg_interface_new_name_rename

    confirm_awg_interface_renaming

    echo ""

    awg-quick down ${AWG_INTERFACE_NAME} > /dev/null 2>&1

    rename_awg_interface_configs

    start_awg_interface_service "$AWG_INTERFACE_NEW_NAME"

    stop_awg_interface_service "$AWG_INTERFACE_NAME"

    echo ""

    printf "${GREEN}Interface ${BOLD_FS}\"${AWG_INTERFACE_NAME}\"${DEFAULT_FS} is succesfuly renamed to ${BOLD_FS}\"${AWG_INTERFACE_NEW_NAME}\"${DEFAULT_FS}.${DEFAULT_COLOR}\n"
    exit 0
}
