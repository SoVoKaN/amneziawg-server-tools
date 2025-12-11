install_packages() {
    dnf check-update
    dnf install kernel-headers-$(uname -r) kernel-devel-$(uname -r)

    dnf copr enable -y amneziavpn/amneziawg

    dnf check-update
    dnf install -y ${INSTALLATION_PACKAGES}
}
