'use strict';

function allowedHost(host, hosts) {
  return [...hosts].some((entry) => host === entry || host.endsWith(`.${entry}`));
}

function configureSession(appSession, appHosts, authHosts) {
  const isTrusted = (origin) => {
    try {
      const url = new URL(origin);
      return url.protocol === 'https:' && (allowedHost(url.hostname.toLowerCase(), appHosts) || allowedHost(url.hostname.toLowerCase(), authHosts));
    } catch {
      return false;
    }
  };
  const allowedPermissions = new Set(['clipboard-read', 'clipboard-sanitized-write', 'media', 'notifications']);
  appSession.setPermissionRequestHandler((webContents, permission, callback) => callback(allowedPermissions.has(permission) && isTrusted(webContents.getURL())));
  appSession.setPermissionCheckHandler((_webContents, permission, requestingOrigin) => allowedPermissions.has(permission) && isTrusted(requestingOrigin));
}

module.exports = { configureSession };