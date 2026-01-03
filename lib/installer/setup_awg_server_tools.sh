create_directories() {
    mkdir -p "$AWG_CLIENT_CONFIGS_PATH"

    mkdir -p "$AWG_SERVER_TOOLS_PATH"

    mkdir -p "${AWG_SERVER_TOOLS_PATH}/interfaces"
}

create_files() {
    touch "${AWG_SERVER_TOOLS_PATH}/interfaces/.ports_reserved"

    touch "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv4_reserved"

    if [ "$IPV6_SUPPORT_ENABLED" = "y" ]; then
        touch "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv6_reserved"
    fi
}

save_server_tools_config() {
    echo "IPV6_SUPPORT_ENABLED=${IPV6_SUPPORT_ENABLED}

SERVER_PUBLIC_NETWORK_INTERFACE=${SERVER_PUBLIC_NETWORK_INTERFACE}
SERVER_PUBLIC_IP_OR_DOMAIN=${SERVER_PUBLIC_IP_OR_DOMAIN}
AWG_CLIENT_CONFIGS_PATH=${AWG_CLIENT_CONFIGS_PATH}

AWG_SERVER_TOOLS_PATH=${AWG_SERVER_TOOLS_PATH}" > "${AWG_SERVER_TOOLS_PATH}/server-tools.conf"
}

enable_routing() {
    echo "net.ipv4.ip_forward = 1" > "/etc/sysctl.d/amneziawg.conf"

    if [ "$IPV6_SUPPORT_ENABLED" = "y" ]; then
        echo "net.ipv6.conf.all.forwarding = 1" >> "/etc/sysctl.d/amneziawg.conf"
    fi

    sysctl --system > /dev/null 2>&1
}


setup_awg_server_tools() {
    AWG_SERVER_TOOLS_PATH="/etc/amnezia/amneziawg/server-tools"

    create_directories

    create_files

    save_server_tools_config

    enable_routing
}
