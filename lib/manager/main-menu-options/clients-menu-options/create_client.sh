check_awg_interface_has_free_clients() {
    if INTERFACE_COUNT_CLIENTS_GREP_OUTPUT=$(grep '^\[Peer\]$' /etc/amnezia/amneziawg/${CURRENT_INTERFACE_NAME}.conf); then
        INTERFACE_COUNT_CLIENTS=$(echo "$INTERFACE_COUNT_CLIENTS_GREP_OUTPUT" | wc -l)
    else
        INTERFACE_COUNT_CLIENTS="0"
    fi

    if [ "$INTERFACE_COUNT_CLIENTS" -gt 251 ]; then
        echo "Maximum clients(252) reached on \"${AWG_INTERFACE_NAME}\" interface."
        exit 0
    fi
}

check_awg_client_ipv4_free() {
    if grep "${1}" "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf" > /dev/null 2>&1; then
        return 1
    fi

    return 0
}

generate_awg_client_ipv4() {
    AWG_CLIENT_IPV4_PREFIX="${AWG_INTERFACE_IPV4%.*}."
    AWG_POSSIBLE_CLIENT_IPV4_PART="2"

    while :; do
        AWG_CLIENT_POSSIBLE_IPV4="${AWG_CLIENT_IPV4_PREFIX}${AWG_POSSIBLE_CLIENT_IPV4_PART}"

        if ! check_awg_client_ipv4_free "$AWG_CLIENT_POSSIBLE_IPV4"; then
            AWG_POSSIBLE_CLIENT_IPV4_PART=$((AWG_POSSIBLE_CLIENT_IPV4_PART + 1))
        else
            break
        fi
    done

    AWG_CLIENT_IPV4="$AWG_CLIENT_POSSIBLE_IPV4"
}

check_awg_client_ipv6_free() {
    if grep "${1}" "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf" > /dev/null 2>&1; then
        return 1
    fi
}

generate_awg_client_ipv6() {
    AWG_CLIENT_IPV6_PREFIX="${AWG_INTERFACE_IPV6%:*}:"
    AWG_POSSIBLE_CLIENT_IPV6_PART="2"

    while :; do
        AWG_POSSIBLE_CLIENT_IPV6_PART_HEX=$(printf '%x' "$AWG_POSSIBLE_CLIENT_IPV6_PART")

        AWG_POSSIBLE_CLIENT_IPV6="${AWG_CLIENT_IPV6_PREFIX}${AWG_POSSIBLE_CLIENT_IPV6_PART_HEX}"

        if ! check_awg_client_ipv6_free "$AWG_POSSIBLE_CLIENT_IPV6"; then
            AWG_POSSIBLE_CLIENT_IPV6_PART=$((AWG_POSSIBLE_CLIENT_IPV6_PART + 1))
        else
            break
        fi
    done

    AWG_CLIENT_IPV6="$AWG_POSSIBLE_CLIENT_IPV6"
}


