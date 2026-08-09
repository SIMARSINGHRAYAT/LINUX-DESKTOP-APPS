'use strict';

const { app, BrowserWindow, Menu, session, shell } = require('electron');
const fs = require('node:fs');
const path = require('node:path');

const APP_URL = 'https://www.kaggle.com/';
const PARTITION = 'persist:kaggle';
const APP_HOSTS = new Set(['kaggle.com', 'www.kaggle.com', 'api.kaggle.com', 'storage.googleapis.com', 'googleusercontent.com']);
const AUTH_HOSTS = new Set(['accounts.google.com', 'appleid.apple.com', 'login.microsoftonline.com', 'auth0.com', 'okta.com']);
let mainWindow;
let statePath;

function hostAllowed(hostname, hosts) {
  const host = hostname.toLowerCase();
  return [...hosts].some((allowed) => host === allowed || host.endsWith(`.${allowed}`));
}

function isTrustedUrl(value) {
  try {
    const url = new URL(value);
    return url.protocol === 'https:' && (hostAllowed(url.hostname, APP_HOSTS) || hostAllowed(url.hostname, AUTH_HOSTS));
  } catch { return false; }
}

function openExternal(value) {
  if (value.startsWith('mailto:') || value.startsWith('tel:')) { void shell.openExternal(value); return; }
  try {
    const url = new URL(value);
    if (url.protocol === 'http:' || url.protocol === 'https:') void shell.openExternal(url.toString());
  } catch { /* Ignore unsupported URLs. */ }
}

function readWindowState() {
  const fallback = { width: 1400, height: 900 };
  try {
    const saved = JSON.parse(fs.readFileSync(statePath, 'utf8'));
    if (Number.isInteger(saved.width) && Number.isInteger(saved.height)) return { ...fallback, ...saved };
  } catch { /* First launch. */ }
  return fallback;
}

function saveWindowState() {
  if (!mainWindow || mainWindow.isDestroyed()) return;
  fs.mkdirSync(path.dirname(statePath), { recursive: true });
  fs.writeFileSync(statePath, JSON.stringify(mainWindow.getNormalBounds(), null, 2));
}

function configurePolicies(window) {
  const contents = window.webContents;
  contents.setWindowOpenHandler(({ url }) => {
    if (!isTrustedUrl(url)) { openExternal(url); return { action: 'deny' }; }
    return { action: 'allow', overrideBrowserWindowOptions: { width: 1100, height: 800, title: 'Kaggle Desktop', icon: path.join(__dirname, '..', 'resources', 'kaggle-desktop.png'), webPreferences: { preload: path.join(__dirname, 'preload.js'), contextIsolation: true, nodeIntegration: false, sandbox: true, webSecurity: true, partition: PARTITION } } };
  });
  contents.on('did-create-window', (childWindow) => configurePolicies(childWindow));
  contents.on('will-navigate', (event, url) => { if (!isTrustedUrl(url)) { event.preventDefault(); openExternal(url); } });
  contents.on('will-redirect', (event, url) => { if (!isTrustedUrl(url)) { event.preventDefault(); openExternal(url); } });
  contents.on('did-redirect-navigation', () => { if (window === mainWindow) mainWindow.focus(); });
  contents.on('did-navigate', () => { if (window === mainWindow) mainWindow.focus(); });
  contents.on('will-download', (_event, item) => item.setSavePath(path.join(app.getPath('downloads'), item.getFilename())));
}

function createMenu() {
  Menu.setApplicationMenu(Menu.buildFromTemplate([
    { label: 'File', submenu: [{ role: 'close' }, { role: 'quit' }] },
    { role: 'editMenu' },
    { label: 'View', submenu: [{ role: 'reload' }, { role: 'forceReload' }, { type: 'separator' }, { role: 'resetZoom' }, { role: 'zoomIn' }, { role: 'zoomOut' }, { type: 'separator' }, { role: 'togglefullscreen' }, { role: 'toggleDevTools', accelerator: 'CommandOrControl+Shift+I' }] },
    { role: 'windowMenu' },
    { role: 'help', submenu: [{ label: 'Kaggle.com', click: () => mainWindow?.loadURL(APP_URL) }] }
  ]));
}

async function createWindow() {
  statePath = path.join(app.getPath('userData'), 'window-state.json');
  mainWindow = new BrowserWindow({ ...readWindowState(), minWidth: 640, minHeight: 480, title: 'Kaggle Desktop', icon: path.join(__dirname, '..', 'resources', 'kaggle-desktop.png'), webPreferences: { preload: path.join(__dirname, 'preload.js'), contextIsolation: true, nodeIntegration: false, sandbox: true, webSecurity: true, partition: PARTITION } });
  configurePolicies(mainWindow);
  mainWindow.on('resize', saveWindowState);
  mainWindow.on('move', saveWindowState);
  mainWindow.on('closed', () => { mainWindow = null; });
  await mainWindow.loadURL(APP_URL);
}

if (!app.requestSingleInstanceLock()) app.quit();
else {
  app.on('second-instance', () => { if (!mainWindow) return; if (mainWindow.isMinimized()) mainWindow.restore(); mainWindow.focus(); });
  app.whenReady().then(async () => {
    const kaggleSession = session.fromPartition(PARTITION);
    kaggleSession.setUserAgent(app.userAgentFallback.replace(/\sElectron\/[^\s]+/, ''));
    kaggleSession.setPermissionRequestHandler((_webContents, permission, callback) => callback(permission === 'notifications'));
    createMenu();
    await createWindow();
    app.on('activate', () => { if (BrowserWindow.getAllWindows().length === 0) void createWindow(); });
  });
  app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });
  app.on('before-quit', saveWindowState);
}
