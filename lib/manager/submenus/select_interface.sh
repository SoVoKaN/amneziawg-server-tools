get_awg_active_interfaces_count() {
    AWG_INTERFACES_COUNT="0"

    for DIR in "${AWG_SERVER_TOOLS_PATH}/interfaces/"*/; do
        if [ ! -d "$DIR" ]; then
            return
        fi
    done

    ACTIVE_AWG_INTERFACES=$(awg show interfaces)
    ACTIVE_AWG_INTERFACES=" ${ACTIVE_AWG_INTERFACES} "

    for DIR in "${AWG_SERVER_TOOLS_PATH}/interfaces/"*/; do
        CURRENT_INTERFACE_NAME="${DIR%/}"
        CURRENT_INTERFACE_NAME="${CURRENT_INTERFACE_NAME##*/}"

        case "$ACTIVE_AWG_INTERFACES" in
            *" ${CURRENT_INTERFACE_NAME} "*) AWG_INTERFACES_COUNT="$((AWG_INTERFACES_COUNT + 1))" ;;
        esac
    done
}

get_awg_inactive_interfaces_count() {
    AWG_INTERFACES_COUNT="0"

    for DIR in "${AWG_SERVER_TOOLS_PATH}/interfaces/"*/; do
        if [ ! -d "$DIR" ]; then
            return
        fi
    done

    ACTIVE_AWG_INTERFACES=$(awg show interfaces)
    ACTIVE_AWG_INTERFACES=" ${ACTIVE_AWG_INTERFACES} "

    for DIR in "${AWG_SERVER_TOOLS_PATH}/interfaces/"*/; do
        CURRENT_INTERFACE_NAME="${DIR%/}"
        CURRENT_INTERFACE_NAME="${CURRENT_INTERFACE_NAME##*/}"

        case "$ACTIVE_AWG_INTERFACES" in
            *" ${CURRENT_INTERFACE_NAME} "*) continue ;;
        esac

        AWG_INTERFACES_COUNT="$((AWG_INTERFACES_COUNT + 1))"
    done
}

get_awg_all_interfaces_count() {
    AWG_INTERFACES_COUNT="0"

    for DIR in "${AWG_SERVER_TOOLS_PATH}/interfaces/"*/; do
        if [ ! -d "$DIR" ]; then
            return
        fi
    done

    for DIR in "${AWG_SERVER_TOOLS_PATH}/interfaces/"*/; do
        AWG_INTERFACES_COUNT="$((AWG_INTERFACES_COUNT + 1))"
    done
}

show_awg_no_active_interfaces_message() {
    if [ -n "$AWG_SERVER_TOOLS_PAGER" ]; then
        printf "There are no active interfaces." | "$AWG_SERVER_TOOLS_PAGER"
    else
        echo "There are no active interfaces."
    fi
}

show_awg_no_inactive_interfaces_message() {
    if [ -n "$AWG_SERVER_TOOLS_PAGER" ]; then
        printf "There are no inactive interfaces." | "$AWG_SERVER_TOOLS_PAGER"
    else
        echo "There are no inactive interfaces."
    fi
}

show_awg_no_all_interfaces_message() {
    if [ -n "$AWG_SERVER_TOOLS_PAGER" ]; then
        printf "No interfaces have been created yet." | "$AWG_SERVER_TOOLS_PAGER"
    else
        echo "No interfaces have been created yet."
    fi
}

