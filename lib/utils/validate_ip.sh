validate_ipv4() {
    VALIDATE_IPV4="$1"

    case "$VALIDATE_IPV4" in
        *.*.*.*.*) return 1 ;;
    esac

    IFS="."

    AWG_VALIDATE_IPV4_PARTS_COUNT="0"
    for PART in $VALIDATE_IPV4; do
        AWG_VALIDATE_IPV4_PARTS_COUNT=$((AWG_VALIDATE_IPV4_PARTS_COUNT + 1))
    done

    if [ "$AWG_VALIDATE_IPV4_PARTS_COUNT" != "4" ]; then
        return 1
    fi

    for PART in $VALIDATE_IPV4; do
        case "$PART" in
            [0-9] | [0-9][0-9] | [0-9][0-9][0-9]) ;;
            *) return 1 ;;
        esac

        if [ "$PART" -lt 0 ] || [ "$PART" -gt 255 ]; then
            return 1
        fi
    done

    unset IFS

    return 0
}

validate_ipv6() {
    VALIDATE_IPV6="$1"

    case "$VALIDATE_IPV6" in
        *.*) return 1 ;;
        *:::*) return 1 ;;
        *::*::*) return 1 ;;
    esac

    AWG_VALIDATE_IPV6_LEFT_SIDE=${VALIDATE_IPV6%%::*}
    AWG_VALIDATE_IPV6_RIGHT_SIDE=${VALIDATE_IPV6#*::}

    if [ "$AWG_VALIDATE_IPV6_LEFT_SIDE" = "$AWG_VALIDATE_IPV6_RIGHT_SIDE" ]; then
        AWG_VALIDATE_IPV6_RIGHT_SIDE=""
    fi

    IFS=":"

    AWG_VALIDATE_IPV6_LEFT_SIDE_PARTS_COUNT="0"
    for PART in $AWG_VALIDATE_IPV6_LEFT_SIDE; do
        AWG_VALIDATE_IPV6_LEFT_SIDE_PARTS_COUNT=$((AWG_VALIDATE_IPV6_LEFT_SIDE_PARTS_COUNT + 1))
    done

    AWG_VALIDATE_IPV6_RIGHT_SIDE_PARTS_COUNT="0"
    for PART in $AWG_VALIDATE_IPV6_RIGHT_SIDE; do
        AWG_VALIDATE_IPV6_RIGHT_SIDE_PARTS_COUNT=$((AWG_VALIDATE_IPV6_RIGHT_SIDE_PARTS_COUNT + 1))
    done

    AWG_VALIDATE_IPV6_PARTS_SUM=$((AWG_VALIDATE_IPV6_LEFT_SIDE_PARTS_COUNT + AWG_VALIDATE_IPV6_RIGHT_SIDE_PARTS_COUNT))

    case "$VALIDATE_IPV6" in
        *::*)
            if [ "$AWG_VALIDATE_IPV6_PARTS_SUM" -gt 7 ]; then
                return 1
            fi
            ;;
        *)
            if [ "$AWG_VALIDATE_IPV6_PARTS_SUM" != "8" ]; then
                return 1
            fi
            ;;
    esac

    if [ -n "$AWG_VALIDATE_IPV6_LEFT_SIDE" ]; then

        for PART in $AWG_VALIDATE_IPV6_LEFT_SIDE; do
            case "$PART" in
                [0-9a-fA-F] | [0-9a-fA-F][0-9a-fA-F] | [0-9a-fA-F][0-9a-fA-F][0-9a-fA-F] | [0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]) ;;
                *) return 1 ;;
            esac
        done
    fi

    if [ -n "$AWG_VALIDATE_IPV6_RIGHT_SIDE" ]; then

        for PART in $AWG_VALIDATE_IPV6_RIGHT_SIDE; do
            case "$PART" in
                [0-9a-fA-F] | [0-9a-fA-F][0-9a-fA-F] | [0-9a-fA-F][0-9a-fA-F][0-9a-fA-F] | [0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]) ;;
                *) return 1 ;;
            esac
        done
    fi

    unset IFS

    return 0
}
