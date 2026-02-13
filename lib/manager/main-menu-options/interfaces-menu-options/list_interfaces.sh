check_awg_has_interfaces() {
    for DIR in "${AWG_SERVER_TOOLS_PATH}/interfaces/"*/; do
        if [ -d "$DIR" ]; then
            return
        fi
    done

    return 1
}

create_awg_interfaces_list() {
    ACTIVE_INTERFACES=$(awg show interfaces)
    ACTIVE_INTERFACES=" ${ACTIVE_INTERFACES} "

    ACTIVE_INTERFACES_LIST=""

    INACTIVE_INTERFACES_LIST=""

    for DIR in "${AWG_SERVER_TOOLS_PATH}/interfaces/"*/; do
        CURRENT_INTERFACE_NAME="${DIR%/}"
        CURRENT_INTERFACE_NAME="${CURRENT_INTERFACE_NAME##*/}"

        . "${AWG_SERVER_TOOLS_PATH}/interfaces/${CURRENT_INTERFACE_NAME}/${CURRENT_INTERFACE_NAME}.data"

        INTERFACE_IS_ACTIVE="Inactive"

        case "$ACTIVE_INTERFACES" in
            *" ${CURRENT_INTERFACE_NAME} "*)
                INTERFACE_IS_ACTIVE="Active"

                if INTERFACE_COUNT_CLIENTS_GREP_OUTPUT=$(grep '^\[Peer\]$' /etc/amnezia/amneziawg/${CURRENT_INTERFACE_NAME}.conf); then
                    INTERFACE_COUNT_CLIENTS=$(echo "$INTERFACE_COUNT_CLIENTS_GREP_OUTPUT" | wc -l)
                else
                    INTERFACE_COUNT_CLIENTS="0"
                fi

                ACTIVE_INTERFACES_LIST="${ACTIVE_INTERFACES_LIST}${CURRENT_INTERFACE_NAME} (${INTERFACE_IS_ACTIVE}, Clients: ${INTERFACE_COUNT_CLIENTS},"

                case "$AWG_INTERFACE_IP_VERSION_USE" in
                    "ipv4")
                        ACTIVE_INTERFACES_LIST="${ACTIVE_INTERFACES_LIST} IPv4: ${AWG_INTERFACE_IPV4}"
                        ;;
                    "ipv6")
                        ACTIVE_INTERFACES_LIST="${ACTIVE_INTERFACES_LIST} IPv6: ${AWG_INTERFACE_IPV6}"
                        ;;
                    "both")
                        ACTIVE_INTERFACES_LIST="${ACTIVE_INTERFACES_LIST} IPv4: ${AWG_INTERFACE_IPV4}, IPv6: ${AWG_INTERFACE_IPV6}"
                        ;;
                esac

                ACTIVE_INTERFACES_LIST="${ACTIVE_INTERFACES_LIST})\n"

                continue
                ;;
        esac

        INACTIVE_INTERFACES_LIST="${INACTIVE_INTERFACES_LIST}${CURRENT_INTERFACE_NAME} (${INTERFACE_IS_ACTIVE},"

        case "$AWG_INTERFACE_IP_VERSION_USE" in
            "ipv4")
                INACTIVE_INTERFACES_LIST="${INACTIVE_INTERFACES_LIST} IPv4: ${AWG_INTERFACE_IPV4}"
                ;;
            "ipv6")
                INACTIVE_INTERFACES_LIST="${INACTIVE_INTERFACES_LIST} IPv6: ${AWG_INTERFACE_IPV6}"
                ;;
            "both")
                INACTIVE_INTERFACES_LIST="${INACTIVE_INTERFACES_LIST} IPv4: ${AWG_INTERFACE_IPV4}, IPv6: ${AWG_INTERFACE_IPV6}"
                ;;
        esac

        INACTIVE_INTERFACES_LIST="${INACTIVE_INTERFACES_LIST})\n"
    done

    INTERFACES_LIST="AmneziaWG Interfaces\n\n${ACTIVE_INTERFACES_LIST}${INACTIVE_INTERFACES_LIST}"
}

print_awg_interfaces() {
    if [ -n "$AWG_SERVER_TOOLS_PAGER" ]; then
        printf "$INTERFACES_LIST" | "$AWG_SERVER_TOOLS_PAGER"
    else
        printf "$INTERFACES_LIST"
    fi
}

list_awg_interfaces() {
    set_awg_server_tools_pager

    if ! check_awg_has_interfaces; then
        if [ -n "$AWG_SERVER_TOOLS_PAGER" ]; then
            printf "No interfaces have been created yet." | "$AWG_SERVER_TOOLS_PAGER"
        else
            printf "\n${BOLD_FS}No interfaces have been created yet.${DEFAULT_FS}\n\n"
        fi

        return
    fi

    create_awg_interfaces_list

    print_awg_interfaces
}
