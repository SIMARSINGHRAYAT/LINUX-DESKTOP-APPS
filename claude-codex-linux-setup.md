# Claude Code and OpenAI Codex on Linux

## Claude Code CLI

Install Claude Code using the official APT repository:

```bash
sudo apt update && \
sudo apt install -y curl gnupg ca-certificates && \
sudo install -d -m 0755 /etc/apt/keyrings && \
sudo curl -fsSL https://downloads.claude.ai/keys/claude-code.asc -o /etc/apt/keyrings/claude-code.asc && \
echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/stable stable main" | \
sudo tee /etc/apt/sources.list.d/claude-code.list > /dev/null && \
sudo apt update && \
sudo apt install -y claude-code && \
claude --version
```

Launch Claude Code:

```bash
claude
```

## Claude Desktop

Install Claude Desktop using the official APT repository:

```bash
sudo curl -fsSLo /usr/share/keyrings/claude-desktop-archive-keyring.asc https://downloads.claude.ai/claude-desktop/key.asc && \
echo "deb [signed-by=/usr/share/keyrings/claude-desktop-archive-keyring.asc] https://downloads.claude.ai/claude-desktop/apt/stable stable main" | \
sudo tee /etc/apt/sources.list.d/claude-desktop.list > /dev/null && \
sudo apt update && \
sudo apt install -y claude-desktop && \
claude-desktop
```

If this message appears when Claude Desktop starts:

```text
vaInitialize failed: unknown libva error
```

Claude Desktop can still launch successfully.

## npm Installation

Install npm:

```bash
sudo apt install npm
```

## OpenAI Codex CLI

First attempt to install Codex:

```bash
npm install -g @openai/codex
```

If npm returns an EACCES permission error for:

```text
/usr/local/lib/node_modules
```

install Codex with:

```bash
sudo npm install -g @openai/codex
```

Launch Codex:

```bash
codex
```

Check the installed version:

```bash
codex --version
```

## ChatGPT Desktop

The ChatGPT desktop application is installed from the downloaded Debian package.

Check the Downloads directory:

```bash
cd ~/Downloads
ls
```

The package used is:

```text
chatgpt_amd64.deb
```

Install it with:

```bash
cd ~/Downloads && sudo apt install -y ./chatgpt_amd64.deb
```

If APT reports a dependency issue, run:

```bash
sudo apt --fix-broken install -y
```

Then install the package again:

```bash
cd ~/Downloads && sudo apt install -y ./chatgpt_amd64.deb
```

The package may display the following notice during installation:

```text
Download is performed unsandboxed as root
```

This does not prevent the package from installing successfully.

## Final Setup

The completed Linux setup includes:

- Claude Code CLI
- Claude Desktop
- OpenAI Codex CLI
- ChatGPT Desktop
