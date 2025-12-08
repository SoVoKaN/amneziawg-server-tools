get_awg_client_name_to_display_qr() {
    while :; do
        echo "${BOLD_FS}Enter client name to display QR code.${DEFAULT_FS}"
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

show_awg_client_qr() {
    if ! command -v qrencode > /dev/null 2>&1; then
        echo "To use this option, \"qrencode\" must be installed. Please install it and try again."
    fi

    echo "-----------------------"
    echo "${BOLD_FS} Show client QR [${AWG_INTERFACE_NAME}] ${DEFAULT_FS}"
    echo "-----------------------"
    echo ""

    get_awg_client_name_to_display_qr

    load_client_data

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
Address = ${AWG_CLIENT_IPV4}/32, ${AWG_CLIENT_IPV6}/128
DNS = ${AWG_CLIENT_FIRST_DNS}, ${AWG_CLIENT_SECOND_DNS}
MTU = ${AWG_INTERFACE_MTU}

[Peer]
PublicKey = ${AWG_INTERFACE_PUBLIC_KEY}
PresharedKey = ${AWG_PRESHARED_KEY}
AllowedIPs = ${AWG_CLIENT_ALLOWED_IPS}
Endpoint = "${SERVER_PUBLIC_IP_OR_DOMAIN}:${AWG_INTERFACE_PORT}"" | qrencode -t ansiutf8 -l L

    echo ""
    echo "Here is your ${BOLD_FS}\"${AWG_CLIENT_NAME}\"${DEFAULT_FS} client as a QR code."
}
