'use strict';

const { app, BrowserWindow, Menu, session, shell } = require('electron');
const fs = require('node:fs');
const path = require('node:path');

const APP_URL = 'https://github.com/';
const GITHUB_HOSTS = new Set(['github.com', 'www.github.com', 'gist.github.com', 'api.github.com', 'githubusercontent.com', 'raw.githubusercontent.com', 'objects.githubusercontent.com', 'githubassets.com', 'github.io']);
const AUTH_PROVIDER_HOSTS = new Set(['accounts.google.com', 'appleid.apple.com', 'login.microsoftonline.com', 'auth0.com', 'okta.com']);
let mainWindow;
let statePath;

function isAllowedHost(hostname) {
  const host = hostname.toLowerCase();
  return [...GITHUB_HOSTS].some((allowed) => host === allowed || host.endsWith(`.${allowed}`));
}

function isGithubUrl(value) {
  try {
    const url = new URL(value);
    return url.protocol === 'https:' && isAllowedHost(url.hostname);
  } catch { return false; }
}

function isTrustedAuthUrl(value) {
  if (isGithubUrl(value)) return true;
  try {
    const url = new URL(value);
    return url.protocol === 'https:' && [...AUTH_PROVIDER_HOSTS].some((allowed) => url.hostname === allowed || url.hostname.endsWith(`.${allowed}`));
  } catch { return false; }
}

function openExternal(value) {
  if (value.startsWith('mailto:') || value.startsWith('tel:')) { void shell.openExternal(value); return; }
  try {
    const url = new URL(value);
    if (url.protocol === 'http:' || url.protocol === 'https:') void shell.openExternal(url.toString());
  } catch { /* Ignore malformed navigation requests. */ }
}

function readWindowState() {
  const fallback = { width: 1400, height: 900 };
  try {
    const saved = JSON.parse(fs.readFileSync(statePath, 'utf8'));
    if (Number.isInteger(saved.width) && Number.isInteger(saved.height)) return { ...fallback, ...saved };
  } catch { /* A first launch has no state file. */ }
  return fallback;
}

function saveWindowState() {
  if (!mainWindow || mainWindow.isDestroyed()) return;
  const bounds = mainWindow.getNormalBounds();
  fs.mkdirSync(path.dirname(statePath), { recursive: true });
  fs.writeFileSync(statePath, JSON.stringify(bounds, null, 2));
}

function createMenu() {
  const template = [
    { label: 'File', submenu: [{ role: 'close' }, { role: 'quit' }] },
    { role: 'editMenu' },
    { label: 'View', submenu: [{ role: 'reload' }, { role: 'forceReload' }, { type: 'separator' }, { role: 'resetZoom' }, { role: 'zoomIn' }, { role: 'zoomOut' }, { type: 'separator' }, { role: 'togglefullscreen' }, { role: 'toggleDevTools', accelerator: 'CommandOrControl+Shift+I' }] },
    { role: 'windowMenu' },
    { role: 'help', submenu: [{ label: 'GitHub.com', click: () => mainWindow?.loadURL(APP_URL) }] }
  ];
  Menu.setApplicationMenu(Menu.buildFromTemplate(template));
}

function configureWindowPolicies(window) {
  const contents = window.webContents;
  contents.setWindowOpenHandler(({ url }) => {
    if (!isTrustedAuthUrl(url)) {
      openExternal(url);
      return { action: 'deny' };
    }
    return {
      action: 'allow',
      overrideBrowserWindowOptions: {
        width: 1100,
        height: 800,
        title: 'GitHub Desktop',
        icon: path.join(__dirname, '..', 'resources', 'github-desktop.png'),
        webPreferences: {
          preload: path.join(__dirname, 'preload.js'),
          contextIsolation: true,
          nodeIntegration: false,
          sandbox: true,
          webSecurity: true,
          partition: 'persist:github'
        }
      }
    };
  });
  contents.on('did-create-window', (childWindow) => configureWindowPolicies(childWindow));
  contents.on('will-navigate', (event, url) => {
    if (!isTrustedAuthUrl(url)) { event.preventDefault(); openExternal(url); }
  });
  contents.on('will-redirect', (event, url) => {
    if (!isTrustedAuthUrl(url)) { event.preventDefault(); openExternal(url); }
  });
  contents.on('did-redirect-navigation', () => { if (window === mainWindow) mainWindow.focus(); });
  contents.on('did-navigate', () => { if (window === mainWindow) mainWindow.focus(); });
  contents.on('will-download', (_event, item) => item.setSavePath(path.join(app.getPath('downloads'), item.getFilename())));
}

async function createWindow() {
  statePath = path.join(app.getPath('userData'), 'window-state.json');
  const state = readWindowState();
  mainWindow = new BrowserWindow({ ...state, minWidth: 640, minHeight: 480, title: 'GitHub Desktop', icon: path.join(__dirname, '..', 'resources', 'github-desktop.png'), webPreferences: { preload: path.join(__dirname, 'preload.js'), contextIsolation: true, nodeIntegration: false, sandbox: true, webSecurity: true, partition: 'persist:github' } });
  configureWindowPolicies(mainWindow);
  mainWindow.on('resize', saveWindowState);
  mainWindow.on('move', saveWindowState);
  mainWindow.on('closed', () => { mainWindow = null; });
  await mainWindow.loadURL(APP_URL);
}

const gotLock = app.requestSingleInstanceLock();
if (!gotLock) app.quit();
else {
  app.on('second-instance', () => { if (!mainWindow) return; if (mainWindow.isMinimized()) mainWindow.restore(); mainWindow.focus(); });
  app.whenReady().then(async () => {
    const githubSession = session.fromPartition('persist:github');
    githubSession.setUserAgent(app.userAgentFallback.replace(/\sElectron\/[^\s]+/, ''));
    githubSession.setPermissionRequestHandler((_webContents, permission, callback) => callback(permission === 'notifications'));
    createMenu();
    await createWindow();
    app.on('activate', () => { if (BrowserWindow.getAllWindows().length === 0) void createWindow(); });
  });
  app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });
  app.on('before-quit', saveWindowState);
}