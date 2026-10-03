const crypto = require('node:crypto');
const { redirectUri } = require('../../_github');

module.exports = (request, response) => {
  if (!process.env.GITHUB_CLIENT_ID || !process.env.GITHUB_CLIENT_SECRET || !process.env.AUTH_SECRET) {
    response.status(500).send('GitHub OAuth is not configured.');
    return;
  }
  const state = crypto.randomBytes(24).toString('hex');
  const query = new URLSearchParams({
    client_id: process.env.GITHUB_CLIENT_ID,
    redirect_uri: redirectUri(),
    scope: 'public_repo follow',
    state
  });
  response.setHeader('Set-Cookie', `github_oauth_state=${state}; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=600`);
  response.redirect(`https://github.com/login/oauth/authorize?${query}`);
};
