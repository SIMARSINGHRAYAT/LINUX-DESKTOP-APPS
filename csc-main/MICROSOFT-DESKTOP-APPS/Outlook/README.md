# Microsoft Outlook Desktop

This is an unofficial Electron wrapper around Microsoft's official web application.

Official starting service: `https://outlook.live.com/`; work and school redirects such as `https://outlook.office.com/` remain trusted.

## Linux Installation

```bash
curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/Outlook/install.sh | bash
```

## Linux Uninstallation

```bash
curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/Outlook/uninstall.sh | bash
```

## Requirements and installation
Linux x64, Node.js 22.12+, and npm. Run `npm install`, then `npm start`; use `npm run dev` for development logging.

## Build
`npm run build` or `npm run build:linux` creates independent AppImage and `.deb` packages in `dist/`.

## Authentication and permissions
Microsoft handles accounts, MFA, email, calendar, contacts, notifications, and redirects. Persistent app-specific Electron storage preserves valid sessions without storing passwords, tokens, emails, or cookies in custom files. Trusted Microsoft origins may receive notifications and clipboard permissions. Downloads use the normal Linux Downloads directory.

## Known limitations and troubleshooting
This wrapper does not implement mail protocols, a backend, or a custom email UI. Use `Account > Clear Session Data` to reset the profile. Network errors provide a Retry page. Trusted hosts include `outlook.live.com`, `outlook.office.com`, `office.com`, `office365.com`, `microsoft.com`, `microsoftonline.com`, `live.com`, `cloud.microsoft`, `msauth.net`, `msftauth.net`, `msidentity.com`, and `office.net` over HTTPS.
