# Microsoft Desktop Apps for Linux

Four independent, unofficial Electron wrappers around Microsoft's official web applications. Electron provides the Linux desktop shell; Microsoft provides the UI, authentication, cloud functionality, synchronization, collaboration, mail, reports, and boards.

| Application | Official Web Service | Desktop Wrapper |
| --- | --- | --- |
| [Microsoft Teams](Teams/README.md) | [teams.microsoft.com](https://teams.microsoft.com/) | Electron |
| [Microsoft Power BI](PowerBI/README.md) | [app.powerbi.com](https://app.powerbi.com/) | Electron |
| [Microsoft Whiteboard](Whiteboard/README.md) | [whiteboard.cloud.microsoft](https://whiteboard.cloud.microsoft/) | Electron |
| [Microsoft Outlook](Outlook/README.md) | [outlook.live.com](https://outlook.live.com/) / [outlook.office.com](https://outlook.office.com/) | Electron |

Each directory is standalone: install dependencies and build from `Teams/`, `PowerBI/`, `Whiteboard/`, or `Outlook/` independently. Every app produces an AppImage and Debian package under its own `dist/` directory.

## One-line installation

```sh
curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/Outlook/install.sh | bash
curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/Teams/install.sh | bash
curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/PowerBI/install.sh | bash
curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/Whiteboard/install.sh | bash
```

Use the same URLs with `uninstall.sh` in place of `install.sh` to remove an app. Installation builds and installs a Debian desktop package, registers it in the system menu, and uses the matching PNG from `csc-main/logo/`.

Authentication is always performed by Microsoft in its own web flow. These projects do not collect credentials, store passwords or tokens, scrape or iframe Microsoft sites, inject replacement UI, add telemetry, or implement Microsoft backend functionality.

These are unofficial wrappers and are not Microsoft Linux applications. Review each app's README for trusted domains, permission policy, packaging, and limitations.
