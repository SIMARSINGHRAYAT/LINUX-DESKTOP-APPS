const { cookieValue, redirectUri, setSession } = require('../../_github');

module.exports = async (request, response) => {
  const { code, state, error } = request.query;
  const savedState = cookieValue(request, 'github_oauth_state');
  // Invalidate the one-time state cookie immediately so it cannot be replayed.
  response.setHeader('Set-Cookie', 'github_oauth_state=; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=0');
  if (error || !code || !state || !savedState || state !== savedState) {
    response.writeHead(302, { Location: '/signin.html?auth_error=github' });
    response.end();
    return;
  }

  try {
    const tokenResponse = await fetch('https://github.com/login/oauth/access_token', {
      method: 'POST',
      headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
      body: JSON.stringify({
        client_id: process.env.GITHUB_CLIENT_ID,
        client_secret: process.env.GITHUB_CLIENT_SECRET,
        code,
        redirect_uri: redirectUri()
      })
    });
    const token = await tokenResponse.json();
    if (!token.access_token) throw new Error('GitHub did not return an access token');
    setSession(response, token.access_token);
    response.writeHead(302, { Location: '/support.html' });
    response.end();
  } catch {
    response.writeHead(302, { Location: '/signin.html?auth_error=github' });
    response.end();
  }
};
