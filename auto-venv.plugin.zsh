# auto-activate-venv.plugin.zsh

PROJECT_PATH=""
CURRENT_PATH=""

auto_activate() {
  local NEW_PATH=$(pwd)

  if [[ "$NEW_PATH" != "$CURRENT_PATH" ]]; then
    CURRENT_PATH="$NEW_PATH"

    # 检查是否存在虚拟环境目录
    if [[ -d ".venv" ]] || [[ -d "venv" ]]; then
      # 如果当前没有激活任何项目，则激活新的虚拟环境
      if [[ -z "$PROJECT_PATH" ]]; then
        source .venv/bin/activate || source venv/bin/activate
        PROJECT_PATH="$CURRENT_PATH"
      else
        # 如果当前路径不在已激活项目路径下，停用旧环境并激活新环境
        if [[ "$CURRENT_PATH" != "$PROJECT_PATH"* ]]; then
          if [[ -n "$VIRTUAL_ENV" ]]; then
            deactivate
          fi
          source .venv/bin/activate || source venv/bin/activate
          PROJECT_PATH="$CURRENT_PATH"
        fi
      fi
    else
      # 如果当前没有虚拟环境，且之前有激活的环境，则停用它
      if [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate
        PROJECT_PATH=""
      fi
    fi
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd auto_activate

