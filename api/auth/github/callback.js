const { cookieValue, redirectUri, setSession } = require('../../_github');

module.exports = async (request, response) => {
  const { code, state, error } = request.query;
  const savedState = cookieValue(request, 'github_oauth_state');
  if (error || !code || !state || state !== savedState) {
    response.redirect('/?auth_error=github');
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
    response.redirect('/support.html');
  } catch {
    response.redirect('/?auth_error=github');
  }
};
