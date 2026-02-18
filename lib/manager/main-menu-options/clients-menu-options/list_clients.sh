check_has_awg_interface_clients() {
    for FILE in "${AWG_SERVER_TOOLS_PATH}/interfaces/${AWG_INTERFACE_NAME}/clients/"*.data; do
        if [ -f "$FILE" ]; then
            return
        fi
    done

    return 1
}

create_clients_list() {
    CLIENTS_LIST=$(awk -v interface_name="$AWG_INTERFACE_NAME" -v ip_version_mode="$AWG_INTERFACE_IP_VERSION_USE" '
BEGIN {
    clients_list = "\"" interface_name "\"" " clients" "\\n\\n"
}
prev ~ "^###" {
    if ($0 == "[Peer]") {
        client_state = "Active"
    }
    else if ($0 == "#[Peer]") {
        client_state = "Inactive"
    }
    else { next }

    split(prev, name_arr, " ")

    clients_list = clients_list name_arr[2] " "

    for (i = 0; i < 3; i++) {
        if (getline <= 0) break
    }

    if (ip_version_mode == "ipv4") {
        split($3, ipv4_arr, "/")

        clients_list = clients_list "(" client_state ", IPv4: " ipv4_arr[1] ")" "\\n"
    }
    else if (ip_version_mode == "ipv6") {
        split($3, ipv6_arr, "/")

        clients_list = clients_list "(" client_state ", IPv6: " ipv6_arr[1] ")" "\\n"
    }
    else {
        split($3, ipv4_arr, "/")

        split($4, ipv6_arr, "/")

        clients_list = clients_list "(" client_state ", IPv4: " ipv4_arr[1] ", IPv6: " ipv6_arr[1] ")" "\\n"
    }
}
{ prev = $0 }
END {
    print clients_list
}
' "/etc/amnezia/amneziawg/${AWG_INTERFACE_NAME}.conf")
}

print_clients() {
    if [ -n "$AWG_SERVER_TOOLS_PAGER" ]; then
        printf "$CLIENTS_LIST" | "$AWG_SERVER_TOOLS_PAGER"
    else
        printf "$CLIENTS_LIST"
    fi
}


list_awg_clients() {
    set_awg_server_tools_pager

    if ! check_has_awg_interface_clients; then
        if [ -n "$AWG_SERVER_TOOLS_PAGER" ]; then
            printf "No clients have been created yet." | "$AWG_SERVER_TOOLS_PAGER"
        else
            printf "\n${BOLD_FS}No clients have been created yet.${DEFAULT_FS}\n\n"
        fi

        return
    fi

    create_clients_list

    print_clients
}
