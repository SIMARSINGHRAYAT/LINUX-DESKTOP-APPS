'use strict';

const { app, BrowserWindow, Menu, session, shell, ipcMain } = require('electron');
const fs = require('node:fs');
const path = require('node:path');

const APP_URL = 'https://portal.azure.com/';
const PARTITION = 'persist:microsoft-azure';
const APP_HOSTS = new Set(['portal.azure.com', 'azure.microsoft.com', 'portal.azure.us', 'portal.azure.cn']);
const AUTH_HOSTS = new Set([
  'microsoft.com', 'microsoftonline.com', 'office.com', 'office365.com', 'live.com',
  'cloud.microsoft', 'msauth.net', 'msftauth.net', 'msidentity.com', 'office.net'
]);
const PERMISSIONS = new Set(['notifications', 'clipboard-read', 'clipboard-sanitized-write']);
let win;
let statePath;

function trusted(value) {
  try {
    const url = new URL(value);
    const hosts = [...APP_HOSTS, ...AUTH_HOSTS];
    return url.protocol === 'https:' && hosts.some((host) => url.hostname === host || url.hostname.endsWith(`.${host}`));
  } catch {
    return false;
  }
}

function external(value) {
  try {
    const url = new URL(value);
    if (['http:', 'https:', 'mailto:', 'tel:'].includes(url.protocol)) void shell.openExternal(url.toString());
  } catch {}
}

function readState() {
  try {
    const value = JSON.parse(fs.readFileSync(statePath, 'utf8'));
    if (Number.isInteger(value.width) && Number.isInteger(value.height)) return value;
  } catch {}
  return { width: 1400, height: 900 };
}

function saveState() {
  if (!win || win.isDestroyed()) return;
  fs.mkdirSync(path.dirname(statePath), { recursive: true });
  fs.writeFileSync(statePath, JSON.stringify(win.getNormalBounds()));
}

function configureSession(appSession) {
  appSession.setPermissionRequestHandler((contents, permission, callback) => {
    let origin;
    try { origin = new URL(contents.getURL()); } catch { callback(false); return; }
    callback(origin.protocol === 'https:' && trusted(origin.toString()) && PERMISSIONS.has(permission));
  });
  appSession.setPermissionCheckHandler((contents, permission, requestingOrigin) => (
    PERMISSIONS.has(permission) && trusted(requestingOrigin || contents.getURL())
  ));
}

function applyPolicy(window) {
  const contents = window.webContents;
  contents.setWindowOpenHandler(({ url }) => {
    if (!trusted(url)) {
      external(url);
      return { action: 'deny' };
    }
    return {
      action: 'allow',
      overrideBrowserWindowOptions: {
        width: 1100,
        height: 800,
        title: 'Microsoft Azure',
        webPreferences: {
          preload: path.join(__dirname, 'preload.js'),
          contextIsolation: true,
          nodeIntegration: false,
          sandbox: true,
          webSecurity: true,
          partition: PARTITION
        }
      }
    };
  });
  contents.on('did-create-window', applyPolicy);
  for (const eventName of ['will-navigate', 'will-redirect']) {
    contents.on(eventName, (event, url) => {
      if (!trusted(url)) {
        event.preventDefault();
        external(url);
      }
    });
  }
  contents.on('will-download', (_event, item) => {
    item.setSavePath(path.join(app.getPath('downloads'), item.getFilename()));
  });
  contents.on('did-fail-load', (_event, errorCode) => {
    if (errorCode !== -3) void window.loadFile(path.join(__dirname, 'offline.html'));
  });
  contents.on('render-process-gone', () => {
    if (!window.isDestroyed()) void window.loadURL(APP_URL);
  });
}

function createMenu() {
  Menu.setApplicationMenu(Menu.buildFromTemplate([
    { label: 'File', submenu: [{ label: 'Reload', role: 'reload' }, { role: 'back' }, { role: 'forward' }, { type: 'separator' }, { role: 'close' }] },
    { label: 'View', submenu: [{ role: 'zoomIn' }, { role: 'zoomOut' }, { role: 'resetZoom' }, { role: 'togglefullscreen' }, ...(app.isPackaged ? [] : [{ role: 'toggleDevTools', accelerator: 'CommandOrControl+Shift+I' }])] },
    { label: 'Account', submenu: [{ label: 'Clear Session Data', click: async () => { await session.fromPartition(PARTITION).clearStorageData(); await win?.loadURL(APP_URL); } }] },
    { label: 'Help', submenu: [{ label: 'Official Website', click: () => external(APP_URL) }, { role: 'about' }] }
  ]));
}

async function createWindow() {
  statePath = path.join(app.getPath('userData'), 'window-state.json');
  win = new BrowserWindow({
    ...readState(),
    minWidth: 900,
    minHeight: 600,
    title: 'Microsoft Azure',
    icon: path.join(__dirname, 'assets/icons/microsoft-azure.svg'),
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
      webSecurity: true,
      partition: PARTITION
    }
  });
  applyPolicy(win);
  win.on('resize', saveState);
  win.on('move', saveState);
  win.on('closed', () => { win = null; });
  await win.loadURL(APP_URL);
}

ipcMain.handle('retry-load', () => win?.loadURL(APP_URL));

if (!app.requestSingleInstanceLock()) app.quit();
else {
  app.whenReady().then(async () => {
    configureSession(session.fromPartition(PARTITION));
    createMenu();
    await createWindow();
    app.on('activate', () => { if (!BrowserWindow.getAllWindows().length) void createWindow(); });
  });
  app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });
  app.on('before-quit', saveState);
}
