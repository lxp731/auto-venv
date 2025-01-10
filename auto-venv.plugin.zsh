# auto-activate-venv.plugin.zsh

# 定义全局变量
PROJECT_PATH=""
CURRENT_PATH=""

# 自动激活虚拟环境的函数
auto_activate() {
  local NEW_PATH=$(pwd)

  # 只有在路径改变时才进行检查
  if [[ "$NEW_PATH" != "$CURRENT_PATH" ]]; then
    CURRENT_PATH="$NEW_PATH"

    if [[ -z "$PROJECT_PATH" ]]; then
      if [ -d ".venv" ]; then
        source .venv/bin/activate
        PROJECT_PATH="$CURRENT_PATH"
      fi
    else
      if [[ "$CURRENT_PATH" == "$PROJECT_PATH"* ]]; then
        return
      else
        if [[ -n "$VIRTUAL_ENV" ]]; then
          deactivate
        fi
        PROJECT_PATH=""
      fi
    fi
  fi
}

# 将 auto_activate 函数绑定到 PROMPT_COMMAND，以便在每次显示提示符时调用它
autoload -Uz add-zsh-hook
add-zsh-hook precmd auto_activate

