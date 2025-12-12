uninstall_packages() {
    dnf remove -y amneziawg-dkms amneziawg-tools
    dnf copr remove -y ${UNINSTALLATION_PACKAGES}
}