get_awg_client_name() {
    while :; do
        printf "Name: "

        handle_user_input

        TEMP="$USER_INPUT"

        ALL_CHARS_CORRECT="1"

        while [ -n "$TEMP" ]; do
            CHAR=${TEMP%${TEMP#?}}

            case "$CHAR" in
                [!a-zA-Z0-9_-])
                    ALL_CHARS_CORRECT="0"
                    break
                    ;;
            esac

            TEMP=${TEMP#?}
        done

        if [ "$ALL_CHARS_CORRECT" != "1" ]; then
            continue
        fi

        if [ ${#USER_INPUT} -lt 1 ]; then
            continue
        fi

        if [ ${#USER_INPUT} -gt 20 ]; then
            continue
        fi

        if check_awg_client_exists "$USER_INPUT"; then
            continue
        fi

        AWG_CLIENT_NAME="$USER_INPUT"

        break
    done
}

get_awg_client_ipv4() {
    generate_awg_client_ipv4

    QUESTION=$(printf 'IPv4 [%s]: %s' "$AWG_CLIENT_IPV4" "$AWG_CLIENT_IPV4_PREFIX")

    while :; do
        printf "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            TEMP="$USER_INPUT"

            ALL_CHARS_CORRECT="1"

            while [ -n "$TEMP" ]; do
                CHAR=${TEMP%${TEMP#?}}

                case "$CHAR" in
                    [!0-9])
                        ALL_CHARS_CORRECT="0"
                        break
                        ;;
                esac

                TEMP=${TEMP#?}
            done

            if [ "$ALL_CHARS_CORRECT" != "1" ]; then
                continue
            fi

            if ! validate_ipv4 "${AWG_CLIENT_IPV4_PREFIX}${USER_INPUT}"; then
                continue
            fi

            if [ ${USER_INPUT%%.*} = "0" ]; then
                continue
            fi

            if [ ${USER_INPUT##.*} = "255" ]; then
                continue
            fi

            if ! check_awg_client_ipv4_free "${AWG_CLIENT_IPV4_PREFIX}${USER_INPUT}"; then
                continue
            fi

            AWG_CLIENT_IPV4="${AWG_CLIENT_IPV4_PREFIX}${USER_INPUT}"
        else
            default_value_autocomplete "${AWG_CLIENT_IPV4##*.}" "$QUESTION"
        fi

        break
    done
}

get_awg_client_ipv6() {
    generate_awg_client_ipv6

    QUESTION=$(printf 'IPv6 [%s]: %s' "$AWG_CLIENT_IPV6" "$AWG_CLIENT_IPV6_PREFIX")

    while :; do
        printf "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            if [ "$USER_INPUT" = "0" ]; then
                continue
            fi

            if ! validate_ipv6 "${AWG_CLIENT_IPV6_PREFIX}${USER_INPUT}"; then
                continue
            fi

            if ! check_awg_client_ipv6_free "${AWG_CLIENT_IPV6_PREFIX}${USER_INPUT}"; then
                continue
            fi

            AWG_CLIENT_IPV6="${AWG_CLIENT_IPV6_PREFIX}${USER_INPUT}"
        else
            default_value_autocomplete "${AWG_CLIENT_IPV6##*:}" "$QUESTION"
        fi

        break
    done
}

get_awg_client_ip() {
    case "$AWG_INTERFACE_IP_VERSION_USE" in
        "ipv4")
            get_awg_client_ipv4
            ;;
        "ipv6")
            get_awg_client_ipv6
            ;;
        "both")
            get_awg_client_ipv4
            get_awg_client_ipv6
            ;;
    esac
}

get_awg_client_ipv4_first_dns() {
    AWG_CLIENT_IPV4_FIRST_DNS="1.1.1.1"

    QUESTION=$(printf 'First IPv4 DNS [%s]: ' "$AWG_CLIENT_IPV4_FIRST_DNS")

    while :; do
        printf "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            if ! validate_ipv4 "$USER_INPUT"; then
                continue
            fi

            if [ ${USER_INPUT%%.*} = "0" ]; then
                continue
            fi

            AWG_CLIENT_IPV4_FIRST_DNS="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_CLIENT_IPV4_FIRST_DNS" "$QUESTION"
        fi

        break
    done
}

get_awg_client_ipv4_second_dns() {
    AWG_CLIENT_IPV4_SECOND_DNS="1.0.0.1"

    QUESTION=$(printf 'Second IPv4 DNS [%s]: ' "$AWG_CLIENT_IPV4_SECOND_DNS")

    while :; do
        printf "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            if ! validate_ipv4 "$USER_INPUT"; then
                continue
            fi

            if [ ${USER_INPUT%%.*} = "0" ]; then
                continue
            fi

            AWG_CLIENT_IPV4_SECOND_DNS="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_CLIENT_IPV4_SECOND_DNS" "$QUESTION"
        fi

        break
    done
}

get_awg_client_ipv6_first_dns() {
    AWG_CLIENT_IPV6_FIRST_DNS="2606:4700:4700::1111"

    QUESTION=$(printf 'First IPv6 DNS [%s]: ' "$AWG_CLIENT_IPV6_FIRST_DNS")

    while :; do
        printf "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            if ! validate_ipv6 "$USER_INPUT"; then
                continue
            fi

            AWG_CLIENT_IPV6_FIRST_DNS="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_CLIENT_IPV6_FIRST_DNS" "$QUESTION"
        fi

        break
    done
}

get_awg_client_ipv6_second_dns() {
    AWG_CLIENT_IPV6_SECOND_DNS="2606:4700:4700::1001"

    QUESTION=$(printf 'Second IPv6 DNS [%s]: ' "$AWG_CLIENT_IPV6_SECOND_DNS")

    while :; do
        printf "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            if ! validate_ipv6 "$USER_INPUT"; then
                continue
            fi

            AWG_CLIENT_IPV6_SECOND_DNS="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_CLIENT_IPV6_SECOND_DNS" "$QUESTION"
        fi

        break
    done
}

get_awg_client_dns() {
    case "$AWG_INTERFACE_IP_VERSION_USE" in
        "ipv4")
            get_awg_client_ipv4_first_dns
            get_awg_client_ipv4_second_dns
            ;;
        "ipv6")
            get_awg_client_ipv6_first_dns
            get_awg_client_ipv6_second_dns
            ;;
        "both")
            get_awg_client_ipv4_first_dns
            get_awg_client_ipv4_second_dns
            get_awg_client_ipv6_first_dns
            get_awg_client_ipv6_second_dns
            ;;
    esac
}

get_awg_client_persistent_keepalive() {
    AWG_CLIENT_PERSISTENT_KEEPALIVE="25"
    
    QUESTION=$(printf 'Persistent Keepalive [%s]: ' "$AWG_CLIENT_PERSISTENT_KEEPALIVE")

    while :; do
        printf "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            TEMP="$USER_INPUT"

            ALL_CHARS_CORRECT="1"

            while [ -n "$TEMP" ]; do
                CHAR=${TEMP%${TEMP#?}}

                case "$CHAR" in
                    [!0-9])
                        ALL_CHARS_CORRECT="0"
                        break
                        ;;
                esac

                TEMP=${TEMP#?}
            done

            if [ "$ALL_CHARS_CORRECT" != "1" ]; then
                continue
            fi

            if [ "$AWG_CLIENT_PERSISTENT_KEEPALIVE" -gt 9999 ]; then
                continue
            fi

            AWG_CLIENT_PERSISTENT_KEEPALIVE="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_CLIENT_PERSISTENT_KEEPALIVE" "$QUESTION"
        fi

        break
    done
}

get_awg_client_allowed_ips() {
    case "$AWG_INTERFACE_IP_VERSION_USE" in
        "ipv4")
            AWG_CLIENT_ALLOWED_IPS="0.0.0.0/0"
            ;;
        "ipv6")
            AWG_CLIENT_ALLOWED_IPS="::/0"
            ;;
        "both")
            AWG_CLIENT_ALLOWED_IPS="0.0.0.0/0, ::/0"
            ;;
    esac

    QUESTION=$(printf 'Allowed IPs [%s]: ' "$AWG_CLIENT_ALLOWED_IPS")

    while :; do
        printf "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            TEMP="$USER_INPUT"

            ALL_CHARS_CORRECT="1"

            while [ -n "$TEMP" ]; do
                CHAR=${TEMP%${TEMP#?}}

                case "$CHAR" in
                    [!0-9a-fA-F/:,.[:space:]])
                        ALL_CHARS_CORRECT="0"
                        break
                        ;;
                esac

                TEMP=${TEMP#?}
            done

            if [ "$ALL_CHARS_CORRECT" != "1" ]; then
                continue
            fi

            case "${USER_INPUT##${USER_INPUT%?}}" in
                [/:,.[:space:]])
                    continue
                    ;;
            esac

            AWG_CLIENT_ALLOWED_IPS="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_CLIENT_ALLOWED_IPS" "$QUESTION"
        fi

        break
    done
}

create_awg_client_key_pair() {
    AWG_CLIENT_PRIVATE_KEY=$(awg genkey)
	AWG_CLIENT_PUBLIC_KEY=$(echo "${AWG_CLIENT_PRIVATE_KEY}" | awg pubkey)
	AWG_PRESHARED_KEY=$(awg genpsk)
}

save_awg_client_to_interface_config() {
    case "$AWG_INTERFACE_IP_VERSION_USE" in
        "ipv4")
            AWG_CLIENT_ADDRESS="${AWG_CLIENT_IPV4}/32"
            ;;
        "ipv6")
            AWG_CLIENT_ADDRESS="${AWG_CLIENT_IPV6}/128"
            ;;
        "both")
            AWG_CLIENT_ADDRESS="${AWG_CLIENT_IPV4}/32, ${AWG_CLIENT_IPV6}/128"
            ;;
    esac

    echo "# ${AWG_CLIENT_NAME}
[Peer]
PublicKey = ${AWG_CLIENT_PUBLIC_KEY}
PresharedKey = ${AWG_PRESHARED_KEY}
AllowedIPs = ${AWG_CLIENT_ADDRESS}
" >> "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"
}

save_awg_client_config() {
    mkdir -p "${AWG_CLIENT_CONFIGS_PATH}/${AWG_INTERFACE_NAME}"

    case "$AWG_INTERFACE_IP_VERSION_USE" in
        "ipv4")
            AWG_CLIENT_ADDRESS="${AWG_CLIENT_IPV4}/32"
            ;;
        "ipv6")
            AWG_CLIENT_ADDRESS="${AWG_CLIENT_IPV6}/128"
            ;;
        "both")
            AWG_CLIENT_ADDRESS="${AWG_CLIENT_IPV4}/32, ${AWG_CLIENT_IPV6}/128"
            ;;
    esac

    case "$AWG_INTERFACE_IP_VERSION_USE" in
        "ipv4")
            AWG_CLIENT_DNS="${AWG_CLIENT_IPV4_FIRST_DNS}, ${AWG_CLIENT_IPV4_SECOND_DNS}"
            ;;
        "ipv6")
            AWG_CLIENT_DNS="${AWG_CLIENT_IPV6_FIRST_DNS}, ${AWG_CLIENT_IPV6_SECOND_DNS}"
            ;;
        "both")
            AWG_CLIENT_DNS="${AWG_CLIENT_IPV4_FIRST_DNS}, ${AWG_CLIENT_IPV4_SECOND_DNS}, ${AWG_CLIENT_IPV6_FIRST_DNS}, ${AWG_CLIENT_IPV6_SECOND_DNS}"
            ;;
    esac

    echo "[Interface]
