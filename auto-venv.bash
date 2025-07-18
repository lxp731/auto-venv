# auto-venv.bash
# Bash 自动激活虚拟环境脚本

AUTO_ACTIVATE_VENV=${AUTO_ACTIVATE_VENV:-1}  # 是否自动激活虚拟环境, 0 表示关闭
MAX_PARENT_LEVELS=7  # 向上最多查找 7 层目录

# 模拟 Zsh 的 associative array 缓存（使用环境变量模拟）
# Bash 4.0+ 支持 declare -A，如果你使用的是 macOS 的 Bash（老版本），请升级或使用别的方式
declare -A VENV_CACHE 2>/dev/null || VENV_CACHE_SIMULATED=1

ACTIVE_PROJECT_PATH=""
CURRENT_PATH=""

auto_activate_venv() {
  [[ "$AUTO_ACTIVATE_VENV" == "1" ]] || return

  local NEW_PATH
  NEW_PATH=$(pwd -P)

  [[ "$NEW_PATH" == "$CURRENT_PATH" ]] && return
  CURRENT_PATH="$NEW_PATH"

  local VENV_DIR=""
  local CACHE_HIT=0

  # 模拟缓存查找
  if [[ -n "${VENV_CACHE[$NEW_PATH]}" ]]; then
    VENV_DIR="${VENV_CACHE[$NEW_PATH]}"
    CACHE_HIT=1
  elif [[ -n "$VENV_CACHE_SIMULATED" ]]; then
    eval "VENV_DIR=\"\${VENV_CACHE_$NEW_PATH}\""
    [[ -n "$VENV_DIR" ]] && CACHE_HIT=1
  fi

  if [[ $CACHE_HIT -eq 0 ]]; then
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

      [[ "$dir" == "/" ]] && break
      dir=$(dirname "$dir")
      ((level++))
    done

    # 缓存结果
    if [[ -n "${VENV_CACHE[$NEW_PATH]+_}" ]]; then
      VENV_CACHE["$NEW_PATH"]="$VENV_DIR"
    elif [[ -n "$VENV_CACHE_SIMULATED" ]]; then
      eval "VENV_CACHE_$NEW_PATH"='"$VENV_DIR"'
    fi
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

# 在 Bash 中使用 PROMPT_COMMAND 模拟 Zsh 的 precmd
if [[ -n "$PROMPT_COMMAND" ]]; then
  PROMPT_COMMAND="auto_activate_venv; $PROMPT_COMMAND"
else
  PROMPT_COMMAND="auto_activate_venv"
fi