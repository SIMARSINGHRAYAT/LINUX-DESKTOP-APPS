'use strict';

const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('desktopApp', Object.freeze({
  retry: () => ipcRenderer.invoke('retry-load')
}));
