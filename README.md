# auto-venv 🐍

Automatically activate and deactivate Python virtual environments as you move between
directories. Zero configuration, minimal overhead.

## ✨ Features

- **Auto-activate** — enters `.venv` or `venv` when you `cd` into a project
- **Auto-deactivate** — leaves the virtualenv when you `cd` out
- **Path caching** — skips redundant filesystem scans for fast repeated navigation
- **Subdirectory-aware** — stays active when moving deeper within the same project
- **Secure** — rejects paths containing `..` to prevent traversal attacks
- **Toggle on/off** — set `AUTO_ACTIVATE_VENV=0` to temporarily disable

## 🚀 Installation

### Zsh (Oh My Zsh)

```bash
git clone https://github.com/lxp731/auto-venv.git "$ZSH_CUSTOM/plugins/auto-venv"
```

Then add `auto-venv` to your plugin list in `~/.zshrc`:

```bash
plugins=(... auto-venv)
```

> Place it **before** the `source $ZSH/oh-my-zsh.sh` line.

### Bash

```bash
curl -o ~/.auto-venv.bash https://raw.githubusercontent.com/lxp731/auto-venv/main/auto-venv.bash
echo 'source ~/.auto-venv.bash' >> ~/.bashrc
```

## ⚙️ Configuration

| Variable | Default | Description |
|---|---|---|
| `AUTO_ACTIVATE_VENV` | `1` | Set to `0` to disable automatic activation |
| `MAX_PARENT_LEVELS` | `7` | Max directory levels to search upward |

## 🧠 How It Works

On every prompt, `auto-venv` scans upward from the current directory (up to
`MAX_PARENT_LEVELS` levels) looking for a `.venv` or `venv` directory. The first
match is cached per working directory, so subsequent visits skip the scan
entirely. Activation and deactivation happen automatically — no `.venv` marker
files, no tool-specific lockfile parsing, just the vanilla `bin/activate` script.

Works with **uv**, **Poetry**, **virtualenv**, or anything that produces a
standard `.venv` layout.

## 📄 License

MIT
