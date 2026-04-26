check_awg_interface_port_free() {
    if grep "^${1}$" "${AWG_SERVER_TOOLS_PATH}/interfaces/.ports_reserved" > /dev/null 2>&1; then
        return 1
    fi

    AWG_POSSIBLE_INTERFACE_PORT_HEX=$(printf '%04X' "$1")

    if grep ":${AWG_POSSIBLE_INTERFACE_PORT_HEX}" /proc/net/udp > /dev/null 2>&1; then
        return 1
    fi

    if grep ":${AWG_POSSIBLE_INTERFACE_PORT_HEX}" /proc/net/udp6 > /dev/null 2>&1; then
        return 1
    fi

    return 0
}

check_awg_interface_ipv4_free() {
    if grep "^${1}$" "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv4_reserved" > /dev/null 2>&1; then
        return 1
    fi

    AWG_CHECK_INTERFACE_IPV4="$1"

    AWG_CHECK_INTERFACE_IPV4_FIRST_PART=${AWG_CHECK_INTERFACE_IPV4%%.*}

    AWG_CHECK_INTERFACE_IPV4=${AWG_CHECK_INTERFACE_IPV4#*.}

    AWG_CHECK_INTERFACE_IPV4_SECOND_PART=${AWG_CHECK_INTERFACE_IPV4%%.*}

    AWG_CHECK_INTERFACE_IPV4=${AWG_CHECK_INTERFACE_IPV4#*.}

    AWG_CHECK_INTERFACE_IPV4_THIRD_PART=${AWG_CHECK_INTERFACE_IPV4%%.*}

    AWG_CHECK_INTERFACE_IPV4_FOURTH_PART=${AWG_CHECK_INTERFACE_IPV4#*.}

    AWG_POSSIBLE_INTERFACE_IPV4_HEX=$(printf '%02X%02X%02X%02X' "$AWG_CHECK_INTERFACE_IPV4_FOURTH_PART" "$AWG_CHECK_INTERFACE_IPV4_THIRD_PART" "$AWG_CHECK_INTERFACE_IPV4_SECOND_PART" "$AWG_CHECK_INTERFACE_IPV4_FIRST_PART")

    if grep "${AWG_POSSIBLE_INTERFACE_IPV4_HEX}:" /proc/net/tcp > /dev/null 2>&1; then
        return 1
    fi

    if grep "${AWG_POSSIBLE_INTERFACE_IPV4_HEX}:" /proc/net/udp > /dev/null 2>&1; then
        return 1
    fi

    return 0
}

check_awg_interface_ipv6_free() {
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

    if grep "^${AWG_CHECK_INTERFACE_IPV6_ALL_PARTS}$" "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv6_reserved" > /dev/null 2>&1; then
        return 1
    fi

    AWG_POSSIBLE_INTERFACE_IPV6_HEX=""

    NUM="4"
    while [ "$NUM" -gt 0 ]; do
        AWG_CHECK_INTERFACE_IPV6_LEFT_PART="${AWG_CHECK_INTERFACE_IPV6_ALL_PARTS%${AWG_CHECK_INTERFACE_IPV6_ALL_PARTS#????}}"
        AWG_CHECK_INTERFACE_IPV6_ALL_PARTS="${AWG_CHECK_INTERFACE_IPV6_ALL_PARTS#????}"

        AWG_CHECK_INTERFACE_IPV6_ALL_PARTS="${AWG_CHECK_INTERFACE_IPV6_ALL_PARTS#?}"

        AWG_CHECK_INTERFACE_IPV6_RIGHT_PART="${AWG_CHECK_INTERFACE_IPV6_ALL_PARTS%${AWG_CHECK_INTERFACE_IPV6_ALL_PARTS#????}}"
        AWG_CHECK_INTERFACE_IPV6_ALL_PARTS="${AWG_CHECK_INTERFACE_IPV6_ALL_PARTS#????}"

        AWG_CHECK_INTERFACE_IPV6_ALL_PARTS="${AWG_CHECK_INTERFACE_IPV6_ALL_PARTS#?}"


        AWG_CHECK_INTERFACE_IPV6_CURRENT_PART="${AWG_CHECK_INTERFACE_IPV6_LEFT_PART}${AWG_CHECK_INTERFACE_IPV6_RIGHT_PART}"


        AWG_CHECK_INTERFACE_IPV6_CURRENT_PART_REVERSED=""

        while [ -n "$AWG_CHECK_INTERFACE_IPV6_CURRENT_PART" ]; do
            AWG_CHECK_INTERFACE_IPV6_CURRENT_PART_PAIR="${AWG_CHECK_INTERFACE_IPV6_CURRENT_PART%${AWG_CHECK_INTERFACE_IPV6_CURRENT_PART#??}}"

            AWG_CHECK_INTERFACE_IPV6_CURRENT_PART_REVERSED="${AWG_CHECK_INTERFACE_IPV6_CURRENT_PART_PAIR}${AWG_CHECK_INTERFACE_IPV6_CURRENT_PART_REVERSED}"

            AWG_CHECK_INTERFACE_IPV6_CURRENT_PART=${AWG_CHECK_INTERFACE_IPV6_CURRENT_PART#??}
        done

        AWG_CHECK_INTERFACE_IPV6_CURRENT_PART_REVERSED=$(printf '%08X' "0x${AWG_CHECK_INTERFACE_IPV6_CURRENT_PART_REVERSED}")

        AWG_POSSIBLE_INTERFACE_IPV6_HEX="${AWG_POSSIBLE_INTERFACE_IPV6_HEX}${AWG_CHECK_INTERFACE_IPV6_CURRENT_PART_REVERSED}"

        NUM=$((NUM - 1))
    done

    if grep "${AWG_POSSIBLE_INTERFACE_IPV6_HEX}:" /proc/net/tcp6 > /dev/null 2>&1; then
        return 1
    fi

    if grep "${AWG_POSSIBLE_INTERFACE_IPV6_HEX}:" /proc/net/udp6 > /dev/null 2>&1; then
        return 1
    fi

    return 0
}

generate_awg_interface_name() {
    NUM="0"

    while :; do
        AWG_POSSIBLE_INTERFACE_NAME="awg${NUM}"

        if ! check_interface_name_free "$AWG_POSSIBLE_INTERFACE_NAME" || check_awg_interface_exists "$USER_INPUT"; then
            NUM=$((NUM + 1))
        else
            break
        fi
    done

    AWG_INTERFACE_NAME="$AWG_POSSIBLE_INTERFACE_NAME"
}

generate_awg_interface_port() {
    NUM="0"

    while :; do
        AWG_POSSIBLE_INTERFACE_PORT=$(awk -v num="$NUM" '
        BEGIN {
            srand(systime() + num)
            print int(rand() * (65535 - 50000 + 1)) + 50000
        }')

        if ! check_awg_interface_port_free "$AWG_POSSIBLE_INTERFACE_PORT"; then
            NUM=$((NUM + 1))
        else
            break
        fi
    done

    AWG_INTERFACE_PORT="$AWG_POSSIBLE_INTERFACE_PORT"
}

generate_awg_interface_ipv4() {
    AWG_POSSIBLE_INTERFACE_IPV4_SECOND_PART="10"
    AWG_POSSIBLE_INTERFACE_IPV4_THIRD_PART="1"

    while :; do
        AWG_INTERFACE_POSSIBLE_IPV4="10.${AWG_POSSIBLE_INTERFACE_IPV4_SECOND_PART}.${AWG_POSSIBLE_INTERFACE_IPV4_THIRD_PART}.1"

        if ! check_awg_interface_ipv4_free "$AWG_INTERFACE_POSSIBLE_IPV4"; then
            if [ ${AWG_POSSIBLE_INTERFACE_IPV4_THIRD_PART} -eq 255 ]; then
                AWG_POSSIBLE_INTERFACE_IPV4_SECOND_PART=$((AWG_POSSIBLE_INTERFACE_IPV4_SECOND_PART + 1))
                AWG_POSSIBLE_INTERFACE_IPV4_THIRD_PART="1"

                continue
            fi

            AWG_POSSIBLE_INTERFACE_IPV4_THIRD_PART=$((AWG_POSSIBLE_INTERFACE_IPV4_THIRD_PART + 1))
        else
            break
        fi
    done

    AWG_INTERFACE_IPV4="$AWG_INTERFACE_POSSIBLE_IPV4"
}

generate_awg_interface_ipv6() {
    AWG_POSSIBLE_INTERFACE_IPV6_PART="1"

    while :; do
        AWG_POSSIBLE_INTERFACE_IPV6_PART_HEX=$(printf '%x' "$AWG_POSSIBLE_INTERFACE_IPV6_PART")

        AWG_POSSIBLE_INTERFACE_IPV6="fdcd:bcfa:f8dc:${AWG_POSSIBLE_INTERFACE_IPV6_PART_HEX}::1"

        if ! check_awg_interface_ipv6_free "$AWG_POSSIBLE_INTERFACE_IPV6"; then
            AWG_POSSIBLE_INTERFACE_IPV6_PART=$((AWG_POSSIBLE_INTERFACE_IPV6_PART + 1))
        else
            break
        fi
    done

    AWG_INTERFACE_IPV6="$AWG_POSSIBLE_INTERFACE_IPV6"
}

get_awg_interface_name() {
    generate_awg_interface_name

    QUESTION=$(printf 'Name [%s]: ' "$AWG_INTERFACE_NAME")

    while :; do
        printf "$QUESTION"

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
                    [!a-z0-9_])
                        ALL_CHARS_CORRECT="0"
                        break
                        ;;
                esac

                TEMP=${TEMP#?}
            done

            if [ "$ALL_CHARS_CORRECT" != "1" ]; then
                continue
            fi

            if ! check_interface_name_free "$USER_INPUT" || check_awg_interface_exists "$USER_INPUT"; then
                continue
            fi

            AWG_INTERFACE_NAME="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_INTERFACE_NAME" "$QUESTION"
        fi

        break
    done
}

ask_which_ip_version_use_awg_interface() {
    AWG_INTERFACE_IP_VERSION_USE="both"

    QUESTION=$(printf 'Which IP version use for interface (ipv4/ipv6/both) [%s]: ' "$AWG_INTERFACE_IP_VERSION_USE")

    while :; do
        printf "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            case "$USER_INPUT" in
                "ipv4" | "IPv4" | "IPV4")
                    AWG_INTERFACE_IP_VERSION_USE="ipv4"
                    ;;
                "ipv6" | "IPv6" | "IPV6")
                    AWG_INTERFACE_IP_VERSION_USE="ipv6"
                    ;;
                "both" | "BOTH")
                    AWG_INTERFACE_IP_VERSION_USE="both"
                    ;;
                *) continue ;;
            esac
        else
            default_value_autocomplete "$AWG_INTERFACE_IP_VERSION_USE" "$QUESTION"
        fi

        break
    done
}

get_awg_interface_ipv4() {
    generate_awg_interface_ipv4

    QUESTION=$(printf 'IPv4 [%s]: ' "$AWG_INTERFACE_IPV4")

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

            if [ ${USER_INPUT##.*} = "255" ]; then
                continue
            fi

            if ! check_awg_interface_ipv4_free "$USER_INPUT"; then
                continue
            fi

            AWG_INTERFACE_IPV4="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_INTERFACE_IPV4" "$QUESTION"
        fi

        break
    done
}

get_awg_interface_ipv6() {
    generate_awg_interface_ipv6

    QUESTION=$(printf 'IPv6 [%s]: ' "$AWG_INTERFACE_IPV6")

    while :; do
        printf "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            if ! validate_ipv6 "$USER_INPUT"; then
                continue
            fi

            if ! check_awg_interface_ipv6_free "$USER_INPUT"; then
                continue
            fi

            AWG_INTERFACE_IPV6="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_INTERFACE_IPV6" "$QUESTION"
        fi

        break
    done
}

get_awg_interface_ip() {
    case "$AWG_IP_VERSION_SUPPORT_MODE" in
        "ipv4")
            AWG_INTERFACE_IP_VERSION_USE="ipv4"
            ;;
        "ipv6")
            AWG_INTERFACE_IP_VERSION_USE="ipv6"
            ;;
        "both")
            ask_which_ip_version_use_awg_interface
            ;;
    esac

    case "$AWG_INTERFACE_IP_VERSION_USE" in
        "ipv4")
            get_awg_interface_ipv4
            ;;
        "ipv6")
            get_awg_interface_ipv6
            ;;
        "both")
            get_awg_interface_ipv4
            get_awg_interface_ipv6
            ;;
    esac
}

