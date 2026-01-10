check_awg_interface_already_enabled() {
    ACTIVE_INTERFACES=$(awg show interfaces)
    ACTIVE_INTERFACES=" ${ACTIVE_INTERFACES} "

    case "$ACTIVE_INTERFACES" in
        *" ${1} "*)
            return 0
    esac

    return 1
}

get_awg_interface_name_enable() {
    while :; do
        printf "${BOLD_FS}Enter interface name to enable.${DEFAULT_FS}\n"
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

        if check_awg_interface_already_enabled "$USER_INPUT"; then
            echo "Interface \"${USER_INPUT}\" is already enabled."
            exit 1
        fi

        AWG_INTERFACE_NAME="$USER_INPUT"

        break
    done
}

confirm_awg_interface_enable() {
    QUESTION=$(printf '%s' "This will enable \"${AWG_INTERFACE_NAME}\" interface. Continue? (y/n): ")

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


enable_awg_interface() {
    echo "------------------"
    printf "${BOLD_FS} Enable Interface ${DEFAULT_FS}\n"
    echo "------------------"
    echo ""

    if ! select_awg_interface_submenu "get_awg_interface_name_enable" "inactive"; then
        SUBMENU_RETURN_CODE="1"
    else
        SUBMENU_RETURN_CODE="0"
    fi

    if [ "$SUBMENU_RETURN_CODE" = "1" ]; then
        clean_lines "4"
        return
    fi

    confirm_awg_interface_enable

    start_awg_interface_service

    echo ""
    printf "${GREEN}Interface ${BOLD_FS}\"${AWG_INTERFACE_NAME}\"${DEFAULT_FS} is succesfuly enabled.${DEFAULT_COLOR}\n"
    exit 0
}
