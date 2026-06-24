#!/usr/bin/env bash

set -e

zshrc() {
    echo "==========================================================="
    echo "             cloning zsh-autosuggestions                   "
    echo "-----------------------------------------------------------"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    echo "==========================================================="
    echo "             cloning zsh-syntax-highlighting               "
    echo "-----------------------------------------------------------"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    echo "==========================================================="
    echo "             cloning powerlevel10k                         "
    echo "-----------------------------------------------------------"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    echo "==========================================================="
    echo "             import zshrc                                  "
    echo "-----------------------------------------------------------"
    cat .zshrc > $HOME/.zshrc
    echo "==========================================================="
    echo "             import powerlevel10k                          "
    echo "-----------------------------------------------------------"
    cat .p10k.zsh > $HOME/.p10k.zsh
}

zshrc

# make directly highlighting readable - needs to be after zshrc line
echo "" >> ~/.zshrc
echo "# remove ls and directory completion highlight color" >> ~/.zshrc
echo "_ls_colors=':ow=01;33'" >> ~/.zshrc
echo 'zstyle ":completion:*:default" list-colors "${(s.:.)_ls_colors}"' >> ~/.zshrc
echo 'LS_COLORS+=$_ls_colors' >> ~/.zshrc

# ── stow setup (claude skills + obsidian project links) ──────────────────────
if ! command -v stow &> /dev/null; then
  echo "Installing stow..."
  if [[ $OSTYPE == 'darwin'* ]]; then
    brew install stow
  elif [[ $OSTYPE == 'linux-gnu'* ]]; then
    sudo apt-get install -y stow
  fi
fi

# jq is used below to merge settings.json (which is NOT symlinked — Claude rewrites it at runtime).
if ! command -v jq &> /dev/null; then
  echo "Installing jq..."
  if [[ $OSTYPE == 'darwin'* ]]; then
    brew install jq
  elif [[ $OSTYPE == 'linux-gnu'* ]]; then
    sudo apt-get install -y jq
  fi
fi

bash "${HOME}/dotfiles/stow.sh"

# ── merge Claude settings (settings.json is .stow-local-ignore'd, not symlinked) ─────────────
# Deep-merge the repo's intended settings (hooks, enabledPlugins, …) into the live
# ~/.claude/settings.json so Claude can still own runtime keys (marketplaces, model). Repo values
# win on overlapping keys; everything Claude wrote that the repo doesn't mention is preserved.
repo_settings="${HOME}/dotfiles/claude/.claude/settings.json"
live_settings="${HOME}/.claude/settings.json"
if [ -f "$repo_settings" ]; then
  mkdir -p "${HOME}/.claude"
  if [ -f "$live_settings" ] && command -v jq &> /dev/null; then
    tmp_settings="$(mktemp)"
    if jq -s '.[0] * .[1]' "$live_settings" "$repo_settings" > "$tmp_settings"; then
      mv "$tmp_settings" "$live_settings"
      echo "Merged Claude settings into $live_settings"
    else
      rm -f "$tmp_settings"
      echo "WARN: failed to merge settings.json; left $live_settings unchanged"
    fi
  elif [ ! -f "$live_settings" ]; then
    cp "$repo_settings" "$live_settings"
    echo "Created $live_settings from repo settings"
  fi
fi

# ── gh auth: derive GH_TOKEN from the valid Ona git credential ───────────────
# .zshrc is installed via `cat` above and already sources gh-token.sh. ~/.bashrc is
# the base-image file (not managed here), so append the source idempotently for bash.
gh_src_line='[ -f "$HOME/dotfiles/gh-token.sh" ] && . "$HOME/dotfiles/gh-token.sh"'
if ! grep -qF "dotfiles/gh-token.sh" "$HOME/.bashrc" 2>/dev/null; then
  printf '\n# gh auth: derive GH_TOKEN from the valid Ona git credential\n%s\n' "$gh_src_line" >> "$HOME/.bashrc"
fi

# ── personal git excludes (keeps stowed skills out of git status) ────────────
if [ -d "/workspaces/obsidian/.git" ]; then
  exclude_file="/workspaces/obsidian/.git/info/exclude"
  for skill_dir in "${HOME}/dotfiles/obsidian/.claude/skills"/*/; do
    skill_name="$(basename "$skill_dir")"
    entry=".claude/skills/${skill_name}"
    grep -qxF "$entry" "$exclude_file" 2>/dev/null || echo "$entry" >> "$exclude_file"
  done
fi

echo "Dotfiles setup complete."