generate_select_awg_active_interface_submenu() {
    ACTIVE_AWG_INTERFACES=$(awg show interfaces)
    ACTIVE_AWG_INTERFACES=" ${ACTIVE_AWG_INTERFACES} "

    SELECT_AWG_INTERFACES_LIST=""
    SELECT_AWG_INTERFACE_SUBMENU=""

    CURRENT_INTERFACE_NUMBER="0"
    for DIR in "${AWG_SERVER_TOOLS_PATH}/interfaces/"*/; do
        CURRENT_INTERFACE_NAME="${DIR%/}"
        CURRENT_INTERFACE_NAME="${CURRENT_INTERFACE_NAME##*/}"

        case "$ACTIVE_AWG_INTERFACES" in
            *" ${CURRENT_INTERFACE_NAME} "*)
                CURRENT_INTERFACE_NUMBER="$((CURRENT_INTERFACE_NUMBER + 1))"

                SELECT_AWG_INTERFACES_LIST="${SELECT_AWG_INTERFACES_LIST}${CURRENT_INTERFACE_NAME} "

                SELECT_AWG_INTERFACE_SUBMENU="${SELECT_AWG_INTERFACE_SUBMENU}${CURRENT_INTERFACE_NUMBER}) ${CURRENT_INTERFACE_NAME}\n"
                ;;
        esac
    done

    LAST_INTERFACE_NUMBER="$CURRENT_INTERFACE_NUMBER"

    SELECT_AWG_INTERFACE_SUBMENU="${SELECT_AWG_INTERFACE_SUBMENU}0) Back\n\n"

    SELECT_AWG_INTERFACE_SUBMENU="${SELECT_AWG_INTERFACE_SUBMENU}Select interface [0-${LAST_INTERFACE_NUMBER}]: "
}

generate_select_awg_inactive_interface_submenu() {
    ACTIVE_AWG_INTERFACES=$(awg show interfaces)
    ACTIVE_AWG_INTERFACES=" ${ACTIVE_AWG_INTERFACES} "

    SELECT_AWG_INTERFACES_LIST=""
    SELECT_AWG_INTERFACE_SUBMENU=""

    CURRENT_INTERFACE_NUMBER="0"
    for DIR in "${AWG_SERVER_TOOLS_PATH}/interfaces/"*/; do
        CURRENT_INTERFACE_NAME="${DIR%/}"
        CURRENT_INTERFACE_NAME="${CURRENT_INTERFACE_NAME##*/}"

        case "$ACTIVE_AWG_INTERFACES" in
            *" ${CURRENT_INTERFACE_NAME} "*) continue ;;
        esac

        CURRENT_INTERFACE_NUMBER="$((CURRENT_INTERFACE_NUMBER + 1))"

        SELECT_AWG_INTERFACES_LIST="${SELECT_AWG_INTERFACES_LIST}${CURRENT_INTERFACE_NAME} "

        SELECT_AWG_INTERFACE_SUBMENU="${SELECT_AWG_INTERFACE_SUBMENU}${CURRENT_INTERFACE_NUMBER}) ${CURRENT_INTERFACE_NAME}\n"
    done

    LAST_INTERFACE_NUMBER="$CURRENT_INTERFACE_NUMBER"

    SELECT_AWG_INTERFACE_SUBMENU="${SELECT_AWG_INTERFACE_SUBMENU}0) Back\n\n"

    SELECT_AWG_INTERFACE_SUBMENU="${SELECT_AWG_INTERFACE_SUBMENU}Select interface [0-${LAST_INTERFACE_NUMBER}]: "
}

generate_select_awg_all_interface_submenu() {
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


get_awg_interfaces_count() {
    case "$SUBMENU_MODE" in
        "active")
            get_awg_active_interfaces_count
            ;;
        "inactive")
            get_awg_inactive_interfaces_count
            ;;
        "all")
            get_awg_all_interfaces_count
            ;;
    esac
}

show_awg_no_interfaces_message() {
    case "$SUBMENU_MODE" in
        "active")
            show_awg_no_active_interfaces_message
            ;;
        "inactive")
            show_awg_no_inactive_interfaces_message
            ;;
        "all")
            show_awg_no_all_interfaces_message
            ;;
    esac
}

generate_select_awg_interface_submenu() {
    case "$SUBMENU_MODE" in
        "active")
            generate_select_awg_active_interface_submenu
            ;;
        "inactive")
            generate_select_awg_inactive_interface_submenu
            ;;
        "all")
            generate_select_awg_all_interface_submenu
            ;;
    esac
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
    SUBMENU_MODE="$2"

    get_awg_interfaces_count

    if [ "$AWG_INTERFACES_COUNT" = "0" ]; then
        set_awg_server_tools_pager

        show_awg_no_interfaces_message

        return 1
    fi

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
