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

Kali receives an AppImage launcher, and Ubuntu/Debian receive a Debian package. All distributions use a checksum-verified Node.js 22 runtime in the user data directory when the system Node.js is missing or too old. Git and curl are required.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/ai/Copilot/uninstall.sh | sh
```

## Local development

```bash
npm install
npm start
```
