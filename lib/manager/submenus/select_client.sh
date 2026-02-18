get_awg_active_clients_count() {
    if AWG_CLIENTS_COUNT_GREP_OUTPUT=$(grep '^\[Peer\]' "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"); then
        AWG_CLIENTS_COUNT=$(echo "$AWG_CLIENTS_COUNT_GREP_OUTPUT" | wc -l)
    else
        AWG_CLIENTS_COUNT="0"
    fi
}

get_awg_inactive_clients_count() {
    if AWG_CLIENTS_COUNT_GREP_OUTPUT=$(grep '^#\[Peer\]' "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"); then
        AWG_CLIENTS_COUNT=$(echo "$AWG_CLIENTS_COUNT_GREP_OUTPUT" | wc -l)
    else
        AWG_CLIENTS_COUNT="0"
    fi
}

get_awg_all_clients_count() {
    AWG_CLIENTS_COUNT="0"

    for CLIENT_DATA_PATH in "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/clients/"*.data; do
        if [ ! -f "$CLIENT_DATA_PATH" ]; then
            return
        else
            break
        fi
    done

    for CLIENT_DATA_PATH in "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/clients/"*.data; do
        AWG_CLIENTS_COUNT="$((AWG_CLIENTS_COUNT + 1))"
    done
}

set_awg_no_active_clients_message() {
    SELECT_CLIENT_SUBMENU_FAILURE_RETURN_MESSAGE="There are no active clients."
}

set_awg_no_inactive_clients_message() {
    SELECT_CLIENT_SUBMENU_FAILURE_RETURN_MESSAGE="There are no inactive clients."
}

set_awg_no_all_clients_message() {
    SELECT_CLIENT_SUBMENU_FAILURE_RETURN_MESSAGE="No clients have been created yet."
}

generate_select_awg_active_clients_submenu() {
    GENERATE_SELECT_AWG_CLIENTS_AWK_OUTPUT=$(awk '
prev ~ "^###" && $0 == "[Peer]" {
    current_client_number++

    split(prev, arr, " ")

    select_awg_clients_list = select_awg_clients_list arr[2] " "

    select_awg_clients_submenu = select_awg_clients_submenu current_client_number ") " arr[2] "\\n"
}
{ prev = $0 }
END {
    printf "%s|%s|%s", current_client_number, select_awg_clients_list, select_awg_clients_submenu
}
' "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf")

    IFS="|"

    set -- $GENERATE_SELECT_AWG_CLIENTS_AWK_OUTPUT

    unset IFS

    LAST_CLIENT_NUMBER="$1"

    SELECT_AWG_CLIENTS_LIST="$2"

    SELECT_AWG_CLIENT_SUBMENU="$3"

    SELECT_AWG_CLIENT_SUBMENU="${SELECT_AWG_CLIENT_SUBMENU}0) Back\n\n"

    SELECT_AWG_CLIENT_SUBMENU="${SELECT_AWG_CLIENT_SUBMENU}Select interface [0-${LAST_CLIENT_NUMBER}]: "
}

generate_select_awg_inactive_clients_submenu() {
    GENERATE_SELECT_AWG_CLIENTS_AWK_OUTPUT=$(awk '
prev ~ "^###" && $0 == "#[Peer]" {
    current_client_number++

    split(prev, arr, " ")

    select_awg_clients_list = select_awg_clients_list arr[2] " "

    select_awg_clients_submenu = select_awg_clients_submenu current_client_number ") " arr[2] "\\n"
}
{ prev = $0 }
END {
    printf "%s|%s|%s", current_client_number, select_awg_clients_list, select_awg_clients_submenu
}
' "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf")

    IFS="|"

    set -- $GENERATE_SELECT_AWG_CLIENTS_AWK_OUTPUT

    unset IFS

    LAST_CLIENT_NUMBER="$1"

    SELECT_AWG_CLIENTS_LIST="$2"

    SELECT_AWG_CLIENT_SUBMENU="$3"

    SELECT_AWG_CLIENT_SUBMENU="${SELECT_AWG_CLIENT_SUBMENU}0) Back\n\n"

    SELECT_AWG_CLIENT_SUBMENU="${SELECT_AWG_CLIENT_SUBMENU}Select interface [0-${LAST_CLIENT_NUMBER}]: "
}

generate_select_awg_all_clients_submenu() {
    SELECT_AWG_CLIENTS_LIST=""
    SELECT_AWG_CLIENT_SUBMENU=""

    CURRENT_CLIENT_NUMBER="0"
    for CLIENT_DATA_PATH in "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/clients/"*.data; do
        CURRENT_CLIENT_NUMBER="$((CURRENT_CLIENT_NUMBER + 1))"
        CURRENT_CLIENT_NAME="${CLIENT_DATA_PATH##*/}"
        CURRENT_CLIENT_NAME="${CURRENT_CLIENT_NAME%.data}"

        SELECT_AWG_CLIENTS_LIST="${SELECT_AWG_CLIENTS_LIST}${CURRENT_CLIENT_NAME} "

        SELECT_AWG_CLIENT_SUBMENU="${SELECT_AWG_CLIENT_SUBMENU}${CURRENT_CLIENT_NUMBER}) ${CURRENT_CLIENT_NAME}\n"
    done

    LAST_CLIENT_NUMBER="$CURRENT_CLIENT_NUMBER"

    SELECT_AWG_CLIENT_SUBMENU="${SELECT_AWG_CLIENT_SUBMENU}0) Back\n\n"

    SELECT_AWG_CLIENT_SUBMENU="${SELECT_AWG_CLIENT_SUBMENU}Select interface [0-${LAST_CLIENT_NUMBER}]: "
}


get_awg_clients_count() {
    case "$SUBMENU_MODE" in
        "active")
            get_awg_active_clients_count
            ;;
        "inactive")
            get_awg_inactive_clients_count
            ;;
        "all")
            get_awg_all_clients_count
            ;;
    esac
}

