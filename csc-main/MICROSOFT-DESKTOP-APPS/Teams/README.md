# Microsoft Teams Desktop

This is an unofficial Electron wrapper around Microsoft's official web application.

## Purpose
Microsoft Teams runs unchanged at `https://teams.microsoft.com/`; Electron supplies the Linux desktop window, persistent profile, navigation policy, permissions, downloads, and native menu.

## Linux Installation

```bash
curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/Teams/install.sh | bash
```

## Linux Uninstallation

```bash
curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/Teams/uninstall.sh | bash
```

## Requirements
- Linux x64 (Ubuntu, Debian, Linux Mint, or Kali Linux)
- Node.js 22.12 or newer
- npm

## Install and run
```sh
npm install
npm start
```
Use `npm run dev` for development logging. Authentication, MFA, account switching, and session lifetime are handled by Microsoft. The persistent Electron partition is not cleared on normal shutdown.

## Build Linux packages
```sh
npm run build
# or: npm run build:linux
```
Packages are written to `dist/` as AppImage and `.deb` artifacts. No generated package files should be committed.

## Permissions
Trusted Microsoft origins may request microphone, camera, notifications, and clipboard permissions. Requests from other origins are denied. Downloads go to the normal Linux Downloads directory and are never executed by the wrapper.

## Trusted domains
Teams and Microsoft authentication may use `teams.microsoft.com`, `teams.cloud.microsoft`, `teams.live.com`, `microsoft.com`, `microsoftonline.com`, `office.com`, `office365.com`, `live.com`, `cloud.microsoft`, `msauth.net`, `msftauth.net`, `msidentity.com`, and `office.net` over HTTPS.

## Known limitations
Microsoft controls feature availability in Chromium/Electron. Browser-only or platform-specific Teams features may be unavailable. This wrapper does not implement chat, calls, authentication, Graph APIs, notifications, or collaboration functionality.

## Troubleshooting
Use `Account > Clear Session Data` to reset this app's Microsoft session. Use `View > Developer Tools` during development to inspect Microsoft-provided diagnostics. Network failures show a retry page; no Microsoft application data is manually cached.
