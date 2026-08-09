# Microsoft Power BI Desktop

This is an unofficial Electron wrapper around Microsoft's official web application.

Official service: `https://app.powerbi.com/`

## Requirements and installation
Linux x64, Node.js 22.12+, and npm. Run `npm install`, then `npm start`; use `npm run dev` for development logging.

## Build
`npm run build` or `npm run build:linux` creates independent AppImage and `.deb` packages in `dist/`.

## Authentication and permissions
Microsoft handles Microsoft Accounts, Microsoft 365 sign-in, MFA, redirects, and session lifetime. The app uses a persistent app-specific Electron partition and does not store passwords or tokens. Only trusted Microsoft origins may receive notifications or clipboard permissions. Downloads use the normal Linux Downloads directory.

## Known limitations and troubleshooting
The wrapper does not implement dashboards, reports, rendering, exports, authentication, or Graph APIs. Microsoft controls browser compatibility and feature availability. Use `Account > Clear Session Data` to reset the profile. Network errors provide a Retry page.

Trusted domains include `app.powerbi.com`, `powerbi.com`, `microsoft.com`, `microsoftonline.com`, `office.com`, `office365.com`, `live.com`, `cloud.microsoft`, `msauth.net`, `msftauth.net`, `msidentity.com`, and `office.net` over HTTPS.
