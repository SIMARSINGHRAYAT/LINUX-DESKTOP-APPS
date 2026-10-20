# Copilot Desktop

Unofficial Electron wrapper for [Microsoft Copilot](https://copilot.com). It keeps the Copilot session in a persistent desktop profile and opens untrusted links in the system browser.

## Ubuntu

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/ai/Copilot/install.sh | LINUX_DESKTOP_DISTRO=ubuntu sh
```

## Kali Linux

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/ai/Copilot/install.sh | LINUX_DESKTOP_DISTRO=kali sh
```

Kali receives an AppImage launcher, with a checksum-verified Node.js 22 runtime installed in the user data directory so the build does not require APT or dpkg. Ubuntu and Debian receive a Debian package and use APT to install Node.js and npm when missing. Git and curl are required.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/ai/Copilot/uninstall.sh | sh
```

## Local development

```bash
npm install
npm start
```
