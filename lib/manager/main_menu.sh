clean_lines() {
    NUM="0"
    while [ "$NUM" -lt "$1" ]; do
        printf '\033[1A'
        printf '\033[2K'

        NUM=$((NUM + 1))
    done
}

validate_ipv4() {
    if ! printf '%s' "$1" | grep "^\([0-9][0-9]*\.\)\{3\}[0-9][0-9]*$" > /dev/null 2>&1; then
        return 1
    fi


    VALIDATE_IPV4="$1"
    
    VALIDATE_IPV4_FIRST_PART=${VALIDATE_IPV4%%.*}

    VALIDATE_IPV4=${VALIDATE_IPV4#*.}

    VALIDATE_IPV4_SECOND_PART=${VALIDATE_IPV4%%.*}

    VALIDATE_IPV4=${VALIDATE_IPV4#*.}

    VALIDATE_IPV4_THIRD_PART=${VALIDATE_IPV4%%.*}

    VALIDATE_IPV4_FOURTH_PART=${VALIDATE_IPV4#*.}

    if [ "$VALIDATE_IPV4_FIRST_PART" -lt 1 ] || [ "$VALIDATE_IPV4_FIRST_PART" -gt 254 ]; then
        return 1
    fi

    if [ "$VALIDATE_IPV4_SECOND_PART" -lt 1 ] || [ "$VALIDATE_IPV4_SECOND_PART" -gt 254 ]; then
        return 1
    fi

    if [ "$VALIDATE_IPV4_THIRD_PART" -lt 1 ] || [ "$VALIDATE_IPV4_THIRD_PART" -gt 254 ]; then
        return 1
    fi

    if [ "$VALIDATE_IPV4_FOURTH_PART" -lt 1 ] || [ "$VALIDATE_IPV4_FOURTH_PART" -gt 254 ]; then
        return 1
    fi


    return 0
}

validate_ipv6() {
    if ! printf '%s' "$1" | awk '{s=$0; if(gsub(/::/,"::",s)>1) exit 1; n=split($0,p,"::"); left=p[1]; if(n>1) right=p[2]; else right=""; nL=split(left,L,":"); if(right=="") nR=0; else nR=split(right,R,":"); g=nL+nR; if(index($0,".")) exit 1; if(index($0,"::")) { if(g>7) exit 1 } else { if(g!=8) exit 1 } for(i=1;i<=nL;i++) if(L[i]!="" && match(L[i],"^[0-9A-Fa-f]{1,4}$")==0) exit 1; for(i=1;i<=nR;i++) if(R[i]!="" && match(R[i],"^[0-9A-Fa-f]{1,4}$")==0) exit 1; exit 0 }'; then
        return 1
    fi

    return 0
}


main_menu() {
    while :; do
        echo "-------------------------"
        echo "${BOLD_FS} AmneziaWG Manager ${AWG_TOOLS_VERSION} ${DEFAULT_FS} -> https://github.com/SoVoKaN/amneziawg-server-tools"
        echo "-------------------------"
        echo ""
        echo "1) Manage clients"
        echo "2) Manage interfaces"
        echo ""
        echo "0) Exit"
        echo ""

        printf "Select option [0-2]: "

        handle_user_input

        clean_lines "10"

        case "$USER_INPUT" in
            "1")
                clients_menu
                ;;
            "2")
                interfaces_menu
                ;;
            "0")
                break
                ;;
        esac
    done
}
