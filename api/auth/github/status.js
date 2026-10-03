const { github, json, sessionToken } = require('../../_github');

module.exports = async (request, response) => {
  const token = sessionToken(request);
  if (!token) {
    json(response, 401, { authenticated: false });
    return;
  }
  const user = await github('/user', {}, token);
  if (!user.response.ok) {
    json(response, 401, { authenticated: false });
    return;
  }
  const [star, follow] = await Promise.all([
    github('/user/starred/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS', { method: 'GET' }, token),
    github('/user/following/SIMARSINGHRAYAT', { method: 'GET' }, token)
  ]);
  json(response, 200, {
    authenticated: true,
    user: { login: user.data.login, avatar: user.data.avatar_url },
    repoStarred: star.response.status === 204,
    profileFollowed: follow.response.status === 204
  });
};
