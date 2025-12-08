set_awg_list_interfaces_pager() {
    IFS=":"

    LIST_INTERFACES_PAGER=""

    if command -v less > /dev/null 2>&1; then
        LIST_INTERFACES_PAGER="less"
        return 0
    fi

    if command -v more > /dev/null 2>&1; then
        LIST_INTERFACES_PAGER="more"
        return 0
    fi

    unset IFS

    return 1
}


check_awg_has_interfaces() {
    for DIR in "${AWG_SERVER_TOOLS_PATH}/interfaces/"*/; do
        if [ -d "$DIR" ]; then
            return
        fi
    done

    echo "No interfaces have been created yet."
    exit 0
}

create_awg_interfaces_list() {
    ACTIVE_INTERFACES=$(awg show interfaces)

    ACTIVE_INTERFACES_LIST=""

    INACTIVE_INTERFACES_LIST=""

    for DIR in "${AWG_SERVER_TOOLS_PATH}/interfaces/"*/; do
        CURRENT_INTERFACE_NAME="${DIR%/}"
        CURRENT_INTERFACE_NAME="${CURRENT_INTERFACE_NAME##*/}"

        . "${AWG_SERVER_TOOLS_PATH}/interfaces/${CURRENT_INTERFACE_NAME}/${CURRENT_INTERFACE_NAME}.data"

        INTERFACE_IS_ACTIVE="Inactive"

        case "$ACTIVE_INTERFACES" in
            *"$CURRENT_INTERFACE_NAME"*)
                INTERFACE_IS_ACTIVE="Active"

                if INTERFACE_COUNT_CLIENTS_GREP_OUTPUT=$(grep '^\[Peer\]$' /etc/amnezia/amneziawg/${CURRENT_INTERFACE_NAME}.conf); then
                    INTERFACE_COUNT_CLIENTS=$(echo "$INTERFACE_COUNT_CLIENTS_GREP_OUTPUT" | wc -l)
                else
                    INTERFACE_COUNT_CLIENTS="0"
                fi

                ACTIVE_INTERFACES_LIST="${ACTIVE_INTERFACES_LIST}${CURRENT_INTERFACE_NAME} (${INTERFACE_IS_ACTIVE}, Clients: ${INTERFACE_COUNT_CLIENTS}, IPv4: ${AWG_INTERFACE_IPV4}, IPv6: ${AWG_INTERFACE_IPV6})\n"

                continue
                ;;
        esac

        INACTIVE_INTERFACES_LIST="${INACTIVE_INTERFACES_LIST}${CURRENT_INTERFACE_NAME} (${INTERFACE_IS_ACTIVE}, IPv4: ${AWG_INTERFACE_IPV4}, IPv6: ${AWG_INTERFACE_IPV6})\n"
    done

    INTERFACES_LIST="AmneziaWG Interfaces\n\n${ACTIVE_INTERFACES_LIST}${INACTIVE_INTERFACES_LIST}"
}

print_awg_interfaces() {
    if set_awg_list_interfaces_pager; then
        printf "$INTERFACES_LIST" | "$LIST_INTERFACES_PAGER"
        return
    fi

    printf "$INTERFACES_LIST"
}

list_awg_interfaces() {
    check_awg_has_interfaces

    create_awg_interfaces_list

    print_awg_interfaces
}
