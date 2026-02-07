get_awg_client_configs_path() {
    CURRENT_AWG_CLIENT_CONFIGS_PATH="$AWG_CLIENT_CONFIGS_PATH"

    while :; do
        printf 'Current client configs path: "%s"' "$CURRENT_AWG_CLIENT_CONFIGS_PATH"
        echo ""

        echo ""
        printf "${BOLD_FS}Enter new full client configs path.${DEFAULT_FS}\n"
        printf '%s' "Path: "

        handle_user_input

        echo ""

        TEMP="$USER_INPUT"

        ALL_CHARS_CORRECT="1"

        while [ -n "$TEMP" ]; do
            CHAR=${TEMP%${TEMP#?}}

            case "$CHAR" in
                ":" | "*" | "?" | "<" | ">" | "|")
                    ALL_CHARS_CORRECT="0"
                    break
                    ;;
            esac

            TEMP=${TEMP#?}
        done

        if [ "$ALL_CHARS_CORRECT" != "1" ]; then
            continue
        fi

        AWG_CLIENT_CONFIGS_PATH="$USER_INPUT"

        break
    done
}

confirm_awg_client_configs_path_change() {
    QUESTION=$(printf '%s' "This will change client configs path on \"${AWG_CLIENT_CONFIGS_PATH}\". Continue? (y/n): ")

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

check_awg_client_configs_directory_exists() {
    if [ -d "$AWG_CLIENT_CONFIGS_PATH" ]; then
        return 0
    fi

    return 1
}

change_config_awg_client_configs_path() {
    TEMP_FILE=$(mktemp)

    sed "s|AWG_CLIENT_CONFIGS_PATH=.*|AWG_CLIENT_CONFIGS_PATH=\"${AWG_CLIENT_CONFIGS_PATH}\"|" "${AWG_SERVER_TOOLS_PATH}/server-tools.conf" > "$TEMP_FILE"

    mv "$TEMP_FILE" "${AWG_SERVER_TOOLS_PATH}/server-tools.conf"
}


change_awg_client_configs_path() {
    echo "----------------------------"
    printf "${BOLD_FS} Change client configs path${DEFAULT_FS}\n"
    echo "----------------------------"
    echo ""

    get_awg_client_configs_path

    confirm_awg_client_configs_path_change

    if ! check_awg_client_configs_directory_exists; then
        echo "Selected path \"${AWG_CLIENT_CONFIGS_PATH}\" does not exists."
        exit 1
    fi

    change_config_awg_client_configs_path

    echo ""
    printf "${GREEN}Client configs path ${BOLD_FS}\"${AWG_CLIENT_CONFIGS_PATH}\"${DEFAULT_FS} is succesfuly changed.${DEFAULT_COLOR}\n"
    exit 0
}
