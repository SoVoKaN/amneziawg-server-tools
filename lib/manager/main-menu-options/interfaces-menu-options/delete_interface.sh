free_awg_interface_port() {
    TEMP_FILE=$(mktemp)

    sed "/^${1}$/d" "${AWG_SERVER_TOOLS_PATH}/interfaces/.ports_reserved" > "$TEMP_FILE"

    mv "$TEMP_FILE" "${AWG_SERVER_TOOLS_PATH}/interfaces/.ports_reserved"
}

free_awg_interface_ipv4() {
    TEMP_FILE=$(mktemp)

    sed "/^${1}$/d" "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv4_reserved" > "$TEMP_FILE"

    mv "$TEMP_FILE" "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv4_reserved"
}

free_awg_interface_ipv6() {
    AWG_CHECK_INTERFACE_IPV6="$1"

    AWG_CHECK_INTERFACE_IPV6_LEFT_SIDE=${AWG_CHECK_INTERFACE_IPV6%%::*}
    AWG_CHECK_INTERFACE_IPV6_RIGHT_SIDE=${AWG_CHECK_INTERFACE_IPV6#*::}

    if [ "$AWG_CHECK_INTERFACE_IPV6_LEFT_SIDE" = "$AWG_CHECK_INTERFACE_IPV6_RIGHT_SIDE" ]; then
        AWG_CHECK_INTERFACE_IPV6_RIGHT_SIDE=""
    fi


    IFS=":"

    AWG_CHECK_INTERFACE_IPV6_LEFT_SIDE_PARTS_COUNT="0"
    for PART in $AWG_CHECK_INTERFACE_IPV6_LEFT_SIDE; do
        AWG_CHECK_INTERFACE_IPV6_LEFT_SIDE_PARTS_COUNT=$((AWG_CHECK_INTERFACE_IPV6_LEFT_SIDE_PARTS_COUNT + 1))
    done

    AWG_CHECK_INTERFACE_IPV6_RIGHT_SIDE_PARTS_COUNT="0"
    for PART in $AWG_CHECK_INTERFACE_IPV6_RIGHT_SIDE; do
        AWG_CHECK_INTERFACE_IPV6_RIGHT_SIDE_PARTS_COUNT=$((AWG_CHECK_INTERFACE_IPV6_RIGHT_SIDE_PARTS_COUNT + 1))
    done


    AWG_CHECK_INTERFACE_IPV6_LEFT_SIDE_PARTS_PROCESSED=""

    if [ "$AWG_CHECK_INTERFACE_IPV6_LEFT_SIDE_PARTS_COUNT" != "0" ]; then
        for PART in $AWG_CHECK_INTERFACE_IPV6_LEFT_SIDE; do
            PROCESSED_PART=$(printf '%04x' "0x${PART}")
            AWG_CHECK_INTERFACE_IPV6_LEFT_SIDE_PARTS_PROCESSED="${AWG_CHECK_INTERFACE_IPV6_LEFT_SIDE_PARTS_PROCESSED}${PROCESSED_PART}:"
        done
    fi

    AWG_CHECK_INTERFACE_IPV6_RIGHT_SIDE_PARTS_PROCESSED=""

    if [ "$AWG_CHECK_INTERFACE_IPV6_RIGHT_SIDE_PARTS_COUNT" != "0" ]; then
        for PART in $AWG_CHECK_INTERFACE_IPV6_RIGHT_SIDE; do
            PROCESSED_PART=$(printf '%04x' "0x${PART}")
            AWG_CHECK_INTERFACE_IPV6_RIGHT_SIDE_PARTS_PROCESSED="${AWG_CHECK_INTERFACE_IPV6_RIGHT_SIDE_PARTS_PROCESSED}${PROCESSED_PART}:"
        done
    fi


    AWG_CHECK_INTERFACE_IPV6_MISSING_PARTS=$((8 - AWG_CHECK_INTERFACE_IPV6_LEFT_SIDE_PARTS_COUNT - AWG_CHECK_INTERFACE_IPV6_RIGHT_SIDE_PARTS_COUNT))

    while [ "$AWG_CHECK_INTERFACE_IPV6_MISSING_PARTS" -gt 0 ]; do
        AWG_CHECK_INTERFACE_IPV6_LEFT_SIDE_PARTS_PROCESSED="${AWG_CHECK_INTERFACE_IPV6_LEFT_SIDE_PARTS_PROCESSED}0000:"
        
        AWG_CHECK_INTERFACE_IPV6_MISSING_PARTS=$((AWG_CHECK_INTERFACE_IPV6_MISSING_PARTS - 1))
    done
    

    AWG_CHECK_INTERFACE_IPV6_ALL_PARTS="${AWG_CHECK_INTERFACE_IPV6_LEFT_SIDE_PARTS_PROCESSED}${AWG_CHECK_INTERFACE_IPV6_RIGHT_SIDE_PARTS_PROCESSED}"

    AWG_CHECK_INTERFACE_IPV6_ALL_PARTS="${AWG_CHECK_INTERFACE_IPV6_ALL_PARTS%?}"

    unset IFS

    TEMP_FILE=$(mktemp)

    sed "/^${AWG_CHECK_INTERFACE_IPV6_ALL_PARTS}$/d" "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv6_reserved" > "$TEMP_FILE"

    mv "$TEMP_FILE" "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv6_reserved"
}


get_awg_interface_name_to_delete() {
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

        AWG_INTERFACE_NAME="$USER_INPUT"

        break
    done
}

confirm_awg_interface_deletion() {
    QUESTION=$(printf '%s' "This will permanently delete \"${AWG_INTERFACE_NAME}\" interface. Continue? (y/n): ")

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

delete_awg_interface_configs() {
    rm -f "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"

    . "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/${AWG_INTERFACE_NAME}.data"

    free_awg_interface_port "${AWG_INTERFACE_PORT}"

    free_awg_interface_ipv4 "${AWG_INTERFACE_IPV4}"

    free_awg_interface_ipv6 "${AWG_INTERFACE_IPV6}"

    rm -rf "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}"
}


delete_awg_interface() {
    echo "------------------"
    printf "${BOLD_FS} Delete Interface ${DEFAULT_FS}\n"
    echo "------------------"
    echo ""

    get_awg_interface_name_to_delete

    confirm_awg_interface_deletion

    stop_awg_interface_service

    delete_awg_interface_configs

    echo ""
    printf "${GREEN}Interface ${BOLD_FS}\"${AWG_INTERFACE_NAME}\"${DEFAULT_FS} is succesfuly deleted.${DEFAULT_COLOR}\n"
}
