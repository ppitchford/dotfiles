# .zshrc

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Environment
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="kitty"
export PATH="$HOME/.local/share/uv/tools/bin:$PATH"

# Zinit setup
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
if [[ ! -d $ZINIT_HOME ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab

# Completions
autoload -Uz compinit && compinit -C
zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE="${XDG_STATE_HOME}/zsh/history"
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory hist_ignore_space
setopt hist_ignore_all_dups hist_save_no_dups hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias obsidian="~/.local/bin/obsidian/Obsidian.AppImage --ozone-platform=wayland"

# keychain
if command -v keychain >/dev/null 2>&1; then
  eval "$(keychain --eval --quiet id_ed25519 hetzner_hil)"
fi

# Keychain is a session-setup concern (manages a daemon, may prompt for passphrase), so it belongs at the front of the eval block.
# Putting it before mise means any mise hooks that ever invoke git+ssh will already have the agent. 

# fzf
eval "$(fzf --zsh)"

# zoxide (https://crates.io/crates/zoxide)
eval "$(zoxide init --cmd z zsh)"

# Starship prompt (https://starship.rs/)
eval "$(starship init zsh)"

# Mise-en-place (https://mise.jdx.dev/)
eval "$(mise activate zsh)"

# ── System ────────────────────────────────────────────────────────────────────

sys-update() {
  echo "Updating system packages..."
  sudo xbps-install -Su
  echo "Removing orphaned dependencies..."
  sudo xbps-remove -O
  echo "Updating zinit and plugins..."
  zinit self-update
  zinit update --all
  echo "Done."
}

# Dotfiles management
# A function rather than an alias so git's completion can be attached to it.
dotfiles() { git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }
compdef dotfiles=git

# Stage everything, commit, and push in one step: dotsave "message"
# Prints what it is about to sweep up, since add -A also takes new files.
dotsave() {
  if [[ -z "$*" ]]; then
    echo "usage: dotsave <message>"
    return 1
  fi
  if [[ -z "$(dotfiles status --porcelain)" ]]; then
    echo "Nothing to commit."
    return 0
  fi
  dotfiles status --short
  dotfiles add -A && dotfiles commit -q -m "$*" && dotfiles push
}

# ── WiFi ──────────────────────────────────────────────────────────────────────

wifi-scan() {
  iwctl station wlp192s0 scan && iwctl station wlp192s0 get-networks
}

wifi-connect() {
  iwctl station wlp192s0 connect "$1"
}

wifi-disconnect() {
  iwctl station wlp192s0 disconnect
}

wifi-status() {
  iwctl station wlp192s0 show
}

wifi-saved() {
  iwctl known-networks list
}

wifi-forget() {
  iwctl known-networks "$1" forget
}

# ── Bluetooth ─────────────────────────────────────────────────────────────────

bt-connect() {
  bluetoothctl connect "$1"
}

bt-disconnect() {
  bluetoothctl disconnect "$1"
}

bt-airpods() {
  bluetoothctl connect 74:15:F5:25:09:92
}

# ── Zettelkasten ──────────────────────────────────────────────────────────────

export ZK_HOME="$HOME/Documents/zettelkasten"

zet() {
  local id=$(date +%Y%m%d%H%M%S)
  local today=$(date +%Y-%m-%d)
  local file="$ZK_HOME/inbox/${id}.md"
  sed -e "s/{{id}}/${id}/g" -e "s/{{date}}/${today}/g" \
    "$ZK_HOME/templates/note.md" > "$file"
  nvim "$file"
}

jrnl() {
  local id=$(date +%Y%m%d000000)
  local today=$(date +%Y-%m-%d)
  local file="$ZK_HOME/journal/${id}.md"
  if [[ ! -f "$file" ]]; then
    sed -e "s/{{id}}/${id}/g" -e "s/{{date}}/${today}/g" \
      "$ZK_HOME/templates/daily.md" > "$file"
  fi
  nvim "$file"
}

idx() {
  local id=$(date +%Y%m%d%H%M%S)
  local today=$(date +%Y-%m-%d)
  local file="$ZK_HOME/topics/${id}.md"
  sed -e "s/{{id}}/${id}/g" -e "s/{{date}}/${today}/g" \
    "$ZK_HOME/templates/index.md" > "$file"
  nvim "$file"
}

inbox() {
  local count=$(find "$ZK_HOME/inbox" -name "*.md" 2>/dev/null | wc -l)
  if [[ $count -eq 0 ]]; then
    echo "Inbox is empty."
  else
    echo "$count note(s) awaiting review in inbox."
  fi
}

inbox
export PATH="$HOME/.npm-global/bin:$PATH"
