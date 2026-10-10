'use strict';

const { app, BrowserWindow, Menu, session, shell, ipcMain } = require('electron');
const fs = require('node:fs');
const path = require('node:path');

const APP_URL = 'https://www.kimi.ai/en';
const PARTITION = 'persist:kimi-desktop';
const TRUSTED_HOSTS = new Set(['kimi.ai', 'google.com', 'github.com', 'microsoftonline.com']);
const ALLOWED_PERMISSIONS = new Set(['notifications', 'clipboard-read', 'clipboard-sanitized-write']);
let mainWindow;
let windowStatePath;

function isTrustedUrl(value) {
  try {
    const url = new URL(value);
    return url.protocol === 'https:' && [...TRUSTED_HOSTS].some((host) =>
      url.hostname === host || url.hostname.endsWith(`.${host}`));
  } catch {
    return false;
  }
}

function openExternal(value) {
  try {
    const url = new URL(value);
    if (['http:', 'https:', 'mailto:', 'tel:'].includes(url.protocol)) void shell.openExternal(url.toString());
  } catch {}
}

function readWindowState() {
  try {
    const saved = JSON.parse(fs.readFileSync(windowStatePath, 'utf8'));
    if (Number.isInteger(saved.width) && Number.isInteger(saved.height)) return saved;
  } catch {}
  return { width: 1440, height: 920 };
}

function saveWindowState() {
  if (!mainWindow || mainWindow.isDestroyed()) return;
  fs.mkdirSync(path.dirname(windowStatePath), { recursive: true });
  fs.writeFileSync(windowStatePath, JSON.stringify(mainWindow.getNormalBounds()));
}

function applyNavigationPolicy(window) {
  const contents = window.webContents;
  contents.setWindowOpenHandler(({ url }) => {
    if (isTrustedUrl(url)) {
      return { action: 'allow', overrideBrowserWindowOptions: {
        width: 1100, height: 800, title: 'Kimi',
        webPreferences: { preload: path.join(__dirname, 'preload.js'), contextIsolation: true, nodeIntegration: false, sandbox: true, partition: PARTITION }
      } };
    }
    openExternal(url);
    return { action: 'deny' };
  });
  contents.on('did-create-window', applyNavigationPolicy);
  for (const eventName of ['will-navigate', 'will-redirect']) {
    contents.on(eventName, (event, url) => { if (!isTrustedUrl(url)) { event.preventDefault(); openExternal(url); } });
  }
  contents.on('will-download', (_event, item) => item.setSavePath(path.join(app.getPath('downloads'), item.getFilename())));
  contents.on('did-fail-load', (_event, errorCode, _description, _url, isMainFrame) => {
    if (isMainFrame && errorCode !== -3) void window.loadFile(path.join(__dirname, 'offline.html'));
  });
  contents.on('render-process-gone', () => { if (!window.isDestroyed()) void window.loadURL(APP_URL); });
}

function createWindow() {
  mainWindow = new BrowserWindow({
    ...readWindowState(), minWidth: 900, minHeight: 640, title: 'Kimi', icon: path.join(__dirname, 'logo.png'), backgroundColor: '#f7f8fa',
    webPreferences: { preload: path.join(__dirname, 'preload.js'), contextIsolation: true, nodeIntegration: false, sandbox: true, webSecurity: true, partition: PARTITION }
  });
  applyNavigationPolicy(mainWindow);
  mainWindow.on('close', saveWindowState);
  void mainWindow.loadURL(APP_URL);
}

app.whenReady().then(() => {
  windowStatePath = path.join(app.getPath('userData'), 'window-state.json');
  const kimiSession = session.fromPartition(PARTITION);
  kimiSession.setPermissionRequestHandler((_webContents, permission, callback) => callback(ALLOWED_PERMISSIONS.has(permission)));
  Menu.setApplicationMenu(null);
  ipcMain.handle('retry-load', () => mainWindow && !mainWindow.isDestroyed() ? mainWindow.loadURL(APP_URL) : undefined);
  createWindow();
  app.on('activate', () => { if (BrowserWindow.getAllWindows().length === 0) createWindow(); });
});

app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });
app.on('before-quit', saveWindowState);
