const categories = [
  {
    id: 'top-ai-dev-apps',
    name: 'Top 10 AI Developer Apps',
    description: 'Developer tools for coding, AI, and ML workflows.',
    apps: [
      { name: 'GitHub', slug: 'github', icon: './csc-main/logo/github.png', readme: './csc-main/Top-10-AI-Developer-Apps/GitHub/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/GitHub/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/GitHub/uninstall.sh | bash' },
      { name: 'GitHub Desktop', slug: 'github-desktop', icon: './csc-main/logo/github.png', readme: './csc-main/Top-10-AI-Developer-Apps/GitHub Desktop/README.md', installCommand: 'cd ~/Downloads && sudo apt install -y ./GitHubDesktop-linux-amd64-3.4.13-linux1.deb && echo "GitHub Desktop installed successfully." && /usr/bin/github-desktop', uninstallCommand: 'sudo apt remove -y github-desktop || sudo dpkg -r github-desktop' },
      { name: 'GitLab', slug: 'gitlab', icon: './csc-main/logo/gitlab.png', readme: './csc-main/Top-10-AI-Developer-Apps/GitLab/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/GitLab/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/GitLab/uninstall.sh | bash' },
      { name: 'Kaggle', slug: 'kaggle', icon: './csc-main/logo/Kaggle.png', readme: './csc-main/Top-10-AI-Developer-Apps/Kaggle/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/Kaggle/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/Kaggle/uninstall.sh | bash' },
      { name: 'Jupyter', slug: 'jupyter', icon: './csc-main/logo/jupyter.png', readme: './csc-main/Top-10-AI-Developer-Apps/Jupyter/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/Jupyter/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/Jupyter/uninstall.sh | bash' },
      { name: 'LeetCode', slug: 'leetcode', icon: './csc-main/logo/leetcode.png', readme: './csc-main/Top-10-AI-Developer-Apps/LeetCode/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/LeetCode/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/LeetCode/uninstall.sh | bash' },
      { name: 'Hugging Face', slug: 'hugging-face', icon: './csc-main/logo/hugging-face.png', readme: './csc-main/Top-10-AI-Developer-Apps/HuggingFace/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/HuggingFace/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/HuggingFace/uninstall.sh | bash' },
      { name: 'Google Colab', slug: 'google-colab', icon: './csc-main/logo/google-colab.png', readme: './csc-main/Top-10-AI-Developer-Apps/GoogleColab/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/GoogleColab/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/GoogleColab/uninstall.sh | bash' },
      { name: 'Roboflow', slug: 'roboflow', icon: './csc-main/logo/Roboflow.png', readme: './csc-main/Top-10-AI-Developer-Apps/Roboflow/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/Roboflow/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/Roboflow/uninstall.sh | bash' },
      { name: 'Codeforces', slug: 'codeforces', icon: './csc-main/logo/codeforces.png', readme: './csc-main/Top-10-AI-Developer-Apps/Codeforces/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/Codeforces/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/Codeforces/uninstall.sh | bash' }
    ]
  },
  {
    id: 'microsoft-apps',
    name: 'Microsoft Apps',
    description: 'Official productivity apps for Linux desktop workflows.',
    apps: [
      { name: 'Microsoft Teams', slug: 'teams', icon: './csc-main/logo/Microsoft_Office_Teams_Logo_512px.png', readme: './csc-main/MICROSOFT-DESKTOP-APPS/Teams/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/Teams/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/Teams/uninstall.sh | bash' },
      { name: 'Power BI', slug: 'powerbi', icon: './csc-main/logo/Microsoft-Power-Bi--Streamline-Svg-Logos.png', readme: './csc-main/MICROSOFT-DESKTOP-APPS/PowerBI/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/PowerBI/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/PowerBI/uninstall.sh | bash' },
      { name: 'Whiteboard', slug: 'whiteboard', icon: './csc-main/logo/Microsoft-whiteboard-94.png', readme: './csc-main/MICROSOFT-DESKTOP-APPS/Whiteboard/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/Whiteboard/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/Whiteboard/uninstall.sh | bash' },
      { name: 'Outlook', slug: 'outlook', icon: './csc-main/logo/Microsoft_Office_Outlook_Logo_512px.png', readme: './csc-main/MICROSOFT-DESKTOP-APPS/Outlook/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/Outlook/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/Outlook/uninstall.sh | bash' }
    ]
  },
  {
    id: 'streaming-apps',
    name: 'Streaming Apps',
    description: 'Entertainment and video streaming apps packaged for Linux.',
    apps: [
      { name: 'Netflix', slug: 'netflix', icon: './csc-main/logo/netflix.png', readme: './csc-main/Streaming-Apps/Netflix/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Streaming-Apps/Netflix/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Streaming-Apps/Netflix/uninstall.sh | bash' },
      { name: 'Prime Video', slug: 'prime-video', icon: './csc-main/logo/prime.png', readme: './csc-main/Streaming-Apps/PrimeVideo/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Streaming-Apps/PrimeVideo/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Streaming-Apps/PrimeVideo/uninstall.sh | bash' },
      { name: 'JioHotstar', slug: 'jiohotstar', icon: './csc-main/logo/jiohotstar.png', readme: './csc-main/Streaming-Apps/JioHotstar/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Streaming-Apps/JioHotstar/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Streaming-Apps/JioHotstar/uninstall.sh | bash' },
      { name: 'Apple TV', slug: 'appletv', icon: './csc-main/logo/apple-tv.png', readme: './csc-main/Streaming-Apps/AppleTV/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Streaming-Apps/AppleTV/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Streaming-Apps/AppleTV/uninstall.sh | bash' },
      { name: 'Crunchyroll', slug: 'crunchyroll', icon: './csc-main/logo/Crunchyroll.png', readme: './csc-main/Streaming-Apps/Crunchyroll/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Streaming-Apps/Crunchyroll/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Streaming-Apps/Crunchyroll/uninstall.sh | bash' },
      { name: 'MX Player', slug: 'mxplayer', icon: './csc-main/logo/mx-player.png', readme: './csc-main/Streaming-Apps/MXPlayer/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Streaming-Apps/MXPlayer/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Streaming-Apps/MXPlayer/uninstall.sh | bash' }
    ]
  },
  {
    id: 'cloud-apps',
    name: 'Cloud Code Apps',
    description: 'Cloud and developer platform tooling for coding and software delivery.',
    apps: [
      { name: 'GitHub', slug: 'github-cloud', icon: './csc-main/logo/github.png', readme: './csc-main/Top-10-AI-Developer-Apps/GitHub/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/GitHub/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/GitHub/uninstall.sh | bash' },
      { name: 'GitLab', slug: 'gitlab-cloud', icon: './csc-main/logo/gitlab.png', readme: './csc-main/Top-10-AI-Developer-Apps/GitLab/README.md', installCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/GitLab/install.sh | bash', uninstallCommand: 'curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/Top-10-AI-Developer-Apps/GitLab/uninstall.sh | bash' }
    ]
  }
];

const floatingIcons = [
  'github.png', 'gitlab.png', 'Kaggle.png', 'google-colab.png', 'hugging-face.png', 'jupyter.png', 'leetcode.png',
  'netflix.png', 'prime.png', 'jiohotstar.png', 'apple-tv.png', 'Crunchyroll.png', 'mx-player.png',
  'Microsoft_Office_Teams_Logo_512px.png', 'Microsoft_Office_Outlook_Logo_512px.png',
  'Microsoft-Power-Bi--Streamline-Svg-Logos.png', 'Microsoft-whiteboard-94.png', 'Roboflow.png', 'codeforces.png'
];

function getIconSrc(name) {
  const lookup = {
    github: './csc-main/logo/github.png',
    'github desktop': './csc-main/logo/github.png',
    gitlab: './csc-main/logo/gitlab.png',
    kaggle: './csc-main/logo/Kaggle.png',
    'google colab': './csc-main/logo/google-colab.png',
    'hugging face': './csc-main/logo/hugging-face.png',
    jupyter: './csc-main/logo/jupyter.png',
    leetcode: './csc-main/logo/leetcode.png',
    netflix: './csc-main/logo/netflix.png',
    'prime video': './csc-main/logo/prime.png',
    jiohotstar: './csc-main/logo/jiohotstar.png',
    'apple tv': './csc-main/logo/apple-tv.png',
    crunchyroll: './csc-main/logo/Crunchyroll.png',
    mxplayer: './csc-main/logo/mx-player.png',
    'microsoft teams': './csc-main/logo/Microsoft_Office_Teams_Logo_512px.png',
    'power bi': './csc-main/logo/Microsoft-Power-Bi--Streamline-Svg-Logos.png',
    whiteboard: './csc-main/logo/Microsoft-whiteboard-94.png',
    outlook: './csc-main/logo/Microsoft_Office_Outlook_Logo_512px.png',
    roboflow: './csc-main/logo/Roboflow.png',
    codeforces: './csc-main/logo/codeforces.png'
  };
  return lookup[String(name).toLowerCase()] || './csc-main/logo/github.png';
}

function buildFloatingLogos() {
  const container = document.getElementById('floating-logos');
  if (!container) return;

  for (let i = 0; i < 24; i++) {
    const item = floatingIcons[Math.floor(Math.random() * floatingIcons.length)];
    const logo = document.createElement('div');
    const img = document.createElement('img');
    logo.className = 'logo-float';
    img.src = `./csc-main/logo/${item}`;
    img.alt = 'App logo';
    logo.style.left = `${Math.random() * 100}%`;
    logo.style.animationDuration = `${12 + Math.random() * 14}s`;
    logo.style.animationDelay = `${Math.random() * 7}s`;
    logo.appendChild(img);
    container.appendChild(logo);
  }
}

function renderCategories() {
  const grid = document.getElementById('category-grid');
  if (!grid) return;

  grid.innerHTML = categories.map((category) => {
    const first = category.apps[0]?.name || 'App';
    const icon = getIconSrc(first);
    return `
      <article class="category-card">
        <div class="icon-wrap">
          <img src="${icon}" alt="${category.name}" />
        </div>
        <h3>${category.name}</h3>
        <p>${category.description}</p>
        <div class="card-footer">
          <a class="action-btn" href="./apps.html?category=${encodeURIComponent(category.id)}">Open</a>
        </div>
      </article>
    `;
  }).join('');
}

function renderApps() {
  const grid = document.getElementById('apps-grid');
  const title = document.getElementById('app-list-title');
  if (!grid) return;

  const params = new URLSearchParams(window.location.search);
  const categoryId = params.get('category');
  const selected = categories.find((item) => item.id === categoryId) || categories[0];

  if (title) title.textContent = selected.name;

  grid.innerHTML = selected.apps.map((app) => `
    <article class="app-card">
      <div class="app-header">
        <div class="app-icon">
          <img src="${app.icon || getIconSrc(app.name)}" alt="${app.name}" />
        </div>
        <span class="badge">Linux</span>
      </div>
      <h3>${app.name}</h3>
      <p>Desktop app wrapper for ${app.name}.</p>
      <div class="meta">
        <span></span>
        <a class="action-btn" href="./app.html?app=${encodeURIComponent(app.slug)}&category=${encodeURIComponent(selected.id)}">View</a>
      </div>
    </article>
  `).join('');
}

async function fetchReadme(url) {
  try {
    const response = await fetch(url, { cache: 'no-store' });
    if (!response.ok) throw new Error('Readme unavailable');
    return await response.text();
  } catch (error) {
    return null;
  }
}

function copyText(text) {
  return navigator.clipboard.writeText(text);
}

function buildReadmeBlocks(app, markdown) {
  if (!markdown) return '<p>README content is unavailable for this app.</p>';

  const installCommand = app.installCommand || 'Install command not found.';
  const uninstallCommand = app.uninstallCommand || 'Uninstall command not found.';

  const renderBlock = (label, content, id) => `
    <div class="code-block">
      <header>
        <h3>${label}</h3>
        <button class="copy-btn" data-copy="${id}">Copy</button>
      </header>
      <pre id="${id}">${escapeHtml(content || 'No command available for this section.')}</pre>
    </div>
  `;

  return `
    ${renderBlock('Installation', installCommand, 'installation-block')}
    ${renderBlock('Uninstallation', uninstallCommand, 'uninstallation-block')}
    <div class="code-block">
      <header>
        <h3>Readme</h3>
      </header>
      <pre>${escapeHtml(markdown.slice(0, 4000))}</pre>
    </div>
  `;
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

async function renderAppDetail() {
  const detail = document.getElementById('app-detail');
  if (!detail) return;

  const params = new URLSearchParams(window.location.search);
  const appSlug = params.get('app');
  const categoryId = params.get('category');
  const category = categories.find((item) => item.id === categoryId) || categories[0];
  const app = category.apps.find((item) => item.slug === appSlug) || category.apps[0];

  const markdown = await fetchReadme(app.readme);

  detail.innerHTML = `
    <article class="app-detail-card">
      <div class="app-detail-header">
        <div class="large-icon">
          <img src="${app.icon || getIconSrc(app.name)}" alt="${app.name}" />
        </div>
        <div>
          <h1>${app.name}</h1>
          <p>${category.name}</p>
        </div>
      </div>

      <div class="detail-actions">
        <a class="back-btn" href="./apps.html?category=${encodeURIComponent(category.id)}">Back to apps</a>
      </div>

      <div class="copy-group">
        ${markdown ? buildReadmeBlocks(app, markdown) : '<p>README content is unavailable for this app.</p>'}
      </div>
    </article>
  `;

  document.querySelectorAll('[data-copy]').forEach((button) => {
    button.addEventListener('click', async () => {
      const target = button.getAttribute('data-copy');
      const source = document.getElementById(target);
      if (!source) return;
      await copyText(source.textContent);
      const original = button.textContent;
      button.textContent = 'Copied';
      setTimeout(() => { button.textContent = original; }, 1200);
    });
  });
}

window.addEventListener('DOMContentLoaded', () => {
  buildFloatingLogos();
  renderCategories();
  renderApps();
  renderAppDetail();
});
