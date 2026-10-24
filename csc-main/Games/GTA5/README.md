# GTA 5 on Ubuntu

This installer adds a **GTA 5** entry to the Ubuntu applications menu and installs an Electron runtime for the desktop app. Node.js and npm must be installed first:

```bash
sudo apt update
sudo apt install -y nodejs npm
```

The desktop app opens the game's launcher at [v2.fiveplay.lol/launcher.html](https://v2.fiveplay.lol/launcher.html) using Electron and a Chromium-compatible user agent. Its launcher enables Chromium's WebGPU support so the game can access a graphics adapter on Linux. It disables only the setuid sandbox helper; Chromium's user-namespace sandbox remains enabled. On Ubuntu systems that restrict user namespaces with AppArmor, the launcher uses the existing `chrome` AppArmor profile only if it allows user namespaces; if not, it reports that restriction instead of disabling Chromium's sandbox. It does not download or install Rockstar's GTA V game files. Only install a certificate offered by the site if you independently trust the host.

The included controller icon is a generic replacement, not the official GTA 5 logo. Use an authorized logo asset if you have rights to distribute one.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/Games/GTA5/install.sh | sh
```

Search for **GTA 5** in the applications menu to launch the Electron app.
If Electron exits without opening, the launcher saves its output to `~/.local/state/gta-5/launch.log`.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/Games/GTA5/uninstall.sh | sh
```

Uninstalling removes the Electron runtime and launcher but leaves the Electron profile, local game data, and launch log intact.
