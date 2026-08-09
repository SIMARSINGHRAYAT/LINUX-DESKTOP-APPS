# Microsoft Whiteboard Desktop

This is an unofficial Electron wrapper around Microsoft's official web application.

Verified official web service: `https://whiteboard.cloud.microsoft/` (the former `https://whiteboard.office.com` redirects there).

## Requirements and installation
Linux x64, Node.js 22.12+, and npm. Run `npm install`, then `npm start`; use `npm run dev` for development logging.

## Build
`npm run build` or `npm run build:linux` creates independent AppImage and `.deb` packages in `dist/`.

## Authentication and permissions
Microsoft owns login, MFA, boards, saving, sharing, and collaboration. The app uses persistent app-specific storage and never collects credentials. Trusted Whiteboard/Microsoft origins may receive notifications and clipboard permissions. Downloads use the normal Linux Downloads directory.

## Known limitations and troubleshooting
This wrapper does not implement a canvas, drawing tools, collaboration, or Microsoft APIs. Use `Account > Clear Session Data` to reset the profile. Network errors provide a Retry page. Trusted hosts include `whiteboard.cloud.microsoft`, `cloud.microsoft`, `microsoft.com`, `microsoftonline.com`, `office.com`, `office365.com`, `live.com`, `msauth.net`, `msftauth.net`, `msidentity.com`, and `office.net` over HTTPS.
