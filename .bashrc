# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Codespaces bash prompt theme
__bash_prompt() {
    local userpart='`echo -n "\[\033[0;32m\]justin-dev"`'
    local gitbranch='`\
        if [ "$(git config --get codespaces-theme.hide-status 2>/dev/null)" != 1 ]; then \
            export BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null); \
            if [ "${BRANCH}" != "" ]; then \
                echo -n "\[\033[0;36m\](\[\033[1;31m\]${BRANCH}" \
                && if git ls-files --error-unmatch -m --directory --no-empty-directory -o --exclude-standard ":/*" > /dev/null 2>&1; then \
                        echo -n " \[\033[1;33m\]✗"; \
                fi \
                && echo -n "\[\033[0;36m\]) "; \
            fi; \
        fi`'
    local lightblue='\[\033[1;34m\]'
    local removecolor='\[\033[0m\]'
    PS1="${userpart} ${lightblue}\w ${gitbranch}${removecolor}\$ "
    unset -f __bash_prompt
}
__bash_prompt

# Custom settings
if [ -f "/usr/share/bash-completion/completions/git" ]; then
    source /usr/share/bash-completion/completions/git
else
    echo "Error loading git completions"
fi

# Custom aliases
alias start="cd /workspaces/obsidian && tmuxinator start vanta -p ~/.vanta-tmux.yml"
alias pull="cd /workspaces/obsidian && git pull --rebase origin main && make generate-types"
alias types="cd /workspaces/obsidian && make generate-types"
alias cdo="cd /workspaces/obsidian"

# Git aliases
alias gs="git status"
__git_complete gs _git_status
alias ga="git add"
__git_complete ga _git_add
alias gb="git branch"
__git_complete gb _git_branch
alias gbd="git branch -d"
__git_complete gbd _git_branch
alias go="git checkout"
__git_complete go _git_checkout
alias gcam="git add . && git commit -m"
__git_complete gcam _git_commit
alias gp="git push"
__git_complete gp _git_push
alias gpf="git push -f"
__git_complete gpf _git_push
alias gpu="git push -u origin HEAD"
__git_complete gpu _git_push
alias grc="git add . && git rebase --continue"
alias grs="git rebase --skip"
alias gra="git rebase --abort"

function gcm() {
    git commit -m "$1";
}
function gcamp() {
    git add .
    git commit -m "$1";
    git push;
}
function gcampu() {
    git add .
    git commit -m "$1";
    git push -u origin HEAD;
}

function ut() {
    readarray -d "/" -t arr <<< "$1";
    TESTS="/workspaces/obsidian/build/$1.test.js" npm -w "${arr[0]}" run unit-test
}
