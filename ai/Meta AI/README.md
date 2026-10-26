# Meta AI Desktop

Unofficial Electron wrapper for [Meta AI](https://www.meta.ai/). It keeps the Meta AI session in a persistent desktop profile, supports downloads and notifications, and opens links outside Meta in the system browser.

Current desktop app version: **1.0.3**.

HTTPS login and authentication popups stay inside the app and use its persistent session, so signing in does not switch to the system browser.

## Ubuntu

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/ai/Meta%20AI/install.sh | LINUX_DESKTOP_DISTRO=ubuntu sh
```

## Kali Linux

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/ai/Meta%20AI/install.sh | LINUX_DESKTOP_DISTRO=kali sh
```

Kali receives an AppImage launcher. Ubuntu receives a Debian package. On Kali, the installer uses a checksum-verified local Node.js 22 runtime when the system Node.js version is missing or too old. The installer requires git, curl, and an apt-based Linux system.

To update an existing installation and refresh its logo, run the installer command for your distribution again.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/ai/Meta%20AI/uninstall.sh | sh
```

## Local development

```bash
npm install
npm start
```
