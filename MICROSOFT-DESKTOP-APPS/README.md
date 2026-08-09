# Microsoft Desktop Apps for Linux

Four independent, unofficial Electron wrappers around Microsoft's official web applications. Electron provides the Linux desktop shell; Microsoft provides the UI, authentication, cloud functionality, synchronization, collaboration, mail, reports, and boards.

| Application | Official Web Service | Desktop Wrapper |
| --- | --- | --- |
| Microsoft Teams | [teams.microsoft.com](https://teams.microsoft.com/) | Electron |
| Microsoft Power BI | [app.powerbi.com](https://app.powerbi.com/) | Electron |
| Microsoft Whiteboard | [whiteboard.cloud.microsoft](https://whiteboard.cloud.microsoft/) | Electron |
| Microsoft Outlook | [outlook.live.com](https://outlook.live.com/) / [outlook.office.com](https://outlook.office.com/) | Electron |

Each directory is standalone: install dependencies and build from `Teams/`, `PowerBI/`, `Whiteboard/`, or `Outlook/` independently. Every app produces an AppImage and Debian package under its own `dist/` directory.

Authentication is always performed by Microsoft in its own web flow. These projects do not collect credentials, store passwords or tokens, scrape or iframe Microsoft sites, inject replacement UI, add telemetry, or implement Microsoft backend functionality.

These are unofficial wrappers and are not Microsoft Linux applications. Review each app's README for trusted domains, permission policy, packaging, and limitations.