get_awg_interface_mtu() {
    SERVER_PUBLIC_NETWORK_INTERFACE_MTU=$(cat /sys/class/net/${SERVER_PUBLIC_NETWORK_INTERFACE}/mtu)

    case "$AWG_INTERFACE_IP_VERSION_USE" in
        "ipv4")
            AWG_INTERFACE_MTU=$((SERVER_PUBLIC_NETWORK_INTERFACE_MTU - 80))
            ;;
        "ipv6" | "both")
            AWG_INTERFACE_MTU=$((SERVER_PUBLIC_NETWORK_INTERFACE_MTU - 100))
            ;;
    esac

    QUESTION=$(printf 'MTU [%s]: ' "$AWG_INTERFACE_MTU")

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

            case "$AWG_INTERFACE_IP_VERSION_USE" in
                "ipv4")
                    if [ "$USER_INPUT" -lt 576 ]; then
                        continue
                    fi
                    ;;
                "ipv6" | "both")
                    if [ "$USER_INPUT" -lt 1280 ]; then
                        continue
                    fi
                    ;;
            esac

            if [ "$USER_INPUT" -gt 1500 ]; then
                continue
            fi

            AWG_INTERFACE_MTU="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_INTERFACE_MTU" "$QUESTION"
        fi

        break
    done
}

