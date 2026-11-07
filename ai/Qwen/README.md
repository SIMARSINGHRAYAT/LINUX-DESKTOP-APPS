# Qwen Desktop

Unofficial Electron wrapper for [Qwen Chat](https://chat.qwen.ai/). It keeps the Qwen session in a persistent desktop profile, supports downloads and notifications, and opens non-Qwen links in the system browser.

## Ubuntu

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/484161a66e5fd8f2e550a1ebf8fcac7fa65c36fe/ai/Qwen/install.sh | LINUX_DESKTOP_DISTRO=ubuntu sh
```

## Kali Linux

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/484161a66e5fd8f2e550a1ebf8fcac7fa65c36fe/ai/Qwen/install.sh | LINUX_DESKTOP_DISTRO=kali sh

## Debian

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/484161a66e5fd8f2e550a1ebf8fcac7fa65c36fe/ai/Qwen/install.sh | LINUX_DESKTOP_DISTRO=debian sh
```
```

Kali receives an AppImage launcher. Ubuntu and Debian receive a Debian package. The installer automatically uses a checksum-verified Node.js 22 runtime when the system Node.js is missing or too old.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/ai/Qwen/uninstall.sh | sh
```

## Local development

```bash
npm install
npm start
```