set_awg_no_clients_message() {
    case "$SUBMENU_MODE" in
        "active")
            set_awg_no_active_clients_message
            ;;
        "inactive")
            set_awg_no_inactive_clients_message
            ;;
        "all")
            set_awg_no_all_clients_message
            ;;
    esac
}

generate_select_awg_clients_submenu() {
    case "$SUBMENU_MODE" in
        "active")
            generate_select_awg_active_clients_submenu
            ;;
        "inactive")
            generate_select_awg_inactive_clients_submenu
            ;;
        "all")
            generate_select_awg_all_clients_submenu
            ;;
    esac
}

set_awg_client_name() {
    NUM="0"
    for CURRENT_CLIENT_NAME in $SELECT_AWG_CLIENTS_LIST; do
        NUM="$((NUM + 1))"

        if [ "$NUM" = "$1" ]; then
            AWG_CLIENT_NAME="$CURRENT_CLIENT_NAME"
            break
        fi
    done
}


select_awg_client_submenu() {
    LIMIT_AWG_CLIENTS_EXCEEDED_HANDLER="$1"
    SUBMENU_MODE="$2"

    get_awg_clients_count

    if [ "$AWG_CLIENTS_COUNT" = "0" ]; then
        set_awg_no_clients_message

        return 2
    fi

    get_terminal_rows

    if [ "$((AWG_CLIENTS_COUNT + 7))" -gt "$TERMINAL_ROWS" ]; then
        "$LIMIT_AWG_CLIENTS_EXCEEDED_HANDLER"
        return
    fi

    generate_select_awg_clients_submenu

    while :; do
        printf "${SELECT_AWG_CLIENT_SUBMENU}"

        handle_user_input

        clean_lines "$((LAST_CLIENT_NUMBER + 3))"

        case "$USER_INPUT" in
            [1-9] | [1-9][0-9])
                if [ "$USER_INPUT" -gt "$LAST_CLIENT_NUMBER" ]; then
                    continue
                fi

                set_awg_client_name "$USER_INPUT"
                break
                ;;
            "0")
                return 1
                ;;
        esac
    done
}
