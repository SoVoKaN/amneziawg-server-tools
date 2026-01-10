set_awg_list_clients_pager() {
    LIST_CLIENTS_PAGER=""

    if command -v less > /dev/null 2>&1; then
        LIST_CLIENTS_PAGER="less"
        return
    fi

    if command -v more > /dev/null 2>&1; then
        LIST_CLIENTS_PAGER="more"
        return
    fi
}


check_has_awg_interface_clients() {
    for FILE in "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/clients/"*.data; do
        if [ -f "$FILE" ]; then
            return
        fi
    done

    return 1
}

create_clients_list() {
    CLIENTS_LIST="\"${AWG_INTERFACE_NAME}\" clients\n\n"

    for CLIENT_DATA_PATH in "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/clients/"*.data; do
        CURRENT_CLIENT_NAME="${CLIENT_DATA_PATH##*/}"
        CURRENT_CLIENT_NAME="${CURRENT_CLIENT_NAME%.data}"

        . "$CLIENT_DATA_PATH"

        CLIENTS_LIST="${CLIENTS_LIST}${CURRENT_CLIENT_NAME} (IPv4: ${AWG_CLIENT_IPV4}"

        if [ "$AWG_INTERFACE_USE_IPV6" = "y" ]; then
            CLIENTS_LIST="${CLIENTS_LIST}, IPv6: ${AWG_CLIENT_IPV6}"
        fi

        CLIENTS_LIST="${CLIENTS_LIST})\n"
    done
}

print_clients() {
    if [ -n "$LIST_CLIENTS_PAGER" ]; then
        printf "$CLIENTS_LIST" | "$LIST_CLIENTS_PAGER"
    else
        printf "$CLIENTS_LIST"
    fi
}


list_awg_clients() {
    set_awg_list_clients_pager

    if ! check_has_awg_interface_clients; then
        if [ -n "$LIST_CLIENTS_PAGER" ]; then
            printf "No clients have been created yet." | "$LIST_CLIENTS_PAGER"
        else
            echo "No clients have been created yet."
        fi

        return
    fi

    create_clients_list

    print_clients
}
