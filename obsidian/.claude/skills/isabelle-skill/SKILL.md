---
name: isabelle-skill
description: Create a new Claude skill in the dotfiles repo for use in Obsidian/Ona workspaces
---

The user wants to create a new Claude skill. Follow these steps:

1. Ask the user for:
   - **Skill name**: kebab-case name (e.g., `my-new-skill`)
   - **Description**: One-line description of what the skill does
   - **Instructions**: The prompt/instructions the skill should contain

2. Create the skill at `~/dotfiles/obsidian/.claude/skills/<skill-name>/SKILL.md` with this format:

```markdown
---
name: <skill-name>
description: <description>
---

<instructions>
```

3. Run `bash ~/dotfiles/stow.sh` to symlink the new skill into the current workspace.

4. Commit and push to persist for future workspaces:
```bash
cd ~/dotfiles && git add . && git commit -m "Add <skill-name> skill" && git push
```

5. Confirm to the user that the skill is available now via `/<skill-name>` and will be auto-linked in future Ona workspaces.
