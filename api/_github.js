const crypto = require('node:crypto');

const OWNER = 'SIMARSINGHRAYAT';
const REPOSITORY = 'LINUX-DESKTOP-APPS';
const PROFILE = 'SIMARSINGHRAYAT';
const DEFAULT_REDIRECT_URI = 'https://linuxdesktopapps11.vercel.app/api/auth/github/callback';

function redirectUri() {
  return process.env.GITHUB_OAUTH_REDIRECT_URI || DEFAULT_REDIRECT_URI;
}

function cookieValue(request, name) {
  const cookies = request.headers.cookie || '';
  const match = cookies.match(new RegExp(`(?:^|; )${name}=([^;]*)`));
  return match ? decodeURIComponent(match[1]) : null;
}

function sessionKey() {
  if (!process.env.AUTH_SECRET) throw new Error('AUTH_SECRET is not configured');
  return crypto.createHash('sha256').update(process.env.AUTH_SECRET).digest();
}

function encrypt(value) {
  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv('aes-256-gcm', sessionKey(), iv);
  const encrypted = Buffer.concat([cipher.update(value, 'utf8'), cipher.final()]);
  return [iv, cipher.getAuthTag(), encrypted].map((part) => part.toString('base64url')).join('.');
}

function decrypt(value) {
  try {
    const [iv, tag, encrypted] = value.split('.').map((part) => Buffer.from(part, 'base64url'));
    const decipher = crypto.createDecipheriv('aes-256-gcm', sessionKey(), iv);
    decipher.setAuthTag(tag);
    return Buffer.concat([decipher.update(encrypted), decipher.final()]).toString('utf8');
  } catch {
    return null;
  }
}

function sessionToken(request) {
  const value = cookieValue(request, 'github_session');
  return value ? decrypt(value) : null;
}

function setSession(response, token) {
  response.setHeader('Set-Cookie', `github_session=${encodeURIComponent(encrypt(token))}; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=604800`);
}

function clearSession(response) {
  response.setHeader('Set-Cookie', 'github_session=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0');
}

async function github(path, options = {}, token) {
  const response = await fetch(`https://api.github.com${path}`, {
    ...options,
    headers: {
      Accept: 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(options.headers || {})
    }
  });
  const text = await response.text();
  let data;
  try { data = text ? JSON.parse(text) : null; } catch { data = text; }
  return { response, data };
}

function json(response, status, body) {
  response.status(status).setHeader('Content-Type', 'application/json').send(JSON.stringify(body));
}

module.exports = { OWNER, REPOSITORY, PROFILE, redirectUri, cookieValue, sessionToken, setSession, clearSession, github, json };
