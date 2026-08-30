'use strict';

const { app, BrowserWindow, Menu, shell } = require('electron');
const fs = require('node:fs');
const path = require('node:path');

const APP_NAME = 'GitHub';
const APP_URL = 'https://github.com/';
let mainWindow;
let statePath;

function hasGraphicalSession() {
  if (process.platform !== 'linux') return true;
  const display = process.env.DISPLAY || process.env.WAYLAND_DISPLAY;
  if (display) return true;
  const sessionType = (process.env.XDG_SESSION_TYPE || '').toLowerCase();
  return sessionType === 'x11' || sessionType === 'wayland';
}

function openExternalUrl(url) {
  if (!url) return;
  void shell.openExternal(url);
}

function createMenu() {
  const template = [
    { label: 'File', submenu: [{ role: 'close' }, { role: 'quit' }] },
    { role: 'editMenu' },
    { label: 'View', submenu: [{ role: 'reload' }, { role: 'forceReload' }, { type: 'separator' }, { role: 'togglefullscreen' }] },
    { label: 'GitHub', submenu: [{ label: 'Open GitHub', click: () => mainWindow?.loadURL(APP_URL) }] }
  ];
  Menu.setApplicationMenu(Menu.buildFromTemplate(template));
}

function readState() {
  const fallback = { width: 1400, height: 900 };
  try {
    const saved = JSON.parse(fs.readFileSync(statePath, 'utf8'));
    if (Number.isInteger(saved.width) && Number.isInteger(saved.height)) {
      return { ...fallback, ...saved };
    }
  } catch {
    // Fresh state on first launch.
  }
  return fallback;
}

function writeState() {
  if (!mainWindow || mainWindow.isDestroyed()) return;
  const bounds = mainWindow.getNormalBounds();
  fs.mkdirSync(path.dirname(statePath), { recursive: true });
  fs.writeFileSync(statePath, JSON.stringify(bounds, null, 2));
}

async function createWindow() {
  statePath = path.join(app.getPath('userData'), 'window-state.json');
  const state = readState();

  mainWindow = new BrowserWindow({
    ...state,
    minWidth: 720,
    minHeight: 500,
    title: APP_NAME,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
      webSecurity: true,
    icon: path.join(__dirname, '..', 'resources', 'github-web.png'),
    }
  });

  mainWindow.on('resize', writeState);
  mainWindow.on('move', writeState);
  mainWindow.on('closed', () => {
    mainWindow = null;
  });

  await mainWindow.loadURL(APP_URL);
}

if (process.platform === 'linux' && !hasGraphicalSession()) {
  console.warn('No graphical session available; opening GitHub in the default browser instead.');
  app.whenReady().then(() => {
    openExternalUrl(APP_URL);
    app.quit();
  });
} else {
  const gotLock = app.requestSingleInstanceLock();
  if (!gotLock) {
    app.quit();
    return;
  }

  app.on('second-instance', () => {
    if (!mainWindow) return;
    if (mainWindow.isMinimized()) mainWindow.restore();
    mainWindow.focus();
  });

  app.whenReady().then(async () => {
    createMenu();
    await createWindow();
    app.on('activate', () => {
      if (BrowserWindow.getAllWindows().length === 0) {
        void createWindow();
      }
    });
  });

  app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') app.quit();
  });

  app.on('before-quit', writeState);
}
