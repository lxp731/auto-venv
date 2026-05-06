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
  local project_root=""

  # 1. 尝试从缓存获取
  if [[ -n "${VENV_CACHE[$NEW_PATH]}" ]]; then
    VENV_DIR="${VENV_CACHE[$NEW_PATH]}"
  fi

  # 2. 缓存未命中 → 重新扫描
  if [[ -z "$VENV_DIR" ]]; then
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

    VENV_CACHE[$NEW_PATH]="$VENV_DIR"
  fi

  if [[ -n "$VENV_DIR" ]]; then
    project_root="${VENV_DIR:h}"

    # 安全检查：拒绝包含 .. 的路径
    if [[ "$VENV_DIR" == *..* ]]; then
      echo "auto-venv: suspicious virtualenv path detected, activation cancelled" >&2
      return
    fi

    # 判断是否进入了一个新项目
    # 使用前缀删除来判断 NEW_PATH 是否在 ACTIVE_PROJECT_PATH 下，避免 glob 误匹配
    if [[ -z "$ACTIVE_PROJECT_PATH" ]] \
      || [[ "$NEW_PATH" != "$ACTIVE_PROJECT_PATH" && "${NEW_PATH#$ACTIVE_PROJECT_PATH/}" == "$NEW_PATH" ]]; then
      if [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate
      fi
      if [[ ! -f "$VENV_DIR/bin/activate" ]]; then
        echo "auto-venv: $VENV_DIR/bin/activate not found — venv may have been deleted" >&2
        echo "auto-venv: recreate with: uv venv" >&2
        VENV_CACHE[$NEW_PATH]=""
        return
      fi
      source "$VENV_DIR/bin/activate"
      ACTIVE_PROJECT_PATH="$project_root"
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