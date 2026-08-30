const categories = [
  {
    id: 'top-ai-dev-apps',
    name: 'Top 10 AI Developer Apps',
    description: 'Developer tools for coding, machine learning, and AI workflows.',
    apps: [
      { name: 'GitHub', slug: 'github', icon: '../csc-main/logo/github.png', readme: '../csc-main/Top-10-AI-Developer-Apps/GitHub/README.md' },
      { name: 'GitLab', slug: 'gitlab', icon: '../csc-main/logo/gitlab.png', readme: '../csc-main/Top-10-AI-Developer-Apps/GitLab/README.md' },
      { name: 'Kaggle', slug: 'kaggle', icon: '../csc-main/logo/Kaggle.png', readme: '../csc-main/Top-10-AI-Developer-Apps/Kaggle/README.md' },
      { name: 'Jupyter', slug: 'jupyter', icon: '../csc-main/logo/jupyter.png', readme: '../csc-main/Top-10-AI-Developer-Apps/Jupyter/README.md' },
      { name: 'LeetCode', slug: 'leetcode', icon: '../csc-main/logo/leetcode.png', readme: '../csc-main/Top-10-AI-Developer-Apps/LeetCode/README.md' },
      { name: 'Hugging Face', slug: 'hugging-face', icon: '../csc-main/logo/hugging-face.png', readme: '../csc-main/Top-10-AI-Developer-Apps/HuggingFace/README.md' },
      { name: 'Google Colab', slug: 'google-colab', icon: '../csc-main/logo/google-colab.png', readme: '../csc-main/Top-10-AI-Developer-Apps/GoogleColab/README.md' },
      { name: 'Roboflow', slug: 'roboflow', icon: '../csc-main/logo/Roboflow.png', readme: '../csc-main/Top-10-AI-Developer-Apps/Roboflow/README.md' },
      { name: 'Codeforces', slug: 'codeforces', icon: '../csc-main/logo/codeforces.png', readme: '../csc-main/Top-10-AI-Developer-Apps/Codeforces/README.md' }
    ]
  },
  {
    id: 'microsoft-apps',
    name: 'Microsoft Apps',
    description: 'Productivity apps from Microsoft for Linux desktop users.',
    apps: [
      { name: 'Microsoft Teams', slug: 'teams', icon: '../csc-main/logo/Microsoft_Office_Teams_Logo_512px.png', readme: '../csc-main/MICROSOFT-DESKTOP-APPS/Teams/README.md' },
      { name: 'Power BI', slug: 'powerbi', icon: '../csc-main/logo/Microsoft-Power-Bi--Streamline-Svg-Logos.png', readme: '../csc-main/MICROSOFT-DESKTOP-APPS/PowerBI/README.md' },
      { name: 'Whiteboard', slug: 'whiteboard', icon: '../csc-main/logo/Microsoft-whiteboard-94.png', readme: '../csc-main/MICROSOFT-DESKTOP-APPS/Whiteboard/README.md' },
      { name: 'Outlook', slug: 'outlook', icon: '../csc-main/logo/Microsoft_Office_Outlook_Logo_512px.png', readme: '../csc-main/MICROSOFT-DESKTOP-APPS/Outlook/README.md' }
    ]
  },
  {
    id: 'streaming-apps',
    name: 'Streaming Apps',
    description: 'Entertainment and video streaming apps packaged for Linux.',
    apps: [
      { name: 'Netflix', slug: 'netflix', icon: '../csc-main/logo/netflix.png', readme: '../csc-main/Streaming-Apps/Netflix/README.md' },
      { name: 'Prime Video', slug: 'prime-video', icon: '../csc-main/logo/prime.png', readme: '../csc-main/Streaming-Apps/PrimeVideo/README.md' },
      { name: 'JioHotstar', slug: 'jiohotstar', icon: '../csc-main/logo/jiohotstar.png', readme: '../csc-main/Streaming-Apps/JioHotstar/README.md' },
      { name: 'Apple TV', slug: 'appletv', icon: '../csc-main/logo/apple-tv.png', readme: '../csc-main/Streaming-Apps/AppleTV/README.md' },
      { name: 'Crunchyroll', slug: 'crunchyroll', icon: '../csc-main/logo/Crunchyroll.png', readme: '../csc-main/Streaming-Apps/Crunchyroll/README.md' },
      { name: 'MX Player', slug: 'mxplayer', icon: '../csc-main/logo/mx-player.png', readme: '../csc-main/Streaming-Apps/MXPlayer/README.md' }
    ]
  }
];

const allAppIcons = [
  'github', 'gitlab', 'Kaggle', 'google-colab', 'hugging-face', 'jupyter', 'leetcode', 'netflix',
  'prime', 'jiohotstar', 'apple-tv', 'Crunchyroll', 'mx-player', 'Microsoft_Office_Teams_Logo_512px.png',
  'Microsoft_Office_Outlook_Logo_512px.png', 'Microsoft-Power-Bi--Streamline-Svg-Logos.png',
  'Microsoft-whiteboard-94.png', 'Roboflow', 'codeforces'
];

