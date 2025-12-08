create_directories() {
    mkdir -p "$AWG_CLIENT_CONFIGS_PATH"

    mkdir -p "$AWG_SERVER_TOOLS_PATH"

    mkdir -p "${AWG_SERVER_TOOLS_PATH}/interfaces"
}

create_files() {
    touch "${AWG_SERVER_TOOLS_PATH}/interfaces/.ports_reserved"

    touch "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv4_reserved"

    touch "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv6_reserved"
}

save_server_tools_config() {
    echo "SERVER_PUBLIC_NETWORK_INTERFACE=${SERVER_PUBLIC_NETWORK_INTERFACE}
SERVER_PUBLIC_IP_OR_DOMAIN=${SERVER_PUBLIC_IP_OR_DOMAIN}
AWG_CLIENT_CONFIGS_PATH=${AWG_CLIENT_CONFIGS_PATH}

AWG_SERVER_TOOLS_PATH=${AWG_SERVER_TOOLS_PATH}" > "${AWG_SERVER_TOOLS_PATH}/server-tools.conf"
}

enable_routing() {
    echo "net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" > "/etc/sysctl.d/awg.conf"

    sysctl --system > /dev/null 2>&1
}


setup_awg_server_tools() {
    AWG_SERVER_TOOLS_PATH="/etc/amnezia/amneziawg/server-tools"

    create_directories

    create_files

    save_server_tools_config

    enable_routing
}
