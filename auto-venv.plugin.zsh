# auto-activate-venv.plugin.zsh

PROJECT_PATH=""
CURRENT_PATH=""

auto_activate() {
  local NEW_PATH=$(pwd)

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

autoload -Uz add-zsh-hook
add-zsh-hook precmd auto_activate

