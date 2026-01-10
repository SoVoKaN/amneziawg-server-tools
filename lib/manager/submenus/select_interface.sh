get_awg_interfaces_count() {
    AWG_INTERFACES_COUNT="0"

    for DIR in "${AWG_SERVER_TOOLS_PATH}/interfaces/"*/; do
        if [ -d "$DIR" ]; then
            AWG_INTERFACES_COUNT="$((AWG_INTERFACES_COUNT + 1))"
        fi
    done
}

generate_select_awg_interface_submenu() {
    SELECT_AWG_INTERFACES_LIST=""
    SELECT_AWG_INTERFACE_SUBMENU=""

    CURRENT_INTERFACE_NUMBER="0"
    for DIR in "${AWG_SERVER_TOOLS_PATH}/interfaces/"*/; do
        CURRENT_INTERFACE_NUMBER="$((CURRENT_INTERFACE_NUMBER + 1))"
        CURRENT_INTERFACE_NAME="${DIR%/}"
        CURRENT_INTERFACE_NAME="${CURRENT_INTERFACE_NAME##*/}"

        SELECT_AWG_INTERFACES_LIST="${SELECT_AWG_INTERFACES_LIST}${CURRENT_INTERFACE_NAME} "

        SELECT_AWG_INTERFACE_SUBMENU="${SELECT_AWG_INTERFACE_SUBMENU}${CURRENT_INTERFACE_NUMBER}) ${CURRENT_INTERFACE_NAME}\n"
    done

    LAST_INTERFACE_NUMBER="$CURRENT_INTERFACE_NUMBER"

    SELECT_AWG_INTERFACE_SUBMENU="${SELECT_AWG_INTERFACE_SUBMENU}0) Back\n\n"

    SELECT_AWG_INTERFACE_SUBMENU="${SELECT_AWG_INTERFACE_SUBMENU}Select interface [0-${LAST_INTERFACE_NUMBER}]: "
}

set_awg_interface_name() {
    NUM="0"
    for CURRENT_INTERFACE_NAME in $SELECT_AWG_INTERFACES_LIST; do
        NUM="$((NUM + 1))"

        if [ "$NUM" = "$1" ]; then
            AWG_INTERFACE_NAME="$CURRENT_INTERFACE_NAME"
            break
        fi
    done
}


select_awg_interface_submenu() {
    LIMIT_AWG_INTERFACE_EXCEEDED_HANDLER="$1"

    get_awg_interfaces_count

    if [ "$AWG_INTERFACES_COUNT" -gt 15 ]; then
        "$LIMIT_AWG_INTERFACE_EXCEEDED_HANDLER"
        return
    fi

    generate_select_awg_interface_submenu

    while :; do
        printf "${SELECT_AWG_INTERFACE_SUBMENU}"

        handle_user_input

        clean_lines "$((LAST_INTERFACE_NUMBER + 3))"

        case "$USER_INPUT" in
            [1-9] | [1-9][0-9])
                if [ "$USER_INPUT" -gt "$LAST_INTERFACE_NUMBER" ]; then
                    continue
                fi

                set_awg_interface_name "$USER_INPUT"
                break
                ;;
            "0")
                return 1
                ;;
        esac
    done
}
