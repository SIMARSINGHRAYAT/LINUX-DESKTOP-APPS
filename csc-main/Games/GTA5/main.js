'use strict';

const { app, BrowserWindow } = require('electron');
const path = require('node:path');

const GAME_URL = 'https://v2.fiveplay.lol/launcher.html';
const GAME_ORIGIN = new URL(GAME_URL).origin;
const WINDOW_TITLE = 'GTA 5';

app.commandLine.appendSwitch('disable-setuid-sandbox');
app.setName(WINDOW_TITLE);
app.setPath('userData', path.join(app.getPath('appData'), 'gta-5'));

function keepNavigationInGame(event, rawUrl) {
  let target;
  try {
    target = new URL(rawUrl);
  } catch {
    event.preventDefault();
    return;
  }
  if (target.origin === GAME_ORIGIN) return;
  event.preventDefault();
  event.preventDefault();
}

function createWindow() {
  const window = new BrowserWindow({
    width: 1280,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    autoHideMenuBar: true,
    title: WINDOW_TITLE,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true
    }
  });

  window.webContents.setUserAgent(
    window.webContents.getUserAgent().replace(/\sElectron\/\S+/, '')
  );
  window.webContents.on('page-title-updated', (event) => {
    event.preventDefault();
    window.setTitle(WINDOW_TITLE);
  });
  window.webContents.on('will-navigate', keepNavigationInGame);
  window.webContents.on('will-redirect', keepNavigationInGame);
  window.webContents.setWindowOpenHandler(({ url }) => {
    let target;
    try {
      target = new URL(url);
    } catch {
      return { action: 'deny' };
    }

    if (target.origin === GAME_ORIGIN) {
      return {
        action: 'allow',
        overrideBrowserWindowOptions: {
          autoHideMenuBar: true,
          webPreferences: {
            contextIsolation: true,
            nodeIntegration: false,
            sandbox: true
          }
        }
      };
    }

    return { action: 'deny' };
  });

  window.webContents.on('did-fail-load', (_event, errorCode, errorDescription, validatedURL, isMainFrame) => {
    if (isMainFrame) {
      console.error(`Could not load ${validatedURL} (${errorCode}): ${errorDescription}`);
    }
  });
  window.loadURL(GAME_URL).catch((error) => {
    console.error(`Could not load ${GAME_URL}:`, error);
  });
}

app.whenReady()
  .then(createWindow)
  .catch((error) => {
    console.error('Could not start the GTA 5 Electron app:', error);
    app.exit(1);
  });

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) createWindow();
});

app.on('window-all-closed', () => app.quit());
