install_packages() {
    dnf check-update || true
    dnf install -y kernel-headers-$(uname -r) kernel-devel-$(uname -r)

    dnf copr enable -y amneziavpn/amneziawg

    dnf check-update || true
    dnf install -y ${INSTALLATION_PACKAGES}
}
