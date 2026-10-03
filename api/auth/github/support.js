const { github, json, sessionToken } = require('../../_github');

module.exports = async (request, response) => {
  const token = sessionToken(request);
  if (!token) {
    json(response, 401, { error: 'Sign in with GitHub first.' });
    return;
  }
  const action = request.body && request.body.action;
  const currentUser = await github('/user', {}, token);
  if (!currentUser.response.ok) {
    json(response, 401, { error: 'GitHub session expired.' });
    return;
  }
  if (currentUser.data.login.toLowerCase() === 'simarsinghrayat') {
    json(response, 200, { complete: true, owner: true });
    return;
  }
  const target = action === 'repo' ? '/user/starred/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS' : action === 'profile' ? '/user/following/SIMARSINGHRAYAT' : null;
  if (!target) {
    json(response, 400, { error: 'Unknown support action.' });
    return;
  }
  const result = await github(target, { method: 'PUT', headers: { 'Content-Length': '0' } }, token);
  if (![204, 304].includes(result.response.status)) {
    json(response, result.response.status === 401 ? 401 : 502, { error: 'GitHub could not complete this action.' });
    return;
  }
  json(response, 200, { complete: true });
};
