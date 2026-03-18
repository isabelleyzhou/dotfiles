# dotfiles

Personal dotfiles for shell config and Claude skills.

## Structure

```
dotfiles/
├── install.sh              # Entry point run by Ona on workspace creation
├── stow.sh                 # Stow symlink logic
├── .zshrc                  # Zsh config
├── .p10k.zsh               # Powerlevel10k config
├── .tmux.conf              # Tmux config
├── .vanta-tmux.yml         # Vanta tmux config
├── claude/                 # Stow package → symlinks into ~/.claude/
│   └── .claude/
│       └── skills/         # User-level Claude skills (all projects)
└── obsidian/               # Stow package → symlinks into /workspaces/obsidian/.claude/
    └── .claude/
        └── skills/         # Obsidian/Ona project-specific Claude skills
```

## Ona Setup (one-time)

```bash
gitpod user dotfiles set --repository https://github.com/isabelleyzhou/dotfiles
```

After setting this, every new Ona workspace will automatically clone this repo and run `install.sh`.

## Adding a new Claude skill

```bash
# For Obsidian-specific skills (symlinked into the project)
mkdir -p ~/dotfiles/obsidian/.claude/skills/my-skill
cat > ~/dotfiles/obsidian/.claude/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: What this skill does
---

Your instructions here.
EOF

# Re-run stow to create the symlink
bash ~/dotfiles/stow.sh

# Commit and push to persist for future workspaces
cd ~/dotfiles && git add . && git commit -m "add my-skill" && git push
```
