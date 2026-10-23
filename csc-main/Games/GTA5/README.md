# GTA 5 on Ubuntu

This installer adds a **GTA 5** entry to the Ubuntu applications menu and installs an Electron runtime for the desktop app. Node.js and npm must be installed first:

```bash
sudo apt update
sudo apt install -y nodejs npm
```

The desktop app opens the supplied web game at [v2.fiveplay.lol](https://v2.fiveplay.lol) using Electron. It does not download or install Rockstar's GTA V game files. Only install a certificate offered by the site if you independently trust the host.

The included controller icon is a generic replacement, not the official GTA 5 logo. Use an authorized logo asset if you have rights to distribute one.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/Games/GTA5/install.sh | sh
```

Search for **GTA 5** in the applications menu to launch the Electron app.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/Games/GTA5/uninstall.sh | sh
```

Uninstalling removes the Electron runtime and launcher but leaves the Electron profile and local game data intact.
