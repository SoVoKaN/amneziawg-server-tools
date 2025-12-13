check_awg_client_exists() {
    for FILE in "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/clients/"*.data; do
        if [ ! -f "$FILE" ]; then
            continue
        fi

        CLIENT_NAME="${FILE##*/}"
        CLIENT_NAME="${CLIENT_NAME%.data}"

        if [ "$1" = "$CLIENT_NAME" ]; then
            return 0
        fi
    done

    return 1
}


get_awg_client_name_to_delete() {
    while :; do
        printf "${BOLD_FS}Enter client name to delete.${DEFAULT_FS}\n"
        printf '%s' "Name: "

        handle_user_input

        echo ""

        if [ -z "$USER_INPUT" ]; then
            echo "Client name can not be empty."
            exit 1
        fi

        if [ ${#USER_INPUT} -gt 15 ]; then
            echo "Client name length must be < 16."
            exit 1
        fi

        if ! check_awg_client_exists "$USER_INPUT"; then
            echo "Client \"${USER_INPUT}\" does not exists."
            exit 1
        fi

        AWG_CLIENT_NAME="$USER_INPUT"

        break
    done
}

confirm_awg_client_deletion() {
    QUESTION=$(printf '%s' "This will permanently delete ${AWG_CLIENT_NAME} client. Continue? (y/n): ")

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

delete_awg_client_in_interface_config() {
    TEMP_FILE=$(mktemp)

    awk -v n="5" -v pattern="# ${AWG_CLIENT_NAME}" '
$0 == pattern { skip = n; next }
skip > 0 { skip--; next }
{ print }
' "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf" > "$TEMP_FILE"

    mv "$TEMP_FILE" "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"
}

delete_awg_client_data() {
    rm -f "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/clients/${AWG_CLIENT_NAME}.data"
}

bring_down_awg_client() {
    TEMP_FILE=$(mktemp)

    awg-quick strip "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf" > "$TEMP_FILE" 2>/dev/null

    awg syncconf "$AWG_INTERFACE_NAME" "$TEMP_FILE"

    rm "$TEMP_FILE"
}


delete_awg_client() {
    print_dashes "$((18 + ${#AWG_INTERFACE_NAME}))"

    printf "${BOLD_FS} Delete client [${AWG_INTERFACE_NAME}] ${DEFAULT_FS}\n"

    print_dashes "$((18 + ${#AWG_INTERFACE_NAME}))"
    echo ""

    get_awg_client_name_to_delete

    confirm_awg_client_deletion

    delete_awg_client_in_interface_config

    delete_awg_client_data

    bring_down_awg_client

    echo ""
    printf "${GREEN}Client ${BOLD_FS}\"${AWG_CLIENT_NAME}\"${DEFAULT_FS} is succesfuly deleted.${DEFAULT_COLOR}\n"
}