PrivateKey = ${AWG_CLIENT_PRIVATE_KEY}
Jc = ${AWG_JC}
Jmin = ${AWG_JMIN}
Jmax = ${AWG_JMAX}
S1 = ${AWG_S1}
S2 = ${AWG_S2}
H1 = ${AWG_H1}
H2 = ${AWG_H2}
H3 = ${AWG_H3}
H4 = ${AWG_H4}
Address = ${AWG_CLIENT_ADDRESS}
DNS = ${AWG_CLIENT_DNS}
MTU = ${AWG_INTERFACE_MTU}

[Peer]
PublicKey = ${AWG_INTERFACE_PUBLIC_KEY}
PresharedKey = ${AWG_PRESHARED_KEY}
AllowedIPs = ${AWG_CLIENT_ALLOWED_IPS}" > "${AWG_CLIENT_CONFIGS_PATH}/${AWG_INTERFACE_NAME}/${AWG_CLIENT_NAME}.conf"

    if validate_ipv6 "$SERVER_PUBLIC_IP_OR_DOMAIN"; then
        echo "Endpoint = \[${SERVER_PUBLIC_IP_OR_DOMAIN}\]:${AWG_INTERFACE_PORT}" >> "${AWG_CLIENT_CONFIGS_PATH}/${AWG_INTERFACE_NAME}/${AWG_CLIENT_NAME}.conf"
    else
        echo "Endpoint = ${SERVER_PUBLIC_IP_OR_DOMAIN}:${AWG_INTERFACE_PORT}" >> "${AWG_CLIENT_CONFIGS_PATH}/${AWG_INTERFACE_NAME}/${AWG_CLIENT_NAME}.conf"
    fi

    if [ "$AWG_CLIENT_PERSISTENT_KEEPALIVE" != "0" ]; then
        echo "PersistentKeepalive = ${AWG_CLIENT_PERSISTENT_KEEPALIVE}" >> "${AWG_CLIENT_CONFIGS_PATH}/${AWG_INTERFACE_NAME}/${AWG_CLIENT_NAME}.conf"
    fi
}

