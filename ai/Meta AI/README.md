# Meta AI Desktop

Unofficial Electron wrapper for [Meta AI](https://www.meta.ai/). It keeps the Meta AI session in a persistent desktop profile, supports downloads and notifications, and opens links outside Meta in the system browser.

## Ubuntu

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/ai/Meta%20AI/install.sh | LINUX_DESKTOP_DISTRO=ubuntu sh
```

## Kali Linux

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/ai/Meta%20AI/install.sh | LINUX_DESKTOP_DISTRO=kali sh
```

Kali receives an AppImage launcher. Ubuntu receives a Debian package. The installer requires Node.js 22+, npm, git, and an apt-based Linux system.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/ai/Meta%20AI/uninstall.sh | sh
```

## Local development

```bash
npm install
npm start
```
