'use strict';

const { app, BrowserWindow, Menu, session, shell, ipcMain } = require('electron');
const fs = require('node:fs');
const path = require('node:path');

const APP_URL = 'https://teams.microsoft.com/';
const PARTITION = 'persist:microsoft-teams';
const APP_HOSTS = new Set(['teams.microsoft.com', 'teams.cloud.microsoft', 'teams.live.com']);
const MICROSOFT_HOSTS = new Set([
  'microsoft.com', 'microsoftonline.com', 'office.com', 'office365.com', 'live.com',
  'cloud.microsoft', 'msauth.net', 'msftauth.net', 'msidentity.com', 'office.net'
]);
const ALLOWED_PERMISSIONS = new Set(['media', 'notifications', 'clipboard-read', 'clipboard-sanitized-write']);
let mainWindow;
let statePath;

function hostMatches(host, hosts) {
  return [...hosts].some((entry) => host === entry || host.endsWith(`.${entry}`));
}

function isTrustedMicrosoftUrl(value) {
  try {
    const url = new URL(value);
    return url.protocol === 'https:' && (hostMatches(url.hostname.toLowerCase(), APP_HOSTS) || hostMatches(url.hostname.toLowerCase(), MICROSOFT_HOSTS));
  } catch {
    return false;
  }
}

function openExternal(value) {
  try {
    const url = new URL(value);
    if (url.protocol === 'http:' || url.protocol === 'https:' || url.protocol === 'mailto:' || url.protocol === 'tel:') void shell.openExternal(url.toString());
  } catch {}
}

function readWindowState() {
  try {
    const state = JSON.parse(fs.readFileSync(statePath, 'utf8'));
    if ([state.width, state.height].every(Number.isInteger)) return state;
  } catch {}
  return { width: 1400, height: 900 };
}

function saveWindowState() {
  if (!mainWindow || mainWindow.isDestroyed()) return;
  fs.mkdirSync(path.dirname(statePath), { recursive: true });
  fs.writeFileSync(statePath, JSON.stringify(mainWindow.getNormalBounds()));
}

function configureSession(appSession) {
  appSession.setPermissionRequestHandler((webContents, permission, callback) => {
    let origin;
    try { origin = new URL(webContents.getURL()); } catch { callback(false); return; }
    callback(origin.protocol === 'https:' && isTrustedMicrosoftUrl(origin.toString()) && ALLOWED_PERMISSIONS.has(permission));
  });
  appSession.setPermissionCheckHandler((webContents, permission, requestingOrigin) => {
    return ALLOWED_PERMISSIONS.has(permission) && isTrustedMicrosoftUrl(requestingOrigin || webContents.getURL());
  });
  appSession.on('will-download', (_event, item) => {
    item.setSavePath(path.join(app.getPath('downloads'), item.getFilename()));
  });
}

function applyNavigationPolicy(window) {
  const contents = window.webContents;
  contents.setWindowOpenHandler(({ url }) => {
    if (!isTrustedMicrosoftUrl(url)) { openExternal(url); return { action: 'deny' }; }
    return { action: 'allow', overrideBrowserWindowOptions: {
      width: 1100, height: 800, title: 'Microsoft Teams',
      webPreferences: { preload: path.join(__dirname, 'preload.js'), contextIsolation: true, nodeIntegration: false, sandbox: true, webSecurity: true, partition: PARTITION }
    } };
  });
  contents.on('did-create-window', applyNavigationPolicy);
  for (const eventName of ['will-navigate', 'will-redirect']) {
    contents.on(eventName, (event, url) => {
      if (!isTrustedMicrosoftUrl(url)) { event.preventDefault(); openExternal(url); }
    });
  }
  contents.on('did-fail-load', (_event, errorCode, _errorDescription, validatedURL, isMainFrame) => {
    if (isMainFrame && errorCode !== -3 && !isTrustedMicrosoftUrl(validatedURL)) void window.loadFile(path.join(__dirname, 'offline.html'));
    else if (isMainFrame && errorCode !== -3) void window.loadFile(path.join(__dirname, 'offline.html'));
  });
  contents.on('render-process-gone', () => { if (!window.isDestroyed()) void window.loadURL(APP_URL); });
}

function createMenu() {
  Menu.setApplicationMenu(Menu.buildFromTemplate([
    { label: 'File', submenu: [{ label: 'Reload', role: 'reload' }, { role: 'back' }, { role: 'forward' }, { type: 'separator' }, { role: 'close' }] },
    { label: 'View', submenu: [{ role: 'zoomIn' }, { role: 'zoomOut' }, { role: 'resetZoom' }, { role: 'togglefullscreen' }, ...(app.isPackaged ? [] : [{ role: 'toggleDevTools', accelerator: 'CommandOrControl+Shift+I' }]) ] },
    { label: 'Account', submenu: [{ label: 'Clear Session Data', click: async () => { await session.fromPartition(PARTITION).clearStorageData(); await mainWindow?.loadURL(APP_URL); } }] },
    { label: 'Help', submenu: [{ label: 'Official Website', click: () => openExternal('https://www.microsoft.com/microsoft-teams/teams-for-work') }, { role: 'about' }] }
  ]));
}

async function createWindow() {
  statePath = path.join(app.getPath('userData'), 'window-state.json');
  mainWindow = new BrowserWindow({ ...readWindowState(), minWidth: 900, minHeight: 600, title: 'Microsoft Teams', icon: path.join(__dirname, 'assets/icons/teams.svg'), webPreferences: { preload: path.join(__dirname, 'preload.js'), contextIsolation: true, nodeIntegration: false, sandbox: true, webSecurity: true, partition: PARTITION } });
  applyNavigationPolicy(mainWindow);
  mainWindow.on('resize', saveWindowState);
  mainWindow.on('move', saveWindowState);
  mainWindow.on('closed', () => { mainWindow = null; });
  await mainWindow.loadURL(APP_URL);
}

ipcMain.handle('retry-load', () => mainWindow?.loadURL(APP_URL));

if (!app.requestSingleInstanceLock()) app.quit();
else {
  app.whenReady().then(async () => {
    configureSession(session.fromPartition(PARTITION));
    createMenu();
    await createWindow();
    app.on('activate', () => { if (!BrowserWindow.getAllWindows().length) void createWindow(); });
  });
  app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });
  app.on('before-quit', saveWindowState);
}
