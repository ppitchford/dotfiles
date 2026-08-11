# Make mise-managed tools available to non-interactive shells (e.g. Neovim/Mason)
typeset -U path PATH
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
export PKG_CONFIG_PATH="/usr/local/lib64/pkgconfig:/usr/local/share/pkgconfig"