save_awg_client_data() {
    mkdir -p "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/clients"

    case "$AWG_INTERFACE_IP_VERSION_USE" in
        "ipv4")
            AWG_CLIENT_IP="AWG_CLIENT_IPV4=\"${AWG_CLIENT_IPV4}\""
            ;;
        "ipv6")
            AWG_CLIENT_IP="AWG_CLIENT_IPV6=\"${AWG_CLIENT_IPV6}\""
            ;;
        "both")
            AWG_CLIENT_IP="AWG_CLIENT_IPV4=\"${AWG_CLIENT_IPV4}\"\nAWG_CLIENT_IPV6=\"${AWG_CLIENT_IPV6}\""
            ;;
    esac

    case "$AWG_INTERFACE_IP_VERSION_USE" in
        "ipv4")
            AWG_CLIENT_DNS="${AWG_CLIENT_IPV4_FIRST_DNS}, ${AWG_CLIENT_IPV4_SECOND_DNS}"
            ;;
        "ipv6")
            AWG_CLIENT_DNS="${AWG_CLIENT_IPV6_FIRST_DNS}, ${AWG_CLIENT_IPV6_SECOND_DNS}"
            ;;
        "both")
            AWG_CLIENT_DNS="${AWG_CLIENT_IPV4_FIRST_DNS}, ${AWG_CLIENT_IPV4_SECOND_DNS}, ${AWG_CLIENT_IPV6_FIRST_DNS}, ${AWG_CLIENT_IPV6_SECOND_DNS}"
            ;;
    esac

    printf "${AWG_CLIENT_IP}
