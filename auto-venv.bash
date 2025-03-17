# Auto-activate uv venv
PROJECT_PATH=""
CURRENT_PATH=""

auto_activate() {
  local NEW_PATH=$(pwd)

  # 只有在路径改变时才进行检查
  if [[ "$NEW_PATH" != "$CURRENT_PATH" ]]; then
    CURRENT_PATH="$NEW_PATH"

    if [[ -z "$PROJECT_PATH" ]]; then
      # 检查是否存在 .venv 或 venv 目录
      if [ -d ".venv" ]; then
        source .venv/bin/activate
        PROJECT_PATH="$CURRENT_PATH"
      elif [ -d "venv" ]; then
        source venv/bin/activate
        PROJECT_PATH="$CURRENT_PATH"
      fi
    else
      # 如果当前路径在项目路径下，则保持激活状态
      if [[ "$CURRENT_PATH" == "$PROJECT_PATH"* ]]; then
        return
      else
        # 如果不在项目路径下，则停用虚拟环境
        if [[ -n "$VIRTUAL_ENV" ]]; then
          deactivate
        fi
        PROJECT_PATH=""
      fi
    fi
  fi
}

PROMPT_COMMAND=auto_activate
