check_awg_interface_already_disabled() {
    ACTIVE_INTERFACES=$(awg show interfaces)
    ACTIVE_INTERFACES=" ${ACTIVE_INTERFACES} "

    case "$ACTIVE_INTERFACES" in
        *" ${1} "*)
            return 1
    esac

    return 0
}

get_awg_interface_name_disable() {
    while :; do
        printf "${BOLD_FS}Enter interface name to delete.${DEFAULT_FS}\n"
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

        if check_awg_interface_already_disabled "$USER_INPUT"; then
            echo "Interface \"${USER_INPUT}\" is already disabled."
            exit 1
        fi

        AWG_INTERFACE_NAME="$USER_INPUT"

        break
    done
}

confirm_awg_interface_disable() {
    QUESTION=$(printf '%s' "This will disable \"${AWG_INTERFACE_NAME}\" interface. Continue? (y/n): ")

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


disable_awg_interface() {
    echo "-------------------"
    printf "${BOLD_FS} Disable Interface ${DEFAULT_FS}\n"
    echo "-------------------"
    echo ""

    if select_awg_interface_submenu "get_awg_interface_name_disable" "active"; then
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

    confirm_awg_interface_disable

    stop_awg_interface_service

    echo ""
    printf "${GREEN}Interface ${BOLD_FS}\"${AWG_INTERFACE_NAME}\"${DEFAULT_FS} is succesfuly disabled.${DEFAULT_COLOR}\n"
    exit 0
}
