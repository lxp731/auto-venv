# auto-activate-venv.plugin.zsh

AUTO_ACTIVATE_VENV=${AUTO_ACTIVATE_VENV:-1}  # 是否自动激活 venv, 0 则不激活
MAX_PARENT_LEVELS=7  # 向上最多查找 7 层目录

typeset -g ACTIVE_PROJECT_PATH=""
typeset -g CURRENT_PATH=""
typeset -gA VENV_CACHE  # 缓存路径查找结果

auto_activate() {
  if [[ "$AUTO_ACTIVATE_VENV" != "1" ]]; then
    return
  fi

  local NEW_PATH=$(pwd -P)
  if [[ "$NEW_PATH" == "$CURRENT_PATH" ]]; then
    return
  fi

  CURRENT_PATH="$NEW_PATH"
  local VENV_DIR=""

  # 检查缓存中是否存在
  if [[ -n "${VENV_CACHE[$NEW_PATH]}" ]]; then
    VENV_DIR="${VENV_CACHE[$NEW_PATH]}"
  else
    # 缓存未命中，开始查找
    local dir="$NEW_PATH"
    local level=0

    while (( level <= MAX_PARENT_LEVELS )); do
      if [[ -d "$dir/.venv" ]]; then
        VENV_DIR="$dir/.venv"
        break
      elif [[ -d "$dir/venv" ]]; then
        VENV_DIR="$dir/venv"
        break
      fi

      if [[ "$dir" == "/" || "$dir" == "." ]]; then
        break
      fi

      dir=$(dirname "$dir")
      ((level++))
    done

    # 缓存结果
    VENV_CACHE[$NEW_PATH]="$VENV_DIR"
  fi

  if [[ -n "$VENV_DIR" ]]; then
    if [[ -z "$ACTIVE_PROJECT_PATH" || "$NEW_PATH" != "$ACTIVE_PROJECT_PATH"* ]]; then
      if [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate
      fi
      source "$VENV_DIR/bin/activate"
      ACTIVE_PROJECT_PATH="$dir"
    fi
  else
    if [[ -n "$VIRTUAL_ENV" ]]; then
      deactivate
      ACTIVE_PROJECT_PATH=""
    fi
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd auto_activate