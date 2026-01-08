generate_choose_awg_interface_submenu() {
    CHOOSE_AWG_INTERFACES_LIST=""
    CHOOSE_AWG_INTERFACE_SUBMENU=""

    CURRENT_INTERFACE_NUMBER="0"
    for DIR in "${AWG_SERVER_TOOLS_PATH}/interfaces/"*/; do
        CURRENT_INTERFACE_NUMBER="$((CURRENT_INTERFACE_NUMBER + 1))"
        CURRENT_INTERFACE_NAME="${DIR%/}"
        CURRENT_INTERFACE_NAME="${CURRENT_INTERFACE_NAME##*/}"

        CHOOSE_AWG_INTERFACES_LIST="${CHOOSE_AWG_INTERFACES_LIST}${CURRENT_INTERFACE_NAME} "

        CHOOSE_AWG_INTERFACE_SUBMENU="${CHOOSE_AWG_INTERFACE_SUBMENU}${CURRENT_INTERFACE_NUMBER}) ${CURRENT_INTERFACE_NAME}\n"
    done

    CHOOSE_AWG_INTERFACE_SUBMENU="${CHOOSE_AWG_INTERFACE_SUBMENU}0) Back\n\n"
}

choose_awg_interface() {
    NUM="0"
    for CURRENT_INTERFACE_NAME in $CHOOSE_AWG_INTERFACES_LIST; do
        NUM="$((NUM + 1))"

        if [ "$NUM" = "$USER_INPUT" ]; then
            AWG_INTERFACE_NAME="$CURRENT_INTERFACE_NAME"
            break
        fi
    done
}


choose_awg_interface_submenu() {
    generate_choose_awg_interface_submenu

    while :; do
        printf "${CHOOSE_AWG_INTERFACE_SUBMENU}"

        printf 'Select interface [0-%s]: ' "$CURRENT_INTERFACE_NUMBER"

        handle_user_input

        clean_lines "$((CURRENT_INTERFACE_NUMBER + 3))"

        case "$USER_INPUT" in
            [1-9] | [1-9][0-9])
                if [ "$USER_INPUT" -gt "$CURRENT_INTERFACE_NUMBER" ]; then
                    continue
                fi

                choose_awg_interface "$USER_INPUT"
                break
                ;;
            "0")
                return 1
                ;;
        esac
    done
}