AWG_CLIENT_DNS=\"${AWG_CLIENT_DNS}\"
AWG_PRESHARED_KEY=\"${AWG_PRESHARED_KEY}\"
AWG_CLIENT_PUBLIC_KEY=\"${AWG_CLIENT_PUBLIC_KEY}\"
AWG_CLIENT_PRIVATE_KEY=\"${AWG_CLIENT_PRIVATE_KEY}\"
AWG_CLIENT_PERSISTENT_KEEPALIVE=\"${AWG_CLIENT_PERSISTENT_KEEPALIVE}\"
AWG_CLIENT_ALLOWED_IPS=\"${AWG_CLIENT_ALLOWED_IPS}\"\n" > "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/clients/${AWG_CLIENT_NAME}.data"
}

bring_up_awg_client() {
    TEMP_FILE=$(mktemp)

    awg-quick strip "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf" > "$TEMP_FILE" 2>/dev/null

    awg syncconf "$AWG_INTERFACE_NAME" "$TEMP_FILE"

    rm "$TEMP_FILE"
}

ask_to_show_qr() {
    if ! command -v qrencode > /dev/null 2>&1; then
        return
    fi

    echo ""

    QUESTION=$(printf 'Do you want to show client config as QR code (y/n) [y]: ')

    printf '%s' "$QUESTION"

    handle_user_input

    if [ -n "$USER_INPUT" ]; then
        case "$USER_INPUT" in
            "y" | "yes" | "Y" | "YES") ;;
            *) return ;;
        esac
    else
        default_value_autocomplete "y" "$QUESTION"
    fi

    echo ""
    printf "${BOLD_FS}Here is your client config file as a QR code: ${DEFAULT_FS}\n"
    qrencode -t ansiutf8 -l L < "${AWG_CLIENT_CONFIGS_PATH}/${AWG_INTERFACE_NAME}/${AWG_CLIENT_NAME}.conf"
    echo ""
}


create_awg_client() {
    print_dashes "$((18 + ${#AWG_INTERFACE_NAME}))"

    printf "${BOLD_FS} Create client [${AWG_INTERFACE_NAME}] ${DEFAULT_FS}\n"

    print_dashes "$((18 + ${#AWG_INTERFACE_NAME}))"
    echo ""

    check_awg_interface_has_free_clients

    get_awg_client_name

    get_awg_client_ip

    get_awg_client_dns

    get_awg_client_persistent_keepalive

    get_awg_client_allowed_ips

    create_awg_client_key_pair

    save_awg_client_to_interface_config

    save_awg_client_config

    save_awg_client_data

    bring_up_awg_client

    ask_to_show_qr

    echo ""
    printf "${GREEN}Client ${BOLD_FS}\"${AWG_CLIENT_NAME}\"${DEFAULT_FS} is succesfuly created.${DEFAULT_COLOR}\n"
    printf "Your client config file saved in \"${AWG_CLIENT_CONFIGS_PATH}/${AWG_INTERFACE_NAME}/${AWG_CLIENT_NAME}.conf\".\n"
}