function getLogoPath(name) {
  const normalized = name.toLowerCase();
  const lookup = {
    github: '../csc-main/logo/github.png',
    gitlab: '../csc-main/logo/gitlab.png',
    kaggle: '../csc-main/logo/Kaggle.png',
    'google colab': '../csc-main/logo/google-colab.png',
    'hugging face': '../csc-main/logo/hugging-face.png',
    jupyter: '../csc-main/logo/jupyter.png',
    leetcode: '../csc-main/logo/leetcode.png',
    netflix: '../csc-main/logo/netflix.png',
    'prime video': '../csc-main/logo/prime.png',
    jiohotstar: '../csc-main/logo/jiohotstar.png',
    'apple tv': '../csc-main/logo/apple-tv.png',
    crunchyroll: '../csc-main/logo/Crunchyroll.png',
    mxplayer: '../csc-main/logo/mx-player.png',
    'microsoft teams': '../csc-main/logo/Microsoft_Office_Teams_Logo_512px.png',
    'power bi': '../csc-main/logo/Microsoft-Power-Bi--Streamline-Svg-Logos.png',
    whiteboard: '../csc-main/logo/Microsoft-whiteboard-94.png',
    outlook: '../csc-main/logo/Microsoft_Office_Outlook_Logo_512px.png',
    roboflow: '../csc-main/logo/Roboflow.png',
    codeforces: '../csc-main/logo/codeforces.png'
  };

  return lookup[normalized] || '../csc-main/logo/github.png';
}

function buildFloatingLogos() {
  const container = document.getElementById('floating-logos');
  if (!container) return;

  const logos = document.querySelectorAll('#floating-logos .logo-float');
  logos.forEach((logo) => logo.remove());

  for (let i = 0; i < 20; i++) {
    const logo = document.createElement('div');
    logo.className = 'logo-float';
    const icon = document.createElement('img');
    const item = allAppIcons[Math.floor(Math.random() * allAppIcons.length)];
    icon.src = item.includes('.') ? `../csc-main/logo/${item}` : getLogoPath(item);
    logo.style.left = `${Math.random() * 100}%`;
    logo.style.animationDuration = `${12 + Math.random() * 12}s`;
    logo.style.animationDelay = `${Math.random() * 6}s`;
    logo.appendChild(icon);
    container.appendChild(logo);
  }
}

function renderCategories() {
  const grid = document.getElementById('category-grid');
  if (!grid) return;

  grid.innerHTML = categories.map((category) => `
    <article class="category-card">
      <div class="icon-wrap">
        <img src="${getLogoPath(category.name === 'Top 10 AI Developer Apps' ? 'GitHub' : category.name === 'Microsoft Apps' ? 'Microsoft Teams' : 'Netflix')}" alt="${category.name}" />
      </div>
      <h3>${category.name}</h3>
      <p>${category.description}</p>
      <div class="card-footer">
        <a class="action-btn" href="apps.html?category=${encodeURIComponent(category.id)}">Open</a>
      </div>
    </article>
  `).join('');
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
          <img src="${app.icon || getLogoPath(app.name)}" alt="${app.name}" />
        </div>
        <span class="badge">Linux</span>
      </div>
      <h3>${app.name}</h3>
      <p>Desktop app wrapper for ${app.name}.</p>
      <div class="meta">
        <span></span>
        <a class="action-btn" href="app.html?app=${encodeURIComponent(app.slug)}&category=${encodeURIComponent(selected.id)}">View</a>
      </div>
    </article>
  `).join('');
}

function renderAppDetail() {
  const detail = document.getElementById('app-detail');
  if (!detail) return;

  const params = new URLSearchParams(window.location.search);
  const appSlug = params.get('app');
  const categoryId = params.get('category');
  const selectedCategory = categories.find((item) => item.id === categoryId) || categories[0];
  const app = selectedCategory.apps.find((item) => item.slug === appSlug) || selectedCategory.apps[0];

  fetch(app.readme)
    .then((response) => response.text())
    .then((text) => {
      const sections = text.split('\n\n');
      const cleaned = sections
        .map((section) => section.trim())
        .filter(Boolean)
        .slice(0, 12)
        .join('\n\n');

      detail.innerHTML = `
        <article class="app-detail-card">
          <div class="app-detail-header">
            <div class="large-icon">
              <img src="${app.icon || getLogoPath(app.name)}" alt="${app.name}" />
            </div>
            <div>
              <h1>${app.name}</h1>
              <p>${selectedCategory.name}</p>
            </div>
          </div>

          <div class="detail-actions">
            <a class="back-btn" href="apps.html?category=${encodeURIComponent(selectedCategory.id)}">Back to apps</a>
            <button class="copy-btn" type="button" data-copy-target="app-readme">Copy README</button>
          </div>

          <div class="code-block">
            <header>
              <h3>README</h3>
            </header>
            <pre id="app-readme">${escapeHtml(cleaned)}</pre>
          </div>
        </article>
      `;

      const copyBtn = document.querySelector('[data-copy-target="app-readme"]');
      if (copyBtn) {
        copyBtn.addEventListener('click', async () => {
          const content = document.getElementById('app-readme')?.textContent || '';
          await navigator.clipboard.writeText(content);
          copyBtn.textContent = 'Copied';
          setTimeout(() => { copyBtn.textContent = 'Copy README'; }, 1200);
        });
      }
    })
    .catch(() => {
      detail.innerHTML = `
        <article class="app-detail-card">
          <div class="app-detail-header">
            <div class="large-icon">
              <img src="${app.icon || getLogoPath(app.name)}" alt="${app.name}" />
            </div>
            <div>
              <h1>${app.name}</h1>
              <p>${selectedCategory.name}</p>
            </div>
          </div>
          <p>README content is unavailable for this app right now.</p>
        </article>
      `;
    });
}

function escapeHtml(value) {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

window.addEventListener('DOMContentLoaded', () => {
  buildFloatingLogos();
  renderCategories();
  renderApps();
  renderAppDetail();
});
