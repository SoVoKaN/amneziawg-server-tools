# [AmneziaWG](https://docs.amnezia.org/documentation/amnezia-wg/) Server Tools

This is an interactive CLI that makes installing and managing the [amneziawg-linux-kernel-module](https://github.com/amnezia-vpn/amneziawg-linux-kernel-module) effortless &ndash; all with just a few keystrokes. 
Allows you to create unlimited awg interfaces, toggle them, manage clients, and receive a ready-to-use client configuration immediately after creation.

### Supported Linux distributions

![Debian 11+](https://img.shields.io/badge/Debian_11%2B-A80030?logo=debian&logoColor=white)
![Ubuntu 20.04+](https://img.shields.io/badge/Ubuntu_20.04%2B-E95420?logo=ubuntu&logoColor=white)

![Alma 9+](https://img.shields.io/badge/Alma_9%2B-dbaf12?logo=almalinux&logoColor=white)
![Rocky 9+](https://img.shields.io/badge/Rocky_9%2B-10B981?logo=rockylinux&logoColor=white)
![CentOS 9+](https://img.shields.io/badge/CentOS_9%2B-A14F8C?logo=centos&logoColor=white)

## Download &amp; Install

Before installation, it is strongly recommended to upgrade your system to the latest available version and reboot afterwards.

<br>

Use wget or curl to download:

```sh
wget https://sovokan.github.io/amneziawg-server-tools/amneziawg-server-tools-latest.tar.gz
```

```sh
curl -O https://sovokan.github.io/amneziawg-server-tools/amneziawg-server-tools-latest.tar.gz
```

Extract archive:

```sh
tar -xzf amneziawg-server-tools-latest.tar.gz
```

Run installer:

```sh
cd amneziawg-server-tools

./install.sh
```

<br>

After launching the installer, simply follow its interactive prompts and answer the questions as they appear.

## Documentation

In addition to this [`README`](README.md), the following documents are also available:

- [`quick-start`](docs/quick-start.md) &ndash; Quick setup and usage instructions.
