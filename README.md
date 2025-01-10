### Introduction

A plugin for zsh to auto activate virtual environment. Applicable to uv, poetry.
It will check current path if exist `.venv` folder. Determine whether to activate the virtual environment based on this folder.


### Installation
```bash
git clone https://github.com/lxp731/auto-venv.git "$ZSH_CUSTOM/plugins/auto-venv"
```
Then add this line to your `.zshrc`. Make sure it is before the line source `$ZSH/oh-my-zsh.sh`.
```bash
plugins=(
    auto-venv
)
```
