const { github, json, sessionToken, OWNER, REPOSITORY, PROFILE } = require('../../_github');

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
  const isOwner = user.data.login.toLowerCase() === OWNER.toLowerCase();
  if (isOwner) {
    json(response, 200, {
      authenticated: true,
      user: { login: user.data.login, avatar: user.data.avatar_url },
      repoStarred: true,
      profileFollowed: true,
      isOwner: true
    });
    return;
  }
  const [star, follow] = await Promise.all([
    github(`/user/starred/${OWNER}/${REPOSITORY}`, { method: 'GET' }, token),
    github(`/user/following/${PROFILE}`, { method: 'GET' }, token)
  ]);
  json(response, 200, {
    authenticated: true,
    user: { login: user.data.login, avatar: user.data.avatar_url },
    repoStarred: isOwner || star.response.status === 204,
    profileFollowed: isOwner || follow.response.status === 204,
    isOwner
  });
};
