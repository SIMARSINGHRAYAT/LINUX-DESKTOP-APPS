# GTA 5 on Ubuntu

This installer adds a GTA 5 entry to the Ubuntu applications menu. It opens the supplied browser game in a dedicated Chromium-based app window when Chromium, Google Chrome, or Brave is installed; otherwise it opens the URL with `xdg-open`.

The launcher does not download or install Rockstar's GTA V game files. The browser game is hosted at [v2.fiveplay.lol](https://v2.fiveplay.lol). Its website recommends an up-to-date Chromium-based browser. Only install a certificate offered by the site if you independently trust the host.

The included controller icon is a generic replacement, not the official GTA 5 logo. Use an authorized logo asset if you have rights to distribute one.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/Games/GTA5/install.sh | sh
```

Search for **GTA 5** in the applications menu to launch it.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/Games/GTA5/uninstall.sh | sh
```

Uninstalling removes the launcher but leaves the browser profile and its local game saves intact.