get_awg_interface_port() {
    generate_awg_interface_port

    QUESTION=$(printf 'Port [%s]: ' "$AWG_INTERFACE_PORT")

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

            if [ "$USER_INPUT" -lt 1  ] || [ "$USER_INPUT" -gt 65535 ]; then
                continue
            fi

            if ! check_awg_interface_port_free "$USER_INPUT"; then
                continue
            fi

            AWG_INTERFACE_PORT="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_INTERFACE_PORT" "$QUESTION"
        fi

        break
    done
}

get_awg_interface_s1() {
    AWG_INTERFACE_S1=$(awk -v max=$((AWG_INTERFACE_MTU - 148)) '
    BEGIN {
        srand(systime())
        print int(rand() * (max - 16 + 1)) + 16
    }')

    QUESTION=$(printf 'S1 [%s]: ' "$AWG_INTERFACE_S1")

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

            if [ "$USER_INPUT" -lt 0 ] || [ "$USER_INPUT" -gt $((AWG_INTERFACE_MTU - 148)) ]; then
                continue
            fi

            AWG_INTERFACE_S1="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_INTERFACE_S1" "$QUESTION"
        fi

        break
    done
}

get_awg_interface_s2() {
    AWG_INTERFACE_S2=$(awk -v max=$((AWG_INTERFACE_MTU - 92)) '
    BEGIN {
        srand(systime() + 1)
        print int(rand() * (max - 16 + 1)) + 16
    }')

    QUESTION=$(printf 'S2 [%s]: ' "$AWG_INTERFACE_S2")

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

            if [ "$USER_INPUT" -lt 0 ] || [ "$USER_INPUT" -gt $((AWG_INTERFACE_MTU - 92)) ]; then
                continue
            fi

            AWG_INTERFACE_S2="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_INTERFACE_S2" "$QUESTION"
        fi

        break
    done
}

get_awg_interface_s3() {
    AWG_INTERFACE_S3=$(awk -v max=$((AWG_INTERFACE_MTU - 64)) '
    BEGIN {
        srand(systime() + 2)
        print int(rand() * (max - 16 + 1)) + 16
    }')

    QUESTION=$(printf 'S3 [%s]: ' "$AWG_INTERFACE_S3")

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

            if [ "$USER_INPUT" -lt 0 ] || [ "$USER_INPUT" -gt $((AWG_INTERFACE_MTU - 64)) ]; then
                continue
            fi

            AWG_INTERFACE_S3="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_INTERFACE_S3" "$QUESTION"
        fi

        break
    done
}

get_awg_interface_s4() {
    case "$AWG_INTERFACE_IP_VERSION_USE" in
        "ipv4")
            AWG_INTERFACE_S4_MAX=$(($(cat /sys/class/net/${SERVER_PUBLIC_NETWORK_INTERFACE}/mtu) - AWG_INTERFACE_MTU - 64))
            ;;
        "ipv6" | "both")
            AWG_INTERFACE_S4_MAX=$(($(cat /sys/class/net/${SERVER_PUBLIC_NETWORK_INTERFACE}/mtu) - AWG_INTERFACE_MTU - 84))
            ;;
    esac

    AWG_INTERFACE_S4=$(awk -v max="$AWG_INTERFACE_S4_MAX" '
    BEGIN {
        srand(systime() + 3)
        print int(rand() * (max - 4 + 1)) + 4
    }')

    QUESTION=$(printf 'S4 [%s]: ' "$AWG_INTERFACE_S4")

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

            if [ "$USER_INPUT" -lt 0 ] || [ "$USER_INPUT" -gt "$AWG_INTERFACE_S4_MAX" ]; then
                continue
            fi

            AWG_INTERFACE_S4="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_INTERFACE_S4" "$QUESTION"
        fi

        break
    done
}

get_awg_interface_h1() {
    AWG_INTERFACE_H1="5-1073741827"

    QUESTION=$(printf 'H1 [%s]: ' "$AWG_INTERFACE_H1")

    while :; do
        printf "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            TEMP="$USER_INPUT"

            ALL_CHARS_CORRECT="1"

            while [ -n "$TEMP" ]; do
                CHAR=${TEMP%${TEMP#?}}

                case "$CHAR" in
                    [!-0-9])
                        ALL_CHARS_CORRECT="0"
                        break
                        ;;
                esac

                TEMP=${TEMP#?}
            done

            if [ "$ALL_CHARS_CORRECT" != "1" ]; then
                continue
            fi

            case "$USER_INPUT" in
                *-*-*) continue ;;
            esac

            if [ "${USER_INPUT%-*}" -lt 0 ] || [ "${USER_INPUT%-*}" -gt 4294967295 ]; then
                continue
            fi

            if [ "${USER_INPUT#*-}" -lt 0 ] || [ "${USER_INPUT#*-}" -gt 4294967295 ]; then
                continue
            fi

            if [ "${USER_INPUT%-*}" -gt "${USER_INPUT#*-}" ]; then
                continue
            fi

            AWG_INTERFACE_H1="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_INTERFACE_H1" "$QUESTION"
        fi

        break
    done
}

get_awg_interface_h2() {
    AWG_INTERFACE_H2="1073741828-2147483650"

    QUESTION=$(printf 'H2 [%s]: ' "$AWG_INTERFACE_H2")

    while :; do
        printf "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            TEMP="$USER_INPUT"

            ALL_CHARS_CORRECT="1"

            while [ -n "$TEMP" ]; do
                CHAR=${TEMP%${TEMP#?}}

                case "$CHAR" in
                    [!-0-9])
                        ALL_CHARS_CORRECT="0"
                        break
                        ;;
                esac

                TEMP=${TEMP#?}
            done

            if [ "$ALL_CHARS_CORRECT" != "1" ]; then
                continue
            fi

            case "$USER_INPUT" in
                *-*-*) continue ;;
            esac

            if [ "${USER_INPUT%-*}" -lt 0 ] || [ "${USER_INPUT%-*}" -gt 4294967295 ]; then
                continue
            fi

            if [ "${USER_INPUT#*-}" -lt 0 ] || [ "${USER_INPUT#*-}" -gt 4294967295 ]; then
                continue
            fi

            if [ "${USER_INPUT%-*}" -gt "${USER_INPUT#*-}" ]; then
                continue
            fi

            AWG_INTERFACE_H2="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_INTERFACE_H2" "$QUESTION"
        fi

        break
    done
}

get_awg_interface_h3() {
    AWG_INTERFACE_H3="2147483651-3221225472"

    QUESTION=$(printf 'H3 [%s]: ' "$AWG_INTERFACE_H3")

    while :; do
        printf "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            TEMP="$USER_INPUT"

            ALL_CHARS_CORRECT="1"

            while [ -n "$TEMP" ]; do
                CHAR=${TEMP%${TEMP#?}}

                case "$CHAR" in
                    [!-0-9])
                        ALL_CHARS_CORRECT="0"
                        break
                        ;;
                esac

                TEMP=${TEMP#?}
            done

            if [ "$ALL_CHARS_CORRECT" != "1" ]; then
                continue
            fi

            case "$USER_INPUT" in
                *-*-*) continue ;;
            esac

            if [ "${USER_INPUT%-*}" -lt 0 ] || [ "${USER_INPUT%-*}" -gt 4294967295 ]; then
                continue
            fi

            if [ "${USER_INPUT#*-}" -lt 0 ] || [ "${USER_INPUT#*-}" -gt 4294967295 ]; then
                continue
            fi

            if [ "${USER_INPUT%-*}" -gt "${USER_INPUT#*-}" ]; then
                continue
            fi

            AWG_INTERFACE_H3="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_INTERFACE_H3" "$QUESTION"
        fi

        break
    done
}

get_awg_interface_h4() {
    AWG_INTERFACE_H4="3221225473-4294967295"

    QUESTION=$(printf 'H4 [%s]: ' "$AWG_INTERFACE_H4")

    while :; do
        printf "$QUESTION"

        handle_user_input

        if [ -n "$USER_INPUT" ]; then
            TEMP="$USER_INPUT"

            ALL_CHARS_CORRECT="1"

            while [ -n "$TEMP" ]; do
                CHAR=${TEMP%${TEMP#?}}

                case "$CHAR" in
                    [!-0-9])
                        ALL_CHARS_CORRECT="0"
                        break
                        ;;
                esac

                TEMP=${TEMP#?}
            done

            if [ "$ALL_CHARS_CORRECT" != "1" ]; then
                continue
            fi

            case "$USER_INPUT" in
                *-*-*) continue ;;
            esac

            if [ "${USER_INPUT%-*}" -lt 0 ] || [ "${USER_INPUT%-*}" -gt 4294967295 ]; then
                continue
            fi

            if [ "${USER_INPUT#*-}" -lt 0 ] || [ "${USER_INPUT#*-}" -gt 4294967295 ]; then
                continue
            fi

            if [ "${USER_INPUT%-*}" -gt "${USER_INPUT#*-}" ]; then
                continue
            fi

            AWG_INTERFACE_H4="$USER_INPUT"
        else
            default_value_autocomplete "$AWG_INTERFACE_H4" "$QUESTION"
        fi

        break
    done
}

create_awg_interface_key_pair() {
    AWG_INTERFACE_PRIVATE_KEY=$(awg genkey)
    AWG_INTERFACE_PUBLIC_KEY=$(echo "${AWG_INTERFACE_PRIVATE_KEY}" | awg pubkey)
}

add_awg_interface_firewalld_rules() {
    echo "PostUp = firewall-cmd --zone=public --add-interface=${AWG_INTERFACE_NAME}
PostUp = firewall-cmd --zone=public --add-port=${AWG_INTERFACE_PORT}/udp" >> "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"

    case "$AWG_INTERFACE_IP_VERSION_USE" in
        "ipv4")
            echo "PostUp = firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i ${SERVER_PUBLIC_NETWORK_INTERFACE} -o ${AWG_INTERFACE_NAME} -j ACCEPT
PostUp = firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i ${AWG_INTERFACE_NAME} -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j ACCEPT
PostUp = firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j MASQUERADE" >> "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"

            echo "PostDown = firewall-cmd --direct --remove-rule ipv4 nat POSTROUTING 0 -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j MASQUERADE
PostDown = firewall-cmd --direct --remove-rule ipv4 filter FORWARD 0 -i ${AWG_INTERFACE_NAME} -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j ACCEPT
PostDown = firewall-cmd --direct --remove-rule ipv4 filter FORWARD 0 -i ${SERVER_PUBLIC_NETWORK_INTERFACE} -o ${AWG_INTERFACE_NAME} -j ACCEPT" >> "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"
            ;;
        "ipv6")
            echo "PostUp = firewall-cmd --direct --add-rule ipv6 filter FORWARD 0 -i ${SERVER_PUBLIC_NETWORK_INTERFACE} -o ${AWG_INTERFACE_NAME} -j ACCEPT
PostUp = firewall-cmd --direct --add-rule ipv6 filter FORWARD 0 -i ${AWG_INTERFACE_NAME} -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j ACCEPT
PostUp = firewall-cmd --direct --add-rule ipv6 nat POSTROUTING 0 -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j MASQUERADE" >> "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"

            echo "PostDown = firewall-cmd --direct --remove-rule ipv6 nat POSTROUTING 0 -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j MASQUERADE
PostDown = firewall-cmd --direct --remove-rule ipv6 filter FORWARD 0 -i ${AWG_INTERFACE_NAME} -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j ACCEPT
PostDown = firewall-cmd --direct --remove-rule ipv6 filter FORWARD 0 -i ${SERVER_PUBLIC_NETWORK_INTERFACE} -o ${AWG_INTERFACE_NAME} -j ACCEPT" >> "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"
            ;;
        "both")
            echo "PostUp = firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i ${SERVER_PUBLIC_NETWORK_INTERFACE} -o ${AWG_INTERFACE_NAME} -j ACCEPT
PostUp = firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i ${AWG_INTERFACE_NAME} -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j ACCEPT
PostUp = firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j MASQUERADE" >> "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"

            echo "PostUp = firewall-cmd --direct --add-rule ipv6 filter FORWARD 0 -i ${SERVER_PUBLIC_NETWORK_INTERFACE} -o ${AWG_INTERFACE_NAME} -j ACCEPT
PostUp = firewall-cmd --direct --add-rule ipv6 filter FORWARD 0 -i ${AWG_INTERFACE_NAME} -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j ACCEPT
PostUp = firewall-cmd --direct --add-rule ipv6 nat POSTROUTING 0 -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j MASQUERADE" >> "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"

            echo "PostDown = firewall-cmd --direct --remove-rule ipv6 nat POSTROUTING 0 -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j MASQUERADE
PostDown = firewall-cmd --direct --remove-rule ipv6 filter FORWARD 0 -i ${AWG_INTERFACE_NAME} -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j ACCEPT
PostDown = firewall-cmd --direct --remove-rule ipv6 filter FORWARD 0 -i ${SERVER_PUBLIC_NETWORK_INTERFACE} -o ${AWG_INTERFACE_NAME} -j ACCEPT" >> "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"

            echo "PostDown = firewall-cmd --direct --remove-rule ipv4 nat POSTROUTING 0 -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j MASQUERADE
PostDown = firewall-cmd --direct --remove-rule ipv4 filter FORWARD 0 -i ${AWG_INTERFACE_NAME} -o ${SERVER_PUBLIC_NETWORK_INTERFACE} -j ACCEPT
PostDown = firewall-cmd --direct --remove-rule ipv4 filter FORWARD 0 -i ${SERVER_PUBLIC_NETWORK_INTERFACE} -o ${AWG_INTERFACE_NAME} -j ACCEPT" >> "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"
            ;;
    esac

    echo "PostDown = firewall-cmd --zone=public --remove-port=${AWG_INTERFACE_PORT}/udp
PostDown = firewall-cmd --zone=public --remove-interface=${AWG_INTERFACE_NAME}

" >> "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"
}

add_awg_interface_nftables_rules() {
    echo "PostUp = nft list table inet filter 2>/dev/null || nft add table inet filter
PostUp = nft list chain inet filter input 2>/dev/null || nft add chain inet filter input { type filter hook input priority filter \; }
PostUp = nft list chain inet filter forward 2>/dev/null || nft add chain inet filter forward { type filter hook forward priority filter \; }
PostUp = nft list chain inet filter postrouting 2>/dev/null || nft add chain inet filter postrouting { type nat hook postrouting priority srcnat \; }
PostUp = nft list map inet filter amneziawg_ports 2>/dev/null || nft add map inet filter amneziawg_ports { type ifname . inet_service : verdict \; }
PostUp = nft list set inet filter amneziawg_interfaces 2>/dev/null || nft add set inet filter amneziawg_interfaces { type ifname \; }
PostUp = nft list chain inet filter input | grep \"iifname . udp dport vmap @amneziawg_ports\" 2>/dev/null || nft add rule inet filter input iifname . udp dport vmap @amneziawg_ports
PostUp = nft list chain inet filter forward | grep \"ct state established,related accept\" 2>/dev/null || nft add rule inet filter forward ct state established,related accept
PostUp = nft list chain inet filter forward | grep \"iifname @amneziawg_interfaces oifname \\\"${SERVER_PUBLIC_NETWORK_INTERFACE}\\\" accept\" 2>/dev/null || nft add rule inet filter forward iifname @amneziawg_interfaces oifname \"${SERVER_PUBLIC_NETWORK_INTERFACE}\" accept
PostUp = nft list chain inet filter postrouting | grep \"iifname @amneziawg_interfaces oifname \\\"${SERVER_PUBLIC_NETWORK_INTERFACE}\\\" masquerade\" || nft add rule inet filter postrouting iifname @amneziawg_interfaces oifname \"${SERVER_PUBLIC_NETWORK_INTERFACE}\" masquerade
PostUp = nft add element inet filter amneziawg_ports { \"${SERVER_PUBLIC_NETWORK_INTERFACE}\" . ${AWG_INTERFACE_PORT} : accept }
PostUp = nft add element inet filter amneziawg_interfaces { \"${AWG_INTERFACE_NAME}\" }
PostDown = nft delete element inet filter amneziawg_interfaces { \"${AWG_INTERFACE_NAME}\" }
PostDown = nft delete element inet filter amneziawg_ports { \"${SERVER_PUBLIC_NETWORK_INTERFACE}\" . ${AWG_INTERFACE_PORT} : accept }
PostDown = nft list set inet filter amneziawg_interfaces | awk 'NR == 4 { exit !(/\"/) }' || nft -a list chain inet filter postrouting | grep \"iifname @amneziawg_interfaces oifname \\\"${SERVER_PUBLIC_NETWORK_INTERFACE}\\\" masquerade\" | awk '{ print \$NF }' | xargs nft delete rule inet filter postrouting handle
PostDown = nft list set inet filter amneziawg_interfaces | awk 'NR == 4 { exit !(/\"/) }' || nft -a list chain inet filter forward | grep \"iifname @amneziawg_interfaces oifname \\\"${SERVER_PUBLIC_NETWORK_INTERFACE}\\\" accept\" | awk '{ print \$NF }' | xargs nft delete rule inet filter forward handle
PostDown = nft list map inet filter amneziawg_ports | awk 'NR == 4 { exit !(/\"/) }' || nft -a list chain inet filter input | grep \"iifname . udp dport vmap @amneziawg_ports\" | awk '{ print \$NF }' | xargs nft delete rule inet filter input handle
PostDown = nft list set inet filter amneziawg_interfaces | awk 'NR == 4 { exit !(/\"/) }' || nft delete set inet filter amneziawg_interfaces
PostDown = nft list map inet filter amneziawg_ports | awk 'NR == 4 { exit !(/\"/) }' || nft delete map inet filter amneziawg_ports

" >> "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"
}

save_awg_interface() {
    case "$AWG_INTERFACE_IP_VERSION_USE" in
        "ipv4")
            AWG_INTERFACE_ADDRESS="${AWG_INTERFACE_IPV4}/24"
            ;;
        "ipv6")
            AWG_INTERFACE_ADDRESS="${AWG_INTERFACE_IPV6}/64"
            ;;
        "both")
            AWG_INTERFACE_ADDRESS="${AWG_INTERFACE_IPV4}/24, ${AWG_INTERFACE_IPV6}/64"
            ;;
    esac

    echo "[Interface]
ListenPort = ${AWG_INTERFACE_PORT}
Address = ${AWG_INTERFACE_ADDRESS}
PrivateKey = ${AWG_INTERFACE_PRIVATE_KEY}
S1 = ${AWG_INTERFACE_S1}
S2 = ${AWG_INTERFACE_S2}
S3 = ${AWG_INTERFACE_S3}
S4 = ${AWG_INTERFACE_S4}
H1 = ${AWG_INTERFACE_H1}
H2 = ${AWG_INTERFACE_H2}
H3 = ${AWG_INTERFACE_H3}
H4 = ${AWG_INTERFACE_H4}
MTU = ${AWG_INTERFACE_MTU}
" > "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf"

    if ps -e | grep '[f]irewalld' > /dev/null 2>&1; then
        add_awg_interface_firewalld_rules
    else
        add_awg_interface_nftables_rules
    fi
}

reserve_awg_interface_port() {
    echo "${AWG_INTERFACE_PORT}" >> "${AWG_SERVER_TOOLS_PATH}/interfaces/.ports_reserved"
}

reserve_awg_interface_ipv4() {
    echo "${AWG_INTERFACE_IPV4}" >> "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv4_reserved"
}

reserve_awg_interface_ipv6() {
    AWG_CHECK_INTERFACE_IPV6="$AWG_INTERFACE_IPV6"

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

    echo "${AWG_CHECK_INTERFACE_IPV6_ALL_PARTS}" >> "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv6_reserved"
}

save_awg_interface_data() {
    AWG_INTERFACE_FOLDER_PATH="${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}"

    mkdir -p "$AWG_INTERFACE_FOLDER_PATH"

    case "$AWG_INTERFACE_IP_VERSION_USE" in
        "ipv4")
            AWG_INTERFACE_IPS="AWG_INTERFACE_IPV4=\"${AWG_INTERFACE_IPV4}\""
            ;;
        "ipv6")
            AWG_INTERFACE_IPS="AWG_INTERFACE_IPV6=\"${AWG_INTERFACE_IPV6}\""
            ;;
        "both")
            AWG_INTERFACE_IPS="AWG_INTERFACE_IPV4=\"${AWG_INTERFACE_IPV4}\"\nAWG_INTERFACE_IPV6=\"${AWG_INTERFACE_IPV6}\""
            ;;
    esac

    printf "AWG_INTERFACE_IP_VERSION_USE=\"${AWG_INTERFACE_IP_VERSION_USE}\"
${AWG_INTERFACE_IPS}
AWG_INTERFACE_PUBLIC_KEY=\"${AWG_INTERFACE_PUBLIC_KEY}\"
AWG_INTERFACE_PRIVATE_KEY=\"${AWG_INTERFACE_PRIVATE_KEY}\"
AWG_INTERFACE_S1=\"${AWG_INTERFACE_S1}\"
AWG_INTERFACE_S2=\"${AWG_INTERFACE_S2}\"
AWG_INTERFACE_S3=\"${AWG_INTERFACE_S3}\"
AWG_INTERFACE_S4=\"${AWG_INTERFACE_S4}\"
AWG_INTERFACE_H1=\"${AWG_INTERFACE_H1}\"
AWG_INTERFACE_H2=\"${AWG_INTERFACE_H2}\"
AWG_INTERFACE_H3=\"${AWG_INTERFACE_H3}\"
AWG_INTERFACE_H4=\"${AWG_INTERFACE_H4}\"
AWG_INTERFACE_MTU=\"${AWG_INTERFACE_MTU}\"
AWG_INTERFACE_PORT=\"${AWG_INTERFACE_PORT}\"
" >> "${AWG_INTERFACE_FOLDER_PATH}/${AWG_INTERFACE_NAME}.data"

    reserve_awg_interface_port

    case "$AWG_INTERFACE_IP_VERSION_USE" in
        "ipv4")
            reserve_awg_interface_ipv4
            ;;
        "ipv6")
            reserve_awg_interface_ipv6
            ;;
        "both")
            reserve_awg_interface_ipv4
            reserve_awg_interface_ipv6
            ;;
    esac
}

