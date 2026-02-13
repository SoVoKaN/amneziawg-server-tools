create_directories() {
    mkdir -p "$AWG_CLIENT_CONFIGS_PATH"

    mkdir -p "$AWG_SERVER_TOOLS_PATH"

    mkdir -p "${AWG_SERVER_TOOLS_PATH}/interfaces"
}

create_files() {
    touch "${AWG_SERVER_TOOLS_PATH}/interfaces/.ports_reserved"

    case "$AWG_IP_VERSION_SUPPORT_MODE" in
        "ipv4")
            touch "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv4_reserved"
            ;;
        "ipv6")
            touch "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv6_reserved"
            ;;
        "both")
            touch "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv4_reserved"
            touch "${AWG_SERVER_TOOLS_PATH}/interfaces/.ipv6_reserved"
            ;;
    esac
}

save_server_tools_config() {
    echo "AWG_IP_VERSION_SUPPORT_MODE=\"${AWG_IP_VERSION_SUPPORT_MODE}\"

SERVER_PUBLIC_NETWORK_INTERFACE=\"${SERVER_PUBLIC_NETWORK_INTERFACE}\"
SERVER_PUBLIC_IP_OR_DOMAIN=\"${SERVER_PUBLIC_IP_OR_DOMAIN}\"
AWG_CLIENT_CONFIGS_PATH=\"${AWG_CLIENT_CONFIGS_PATH}\"

AWG_SERVER_TOOLS_PATH=\"${AWG_SERVER_TOOLS_PATH}\"" > "${AWG_SERVER_TOOLS_PATH}/.server-tools.conf"
}

enable_routing() {
    case "$AWG_IP_VERSION_SUPPORT_MODE" in
        "ipv4")
            echo "net.ipv4.ip_forward = 1" > "/etc/sysctl.d/amneziawg.conf"
            ;;
        "ipv6")
            echo "net.ipv6.conf.all.forwarding = 1" > "/etc/sysctl.d/amneziawg.conf"
            ;;
        "both")
            echo "net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" > "/etc/sysctl.d/amneziawg.conf"
            ;;
    esac

    sysctl --system > /dev/null 2>&1
}


setup_awg_server_tools() {
    AWG_SERVER_TOOLS_PATH="/etc/amnezia/amneziawg/server-tools"

    create_directories

    create_files

    save_server_tools_config

    enable_routing
}
