# dotfiles

Personal dotfiles for shell config and Claude skills.

## Structure

```
dotfiles/
├── install.sh              # Entry point run by Ona on workspace creation
├── post-start-install.sh   # Runs after EFS mounts; installs the Cursor helper
├── install-cursor-shared-root.sh
├── cursor-shared-root/     # Personal remote extension: adds EFS beside Obsidian
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

### Cursor: show the EFS share beside Obsidian

`post-start-install.sh` installs the personal `isabelleyzhou.cursor-shared-root`
extension into the Cursor server stored on EFS. When a remote Cursor window finishes
starting with `/workspaces/obsidian` open, the extension adds `/home/vscode/shared`
as a second Explorer root named `Shared`.

The hook runs before Cursor is necessarily connected, so the installer waits in the
background for Cursor's remote server binary. On a brand-new EFS volume, the first
connection can win that race and require one window reload; after the extension is
installed on EFS, subsequent Ona instances load it automatically on connection.

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