check_awg_interface_service() {
    if systemctl --no-pager --no-ask-password status "awg-quick@${AWG_INTERFACE_NAME}" > /dev/null 2>&1; then
        echo ""
        printf "${GREEN}Interface ${BOLD_FS}\"${AWG_INTERFACE_NAME}\"${DEFAULT_FS} is succesfuly created.${DEFAULT_COLOR}\n"
    else
        echo ""
        printf "${YELLOW}WARNING:${DEFAULT_COLOR} ${BOLD_FS}Interface \"${AWG_INTERFACE_NAME}\" appears to be inactive.${DEFAULT_FS}\n"
        echo "You can verify the service status by running: systemctl status awg-quick@${AWG_INTERFACE_NAME}"
    fi
}

create_awg_interface() {
    echo "------------------"
    printf "${BOLD_FS} Create Interface ${DEFAULT_FS}\n"
    echo "------------------"
    echo ""

    get_awg_interface_name

    get_awg_interface_ip

    get_awg_interface_mtu

    get_awg_interface_port

    echo ""
    get_awg_interface_s1

    get_awg_interface_s2

    get_awg_interface_s3

    get_awg_interface_s4

    while :; do
        get_awg_interface_h1

        get_awg_interface_h2

        get_awg_interface_h3

        get_awg_interface_h4

        if ! awk -v r1="$AWG_INTERFACE_H1" -v r2="$AWG_INTERFACE_H2" -v r3="$AWG_INTERFACE_H3" -v r4="$AWG_INTERFACE_H4" 'BEGIN{split(r1,a,"-");s[1]=a[1];e[1]=a[2];split(r2,a,"-");s[2]=a[1];e[2]=a[2];split(r3,a,"-");s[3]=a[1];e[3]=a[2];split(r4,a,"-");s[4]=a[1];e[4]=a[2];for(i=1;i<=4;i++)for(j=i+1;j<=4;j++)if(s[i]<=e[j]&&s[j]<=e[i])exit 1}'; then
            printf "${YELLOW}The Ranges of H params overlap. Please re-enter them.${DEFAULT_COLOR}\n"
            continue
        fi

        break
    done

    create_awg_interface_key_pair

    save_awg_interface

    save_awg_interface_data

    echo ""
    start_awg_interface_service "$AWG_INTERFACE_NAME"

    check_awg_interface_service
}
