# The rest of my fun git aliases
alias ungit="find . -name '.git' -exec rm -rf {} \;"
alias gb='git branch'
alias gba='git branch -a'
alias gc='git commit -v'
alias gca='git commit -v -a'
# Commit pending changes and quote all args as message
function gg() {
    git commit -v -a -m "$*"
}
alias gco='git checkout'
alias gd='git diff'
alias gdm='git diff master'
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gnp="git-notpushed"
alias gp='git push'
alias gpr='git open-pr'
alias gam='git commit --amend -C HEAD'
alias gst='git status'
alias gt='git status'
alias g='git status --short'
alias gsp='git smart-pull'
alias gm='smart-merge'
alias eg='code .git/config'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias ghv="gh repo view --web"
alias ghvb="gh repo view --web --branch \$(git branch --show-current)"
alias v="gh repo view --web --branch \$(git branch --show-current)"
