# Qwen Desktop

Unofficial Electron wrapper for [Qwen Chat](https://chat.qwen.ai/). It keeps the Qwen session in a persistent desktop profile, supports downloads and notifications, and opens non-Qwen links in the system browser.

## Ubuntu

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/ai/Qwen/install.sh | LINUX_DESKTOP_DISTRO=ubuntu sh
```

## Kali Linux

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/ai/Qwen/install.sh | LINUX_DESKTOP_DISTRO=kali sh
```

Kali receives an AppImage launcher. Ubuntu receives a Debian package. The installer requires Node.js 22+, npm, git, and an apt-based Linux system.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/ai/Qwen/uninstall.sh | sh
```

## Local development

```bash
npm install
npm start
```
