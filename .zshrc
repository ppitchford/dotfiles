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

# ── Dotfiles ──────────────────────────────────────────────────────────────────
# Bare repo at ~/.dotfiles with $HOME as the work tree, so configs are tracked
# where they already live — no symlink farm, no staging directory.
#
#   dotfiles status            what changed, new files included
#   dotfiles diff              review before staging
#   dotfiles add -A            stage everything, new files included
#   dotfiles commit -m "msg"
#   dotfiles push
#   dotsave "msg"              the last three in one step
#   dotfiles restore <path>    discard uncommitted changes to a file
#   dotfiles pull              picking up changes on another machine
#
# Two things that bite:
#
#   - `commit -am` and `add -u` stage only files git already tracks, so a newly
#     created config is skipped without a word. Prefer `add -A`, or dotsave.
#   - $HOME is mostly not dotfiles, so ~/.gitignore ignores everything and
#     re-includes tracked areas by name. A new area is invisible to status —
#     not just untracked, invisible — until you add a `!` line for it there.
#     That header explains the scheme; read it before adding a new area.
#     `dotfiles check-ignore -v <path>` names the rule and line that hides it.

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

# ── Notes ─────────────────────────────────────────────────────────────────────

# New zettel: new-note <title>. The title becomes the filename, so quote it
# if it contains an apostrophe. Frontmatter comes from --set because `iwe new`
# writes none, and the template's {{id}} is a random slug, not a timestamp.
new-note() {
  if [[ -z "$*" ]]; then
    echo "usage: new-note <title>"
    return 1
  fi
  # Not `local path` — zsh ties `path` to PATH, and a local one blanks it.
  local id file
  id=$(date +%Y%m%d%H%M%S)
  file=$(cd "$HOME/Documents/notes" && iwe create --template default \
    --var title="$*" --set id="\"$id\"" --set date="$(date +%F)") || return
  hx "$file"
}

export PATH="$HOME/.npm-global/bin:$PATH"
