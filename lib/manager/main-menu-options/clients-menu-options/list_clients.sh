set_awg_list_clients_pager() {
    LIST_CLIENTS_PAGER=""

    if command -v less > /dev/null 2>&1; then
        LIST_CLIENTS_PAGER="less"
        return 0
    fi

    if command -v more > /dev/null 2>&1; then
        LIST_CLIENTS_PAGER="more"
        return 0
    fi

    return 1
}


check_has_awg_interface_clients() {
    for FILE in "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/clients/"*.data; do
        if [ -f "$FILE" ]; then
            return
        fi
    done

    echo "No clients have been created yet."
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
    if set_awg_list_clients_pager; then
        printf "$CLIENTS_LIST" | "$LIST_CLIENTS_PAGER"
        return
    fi

    printf "$CLIENTS_LIST"
}


list_awg_clients() {
    check_has_awg_interface_clients

    create_clients_list

    print_clients
}
