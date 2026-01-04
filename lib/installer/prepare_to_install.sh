confirm_installation() {
    QUESTION=$(printf '%s' "Do you want to continue with installation (y/n): ")

    printf '%s' "$QUESTION"

    handle_user_input

    if [ -z "$USER_INPUT" ]; then
        default_value_autocomplete "n" "$QUESTION"
    fi

    echo ""

    case "$USER_INPUT" in
        "y" | "yes" | "Y" | "YES") ;;
        *)
            echo "Aborted."
            exit 0
            ;;
    esac
}


ask_server_has_ipv6() {
    IPV6_SUPPORT_ENABLED=""

    while :; do
        printf 'Enable IPv6 support (y/n): '

        handle_user_input

        case "$USER_INPUT" in
            "n" | "no" | "N" | "NO") IPV6_SUPPORT_ENABLED="n" ;;
            "y" | "yes" | "Y" | "YES") IPV6_SUPPORT_ENABLED="y" ;;
            *) continue ;;
        esac

        break
    done
}

get_server_public_network_interface() {
    SERVER_PUBLIC_NETWORK_INTERFACE=$(ip -4 route 2>/dev/null | awk '/^default/ { for (i=1; i<=NF; i++) if ($i=="dev") { print $(i+1); exit 0 } }')

    while :; do
        QUESTION=$(printf 'Public network interface [%s]: ' "$SERVER_PUBLIC_NETWORK_INTERFACE")

        printf '%s' "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            if [ ${#USER_INPUT} -gt 15 ]; then
                continue
            fi

            TEMP="$USER_INPUT"

            ALL_CHARS_CORRECT="1"

            while [ -n "$TEMP" ]; do
                CHAR=${TEMP%${TEMP#?}}

                case "$CHAR" in
                    [!a-zA-Z0-9_])
                        ALL_CHARS_CORRECT="0"
                        break
                        ;;
                esac

                TEMP=${TEMP#?}
            done

            if [ "$ALL_CHARS_CORRECT" != "1" ]; then
                continue
            fi

            SERVER_PUBLIC_NETWORK_INTERFACE="$USER_INPUT"
        else
            default_value_autocomplete "$SERVER_PUBLIC_NETWORK_INTERFACE" "$QUESTION"
        fi

        break
    done
}

get_server_public_ip_or_domain() {
    SERVER_PUBLIC_IP_OR_DOMAIN=$(ip -4 addr 2>/dev/null | awk '/scope global/ { sub(/\/.*/, "", $2); print $2; exit }')

    if [ "$IPV6_SUPPORT_ENABLED" = "y" ]; then
        if [ -z "$SERVER_PUBLIC_IP_OR_DOMAIN" ]; then
            SERVER_PUBLIC_IP_OR_DOMAIN=$(ip -6 addr 2>/dev/null | awk '/scope global/ { sub(/\/.*/, "", $2); print $2; exit }')
        fi
    fi

    while :; do
        QUESTION=$(printf 'Public IPv4/IPv6 address or domain [%s]: ' "$SERVER_PUBLIC_IP_OR_DOMAIN")

        printf '%s' "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            SERVER_PUBLIC_IP_OR_DOMAIN="$USER_INPUT"
        else
            default_value_autocomplete "$SERVER_PUBLIC_IP_OR_DOMAIN" "$QUESTION"
        fi
        
        break
    done
}

get_awg_client_configs_path() {
    AWG_CLIENT_CONFIGS_PATH="/etc/amnezia/amneziawg/client-configs"

    while :; do
        QUESTION=$(printf 'AmneziaWG client configs full path [%s]: ' "$AWG_CLIENT_CONFIGS_PATH")

        printf '%s' "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
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
        else
            default_value_autocomplete "$AWG_CLIENT_CONFIGS_PATH" "$QUESTION"
        fi

        break
    done
}


ask_to_install_qrencode() {
    INSTALL_QRENCODE="y"

    while :; do
        QUESTION=$(printf 'Do you want to enable client QR display option (y/n) [%s]: ' "$INSTALL_QRENCODE")

        printf '%s' "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            case "$USER_INPUT" in
                "n" | "no" | "N" | "NO") INSTALL_QRENCODE="n" ;;
                "y" | "yes" | "Y" | "YES") INSTALL_QRENCODE="y" ;;
                *) continue ;;
            esac
        else
            default_value_autocomplete "$INSTALL_QRENCODE" "$QUESTION"
        fi

        break
    done
}


is_ready_to_continue() {
    printf "Press ${BOLD_FS}Enter${DEFAULT_FS} to continue..."

    ENTER=$(printf '\012')

    OLD_STTY=$(stty -g)

    trap 'echo ""; stty $OLD_STTY; exit' INT TERM HUP QUIT

    stty -echo -icanon min 1 time 0

    while :; do
        CHAR=$(dd bs=1 count=1 2>/dev/null)

        if [ "$CHAR" = "$ENTER" ]; then
            break
        fi
    done

    stty "$OLD_STTY"
}


prepare_to_install() {
    confirm_installation

    echo ""
    printf "Options require input. Default value is shown in [brackets] — press ${BOLD_FS}Enter${DEFAULT_FS} to ${GREEN}accept${DEFAULT_COLOR} it.\n"

    echo ""
    printf "${BOLD_FS}Server settings${DEFAULT_FS}\n"

    ask_server_has_ipv6

    get_server_public_network_interface

    get_server_public_ip_or_domain

    get_awg_client_configs_path

    echo ""
    printf "${BOLD_FS}Optional features${DEFAULT_FS}\n"

    ask_to_install_qrencode

    echo ""
    printf "${GREEN}Configuration done.${DEFAULT_COLOR}\n"
    
    is_ready_to_continue

    echo ""
    echo ""
}
